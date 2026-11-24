import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logical_day.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/stat.dart';
import '../game/progression.dart';
import 'board.dart';
import 'progression.dart';
import 'providers.dart';

/// One quest's whole history, summed up.
@immutable
class QuestRecord {
  const QuestRecord({
    required this.questTitle,
    required this.habitName,
    required this.kind,
    required this.attribute,
    required this.rank,
    required this.since,
    required this.finished,
    required this.cracks,
    required this.longestRun,
    required this.currentRun,
    this.notes = const [],
  });

  final String questTitle;
  final String habitName;
  final HabitKind kind;
  final Stat attribute;
  final String rank;
  final LogicalDay since;

  /// Days done (or held, for seals).
  final int finished;

  /// Seal cracks.
  final int cracks;

  /// Longest run of consecutive days finished.
  final int longestRun;
  final int currentRun;

  /// The most recent notes, newest first.
  final List<String> notes;
}

/// Everything the adventure has recorded, for the title appraisal and for
/// exporting as a readable file.
@immutable
class AdventureRecord {
  const AdventureRecord({
    required this.heroName,
    this.identity,
    this.heroClass,
    this.title,
    required this.level,
    required this.totalXp,
    required this.guildRank,
    required this.adventureDays,
    required this.perfectDays,
    required this.stats,
    required this.quests,
    required this.chapters,
  });

  final String heroName;
  final String? identity;
  final String? heroClass;
  final String? title;
  final int level;
  final int totalXp;
  final String guildRank;
  final int adventureDays;
  final int perfectDays;

  /// Strongest first.
  final List<(Stat, int)> stats;
  final List<QuestRecord> quests;

  /// Written chapters, oldest first: (number, title, recap).
  final List<(int, String, String)> chapters;

  /// The quest with the longest run, if any.
  QuestRecord? get best => quests.isEmpty
      ? null
      : quests.reduce((a, b) => b.longestRun > a.longestRun ? b : a);

  Map<String, Object?> toJson() => {
    'hero': {
      'name': heroName,
      if (identity != null) 'identity': identity,
      if (heroClass != null) 'class': heroClass,
      if (title != null) 'title': title,
      'level': level,
      'guildRank': guildRank,
      'adventureDays': adventureDays,
      'perfectDays': perfectDays,
      'stats': {for (final (s, v) in stats) s.label: v},
    },
    'quests': [
      for (final q in quests)
        {
          'quest': q.questTitle,
          'habit': q.habitName,
          'kind': q.kind.name,
          'attribute': q.attribute.label,
          'rank': q.rank,
          'since': q.since.toKey(),
          'finished': q.finished,
          if (q.kind == HabitKind.quit) 'cracks': q.cracks,
          'longestRun': q.longestRun,
          'currentRun': q.currentRun,
          if (q.notes.isNotEmpty) 'notes': q.notes,
        },
    ],
    'chapters': [
      for (final (n, title, recap) in chapters)
        {'chapter': n, 'title': title, 'recap': recap},
    ],
  };

  String toMarkdown() {
    final b = StringBuffer()
      ..writeln('# $heroName 的冒險紀錄')
      ..writeln()
      ..writeln(
        '- ${heroClass ?? '冒險者'}・Lv.$level・公會 Rank $guildRank'
        '${title == null ? '' : '・稱號「$title」'}',
      )
      ..writeln('- 冒險第 $adventureDays 天，完美的一天 $perfectDays 天，累積 $totalXp EXP');
    if (identity != null) b.writeln('- 想成為：$identity');
    b
      ..writeln()
      ..writeln('## 能力值')
      ..writeln()
      ..writeln(stats.map((e) => '${e.$1.label} ${e.$2}').join('、'))
      ..writeln()
      ..writeln('## 任務與封印')
      ..writeln();
    for (final q in quests) {
      b.writeln(
        '- 【${q.rank}】${q.questTitle}（${q.habitName}，${q.attribute.label}）：'
        '${q.kind == HabitKind.quit ? '守住 ${q.finished} 天、裂痕 ${q.cracks} 次' : '完成 ${q.finished} 天'}，'
        '最長連續 ${q.longestRun} 天，目前連續 ${q.currentRun} 天',
      );
      for (final n in q.notes) {
        b.writeln('  - 「$n」');
      }
    }
    if (chapters.isNotEmpty) {
      b
        ..writeln()
        ..writeln('## 冒險日誌')
        ..writeln();
      for (final (n, title, recap) in chapters) {
        b.writeln('- ${n == 0 ? '序章' : '第 $n 章'}・$title：$recap');
      }
    }
    return b.toString();
  }
}

