import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;

import '../data/story_repository.dart';
import '../domain/chapter.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/side_quest.dart';
import '../domain/sprite_ids.dart';
import '../domain/stat.dart';
import '../domain/story_config.dart';
import 'ai_tasks.dart';

/// Result of reading an AI reply.
sealed class ParseOutcome<T> {
  const ParseOutcome();
}

final class Parsed<T> extends ParseOutcome<T> {
  const Parsed(this.value, {this.warnings = const []});
  final T value;

  /// Small issues that were fixed automatically.
  final List<String> warnings;
}

final class ParseFailed<T> extends ParseOutcome<T> {
  const ParseFailed(this.problems);

  /// What is wrong, phrased so it can be sent back to the AI.
  final List<String> problems;
}

/// Finds the JSON object in a chat reply: inside a ```json fence if there is
/// one, otherwise the outermost braces.
@visibleForTesting
Object? extractJson(String raw) {
  final text = raw.replaceAll(RegExp('[​﻿]'), '').trim();
  final fence = RegExp(r'```(?:json|JSON)?\s*\n?([\s\S]*?)```')
      .firstMatch(text);
  final candidates = [
    if (fence != null) fence.group(1)!,
    if (text.contains('{') && text.lastIndexOf('}') > text.indexOf('{'))
      text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1),
  ];
  for (final c in candidates) {
    try {
      return jsonDecode(c.trim());
    } on FormatException {
      continue;
    }
  }
  return null;
}

String _clip(Object? v, int max) {
  final s = v is String ? v.trim() : '';
  final chars = s.characters;
  return chars.length <= max ? s : chars.take(max).toString();
}

/// Wraps a tagline in ～ if the AI forgot.
String _tagline(Object? v) {
  final s = _clip(v, 24);
  if (s.isEmpty || s.startsWith('～') || s.startsWith('~')) {
    return s.replaceAll('~', '～');
  }
  return '～$s～';
}

List<String> _checkHeader(Map<Object?, Object?> json, String requestId) => [
  if (json['protocol'] != null && json['protocol'] != kProtocol)
    'protocol 必須是 "$kProtocol"。',
  if (json['requestId'] != null && json['requestId'] != requestId)
    '這是另一次請求的回應（requestId 應為 "$requestId"）。',
];

/// Choices with their blessings; a missing or unusable blessing gets one
/// from [stats] (the stats the hero's quests train) so every choice counts.
List<StoryChoice> _choices(Object? raw, int count, List<Stat> stats) {
  final list = [
    for (final c in (raw is List ? raw : const []))
      if (c is Map && _clip(c['label'], 30).isNotEmpty) c,
  ].take(count).toList();
  final pool = stats.isEmpty ? Stat.attributes : stats;
  return [
    for (final (i, c) in list.indexed)
      StoryChoice(
        _clip(c['label'], 30),
        hint: _clip(c['hint'], 60),
        blessing: switch (Blessing.fromJson(c['blessing'])) {
          final b? when pool.contains(b.stat) => b,
          _ => Blessing(
            BlessingKind.values[i % BlessingKind.values.length],
            pool[i % pool.length],
          ),
        },
      ),
  ];
}

ParseOutcome<ForgeResult> parseForge(String raw, ForgeRequest request) {
  final json = extractJson(raw);
  if (json is! Map) {
    return const ParseFailed(['找不到 JSON。請只回覆一個 ```json 程式碼區塊。']);
  }
  final problems = _checkHeader(json, request.requestId);
  final warnings = <String>[];

  final list = json['quests'];
  final byKey = <String, Map<Object?, Object?>>{
    for (final q in (list is List ? list : const []))
      if (q is Map && q['key'] is String) q['key'] as String: q,
  };
  final quests = <ForgedQuest>[];
  for (final h in request.habits) {
    final q = byKey[h.key];
    if (q == null) {
      problems.add('quests 缺少 key 為 "${h.key}" 的任務（${h.name}）。');
      continue;
    }
    final title = _clip(q['title'], 16);
    if (title.isEmpty) {
      problems.add('任務 "${h.key}" 的 title 是空的。');
      continue;
    }
    final sprite = q['spriteId'];
    quests.add(
      ForgedQuest(
        key: h.key,
        rank: QuestRank.parse('${q['rank'] ?? ''}'),
        title: title,
        subtitle: _tagline(q['subtitle']),
        flavor: _clip(q['flavor'], 120),
        spriteId: h.kind == HabitKind.quit
            ? (kMonsterSpriteIds.contains(sprite)
                  ? sprite as String
                  : guessMonster(h.name))
            : (kQuestSpriteIds.contains(sprite) ? sprite as String : 'scroll'),
        attribute: switch (Stat.parse(q['attribute'])) {
          final s? when s.isQuestAttribute => s,
          _ => guessAttribute(h.name, h.kind),
        },
      ),
    );
  }

  WorldBible? world;
  ChapterContent? prologue;
  if (request.withPrologue) {
    final w = json['world'];
    if (w is Map) world = WorldBible.fromJson(w.cast<String, Object?>());
    final p = json['prologue'];
    if (p is! Map || _clip(p['body'], 2000).isEmpty) {
      problems.add('缺少 prologue（序章）或它的 body。');
    } else {
      final count = request.config.interaction == StoryInteraction.choices
          ? request.config.choicesPerChapter
          : 0;
      prologue = ChapterContent(
        title: _clip(p['title'], 16).isEmpty ? '啟程' : _clip(p['title'], 16),
        body: _clip(p['body'], 2000),
        choices: _choices(
          p['choices'],
          count,
          {for (final q in quests) q.attribute}.toList(),
        ),
        recap: _clip(p['recap'], 200),
      );
    }
  }

  if (problems.isNotEmpty) return ParseFailed(problems);
  return Parsed(
    ForgeResult(quests: quests, world: world, prologue: prologue),
    warnings: warnings,
  );
}

ParseOutcome<ClassResult> parseClass(String raw, ClassRequest request) {
  final json = extractJson(raw);
  if (json is! Map) {
    return const ParseFailed(['找不到 JSON。請只回覆一個 ```json 程式碼區塊。']);
  }
  final problems = _checkHeader(json, request.requestId);
  final warnings = <String>[];
  final name = _clip(json['name'], 10);
  if (name.isEmpty) problems.add('name（職業名）是空的。');

  final stats = <Stat>{
    for (final s in (json['stats'] is List ? json['stats'] as List : const []))
      if (Stat.parse(s) case final stat? when stat.isQuestAttribute) stat,
  }.take(2).toList();
  if (stats.isEmpty) {
    stats.add(request.stats.first.$1);
    warnings.add('沒有主屬性，先用能力值最高的「${stats.first.label}」。');
  }
  final portrait = json['portrait'];

  if (problems.isNotEmpty) return ParseFailed(problems);
  return Parsed(
    ClassResult(
      name: name,
      stats: stats,
      flavor: _clip(json['flavor'], 60),
      portraitId: kPortraitIds.contains(portrait)
          ? portrait as String
          : 'knight',
      ceremony: _clip(json['ceremony'], 200),
    ),
    warnings: warnings,
  );
}

ParseOutcome<UpgradeProposal> parseUpgrade(String raw, UpgradeRequest request) {
  final json = extractJson(raw);
  if (json is! Map) {
    return const ParseFailed(['找不到 JSON。請只回覆一個 ```json 程式碼區塊。']);
  }
  final problems = _checkHeader(json, request.requestId);
  final title = _clip(json['title'], 16);
  if (title.isEmpty) problems.add('title（新任務名）是空的。');
  if (problems.isNotEmpty) return ParseFailed(problems);
  final raw0 = json['target'];
  final min = request.minTarget;
  final max = request.maxTarget;
  double? target;
  if (request.currentTarget != null &&
      raw0 is num &&
      min != null &&
      max != null) {
    target = raw0.toDouble().clamp(min, max);
  }
  return Parsed(
    UpgradeProposal(
      title: title,
      subtitle: _tagline(json['subtitle']),
      npcLine: _clip(json['npcLine'], 160),
      target: target,
    ),
  );
}

ParseOutcome<TitleResult> parseTitle(String raw, TitleRequest request) {
  final json = extractJson(raw);
  if (json is! Map) {
    return const ParseFailed(['找不到 JSON。請只回覆一個 ```json 程式碼區塊。']);
  }
  final problems = _checkHeader(json, request.requestId);
  final title = _clip(json['title'], 12).replaceAll(RegExp('[「」『』]'), '');
  if (title.isEmpty) problems.add('title（稱號）是空的。');
  if (problems.isNotEmpty) return ParseFailed(problems);
  return Parsed(TitleResult(title: title, reason: _clip(json['reason'], 160)));
}