/// Longest run of consecutive days in [days] (any order).
int longestRun(Iterable<LogicalDay> days) {
  final sorted = days.toSet().toList()..sort();
  var best = 0;
  var run = 0;
  LogicalDay? prev;
  for (final d in sorted) {
    run = prev != null && d.differenceInDays(prev) == 1 ? run + 1 : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}

QuestRecord questRecord(BoardEntry e, List<CheckIn> all) {
  final mine = all.where((c) => c.habitId == e.habit.id).toList();
  final finished = mine.where(counts).toList();
  final days = finished.map((c) => c.day);
  return QuestRecord(
    questTitle: e.active.quest.title,
    habitName: e.habit.name,
    kind: e.habit.kind,
    attribute: e.active.attribute,
    rank: e.active.quest.rank.label,
    since: e.habit.firstDay,
    finished: finished.length,
    cracks: mine.where((c) => c.outcome == CheckInOutcome.relapsed).length,
    longestRun: longestRun(days),
    currentRun: e.streak.slotDays == 1 ? e.streak.length : e.streak.days,
    notes: [
      for (final c in mine.reversed)
        if (c.note != null) c.note!,
    ].take(3).toList(),
  );
}

/// Gathers the record from the current board, progression and history.
Future<AdventureRecord?> loadRecord(WidgetRef ref) async {
  // Settings may open before anything watched the board, and Riverpod
  // pauses providers nobody listens to: listen while the data arrives.
  final subs = [
    ref.listenManual(boardProvider, (_, _) {}),
    ref.listenManual(progressionProvider, (_, _) {}),
  ];
  try {
    await Future.wait([
      ref.read(activeQuestsProvider.future),
      ref.read(recentCheckInsProvider.future),
      ref.read(totalXpProvider.future),
      ref.read(adventurerProvider.future),
      ref.read(chaptersProvider.future),
      ref.read(openOffersProvider.future),
      ref.read(questIndexProvider.future),
      ref.read(xpByQuestProvider.future),
    ]);
    return await _compose(ref);
  } finally {
    for (final s in subs) {
      s.close();
    }
  }
}

Future<AdventureRecord?> _compose(WidgetRef ref) async {
  final board = ref.read(boardProvider).value;
  final progression = ref.read(progressionProvider).value;
  final hero = board?.adventurer;
  if (board == null || progression == null || hero == null) return null;
  final all = await ref
      .read(checkInRepoProvider)
      .between(const LogicalDay(2000, 1, 1), board.today);
  final chapters = await ref.read(storyRepoProvider).all();
  final stats = progression.stats;
  return AdventureRecord(
    heroName: hero.name,
    identity: hero.identity,
    heroClass: hero.heroClass,
    title: hero.title,
    level: board.level.level,
    totalXp: board.level.totalXp,
    guildRank: hero.guildRank.label,
    adventureDays: progression.adventureDays,
    perfectDays: progression.perfectDays,
    stats: [
      for (final s in [...stats.ranked, Stat.luk]) (s, stats[s]),
    ],
    quests: [for (final e in board.entries) questRecord(e, all)],
    chapters: [
      for (final c
          in chapters.where((c) => c.status == ChapterStatus.written).toList()
            ..sort((a, b) => a.number.compareTo(b.number)))
        (c.number, c.title, c.recap),
    ],
  );
}