/// A side quest the app can actually track, with its target clamped to
/// what the next period allows; null when it names nothing real.
SideQuestDraft? _sideQuest(Object? raw, ChapterRequest request) {
  if (raw is! Map) return null;
  final kind = SideQuestKind.values
      .where((k) => k.name == raw['kind'])
      .firstOrNull;
  final title = _clip(raw['title'], 16);
  final target = (raw['target'] as num?)?.round();
  if (kind == null || title.isEmpty || target == null) return null;
  final days = request.config.periodDays;
  final habit = request.habits
      .where((h) => h.key == raw['questKey'])
      .firstOrNull;
  final stat = Stat.parse(raw['stat']);
  final ok = switch (kind) {
    SideQuestKind.questCount => habit?.kind == HabitKind.build,
    SideQuestKind.sealClean => habit?.kind == HabitKind.quit,
    SideQuestKind.statCount =>
      stat != null && request.habits.any((h) => h.attribute == stat),
    SideQuestKind.perfectDays => true,
  };
  if (!ok) return null;
  final most = kind == SideQuestKind.statCount
      ? days * request.habits.where((h) => h.attribute == stat).length
      : days;
  return SideQuestDraft(
    title: title,
    story: _clip(raw['story'], 120),
    kind: kind,
    questKey: habit?.key,
    stat: kind == SideQuestKind.statCount ? stat : null,
    target: target.clamp(1, most),
  );
}

ParseOutcome<ChapterResult> parseChapter(String raw, ChapterRequest request) {
  final json = extractJson(raw);
  if (json is! Map) {
    return const ParseFailed(['找不到 JSON。請只回覆一個 ```json 程式碼區塊。']);
  }
  final problems = _checkHeader(json, request.requestId);
  final warnings = <String>[];

  final title = _clip(json['title'], 20);
  final body = _clip(json['body'], 3000);
  if (title.isEmpty) problems.add('title（章名）是空的。');
  if (body.isEmpty) problems.add('body（本文）是空的。');

  final choices = _choices(
    json['choices'],
    request.choiceCount,
    {for (final h in request.habits) h.attribute}.toList(),
  );
  if (request.choiceCount > 0 && choices.isEmpty) {
    problems.add('choices 需要 ${request.choiceCount} 個抉擇。');
  } else if (choices.length < request.choiceCount) {
    warnings.add('抉擇只有 ${choices.length} 個。');
  }

  var recap = _clip(json['recap'], 200);
  if (recap.isEmpty && body.isNotEmpty) {
    recap = _clip(body, 100);
    warnings.add('沒有 recap，先用本文開頭代替。');
  }

  final bonusRaw = json['qualityBonus'];
  final bonus = bonusRaw is num ? bonusRaw.toDouble() : 0.0;
  if (bonusRaw is! num) warnings.add('qualityBonus 不是數字，當作 0。');

  final wanted = {for (final h in request.upgradeCandidates) h.key};
  final upgrades = <UpgradeText>[
    for (final u
        in (json['upgrades'] is List ? json['upgrades'] as List : const []))
      if (u is Map &&
          wanted.contains(u['questKey']) &&
          _clip(u['title'], 16).isNotEmpty)
        UpgradeText(
          questKey: u['questKey'] as String,
          title: _clip(u['title'], 16),
          subtitle: _tagline(u['subtitle']),
          npcLine: _clip(u['npcLine'], 160),
        ),
  ];

  final sideQuest = _sideQuest(json['sideQuest'], request);
  if (json['sideQuest'] is Map && sideQuest == null) {
    warnings.add('sideQuest 的目標對不上任務，這章先不給支線。');
  }

  if (problems.isNotEmpty) return ParseFailed(problems);
  return Parsed(
    ChapterResult(
      content: ChapterContent(
        title: title,
        body: body,
        choices: choices,
        recap: recap,
      ),
      qualityBonus: bonus.isNaN ? 0 : bonus.clamp(0, 1).toDouble(),
      upgrades: upgrades,
      sideQuest: sideQuest,
    ),
    warnings: warnings,
  );
}
