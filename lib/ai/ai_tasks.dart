import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/story_repository.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/side_quest.dart';
import '../domain/stat.dart';
import '../domain/story_config.dart';
import '../game/checks.dart';
import '../game/judgement.dart';
import '../game/period.dart';

/// Version tag every reply must echo, so stale or foreign pastes are caught.
const kProtocol = 'hq-1';

String newRequestId([Random? random]) {
  final r = random ?? Random.secure();
  const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
  return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
}

/// Everything the AI needs to write one prompt.
@immutable
class AiPrompt {
  const AiPrompt({
    required this.requestId,
    required this.system,
    required this.user,
    required this.schema,
  });

  final String requestId;
  final String system;
  final String user;

  /// JSON schema of the expected reply.
  final Map<String, Object?> schema;

  /// The single block of text a player pastes into a chat AI.
  String get manualText => '$system\n\n$user';
}

// ---------------------------------------------------------------- forge

@immutable
class ForgeHabit {
  const ForgeHabit({
    required this.key,
    required this.kind,
    required this.name,
    this.unit,
    this.target,
    this.timesPerWeek = 7,
    this.intention,
  });

  /// Stable id inside one request, e.g. `h1`.
  final String key;
  final HabitKind kind;
  final String name;
  final String? unit;
  final double? target;
  final int timesPerWeek;
  final String? intention;
}

@immutable
class ForgeRequest {
  const ForgeRequest({
    required this.requestId,
    required this.heroName,
    this.identity,
    required this.habits,
    required this.config,
    this.withPrologue = false,
    this.world,
  });

  final String requestId;
  final String heroName;
  final String? identity;
  final List<ForgeHabit> habits;
  final StoryConfig config;

  /// First forge: also create the world and prologue.
  final bool withPrologue;

  /// Existing world, so later quests fit in.
  final WorldBible? world;
}

@immutable
class ForgedQuest {
  const ForgedQuest({
    required this.key,
    required this.rank,
    required this.title,
    required this.subtitle,
    this.flavor = '',
    required this.spriteId,
    required this.attribute,
  });

  final String key;
  final QuestRank rank;
  final String title;
  final String subtitle;
  final String flavor;
  final String spriteId;

  /// The stat the quest trains.
  final Stat attribute;
}

/// Recurring places and characters, so chapters stay consistent.
@immutable
class WorldBible {
  const WorldBible({required this.summary, this.npcs = const []});

  factory WorldBible.fromJson(Map<String, Object?> json) => WorldBible(
    summary: (json['summary'] as String?)?.trim() ?? '',
    npcs: [
      for (final n in (json['npcs'] as List?) ?? const [])
        if (n is Map)
          (
            name: (n['name'] as String?)?.trim() ?? '',
            description: (n['description'] as String?)?.trim() ?? '',
          ),
    ],
  );

  final String summary;
  final List<({String name, String description})> npcs;

  Map<String, Object?> toJson() => {
    'summary': summary,
    'npcs': [
      for (final n in npcs) {'name': n.name, 'description': n.description},
    ],
  };
}

@immutable
class ForgeResult {
  const ForgeResult({required this.quests, this.world, this.prologue});

  final List<ForgedQuest> quests;
  final WorldBible? world;
  final ChapterContent? prologue;

  ForgedQuest? questFor(String key) =>
      quests.where((q) => q.key == key).firstOrNull;
}

// -------------------------------------------------------------- chapter

/// Why a quest is offered an upgrade.
enum UpgradeReason { surpass, sealMastery }

@immutable
class ChapterHabitStats {
  const ChapterHabitStats({
    required this.key,
    required this.kind,
    required this.questTitle,
    required this.habitName,
    this.attribute = Stat.spi,
    this.unit,
    this.target,
    required this.scheduled,
    required this.completion,
    this.done = 0,
    this.partial = 0,
    this.resisted = 0,
    this.relapsed = 0,
    this.averageAmount,
    this.notes = const [],
    this.upgrade,
  });

  final String key;
  final HabitKind kind;
  final String questTitle;
  final String habitName;
  final Stat attribute;
  final String? unit;
  final double? target;
  final int scheduled;
  final double completion;
  final int done;
  final int partial;
  final int resisted;
  final int relapsed;
  final double? averageAmount;
  final List<String> notes;

  /// Set when the next tier should be offered in this chapter.
  final UpgradeReason? upgrade;
}

@immutable
class ChapterRequest {
  const ChapterRequest({
    required this.requestId,
    required this.number,
    required this.period,
    required this.config,
    required this.heroName,
    this.heroClass,
    required this.level,
    this.guildRank = QuestRank.f,
    this.checks = const [],
    this.world,
    this.recentRecaps = const [],
    this.lastChoice,
    required this.judgement,
    required this.score,
    required this.habits,
  });

  final String requestId;
  final int number;
  final Period period;
  final StoryConfig config;
  final String heroName;
  final String? heroClass;
  final int level;
  final QuestRank guildRank;

  /// Stat checks to narrate; their results are already decided.
  final List<StoryCheck> checks;
  final WorldBible? world;

  /// Oldest first.
  final List<String> recentRecaps;
  final String? lastChoice;
  final Judgement judgement;
  final double score;
  final List<ChapterHabitStats> habits;

  int get choiceCount => config.interaction == StoryInteraction.choices
      ? config.choicesPerChapter
      : 0;

  Iterable<ChapterHabitStats> get upgradeCandidates =>
      habits.where((h) => h.upgrade != null);
}

@immutable
class UpgradeText {
  const UpgradeText({
    required this.questKey,
    required this.title,
    required this.subtitle,
    required this.npcLine,
  });

  final String questKey;
  final String title;
  final String subtitle;
  final String npcLine;
}

/// A side quest as the AI wrote it; [questKey] still names a request key.
@immutable
class SideQuestDraft {
  const SideQuestDraft({
    required this.title,
    this.story = '',
    required this.kind,
    this.questKey,
    this.stat,
    required this.target,
  });

  final String title;
  final String story;
  final SideQuestKind kind;
  final String? questKey;
  final Stat? stat;
  final int target;
}

@immutable
class ChapterResult {
  const ChapterResult({
    required this.content,
    this.qualityBonus = 0,
    this.upgrades = const [],
    this.sideQuest,
  });

  final ChapterContent content;

  /// 0–1 as returned; the game clamps it with `GameRules.qualityBonusCap`.
  final double qualityBonus;
  final List<UpgradeText> upgrades;
  final SideQuestDraft? sideQuest;
}

// ---------------------------------------------------------------- class

/// One quest as the class appraisal sees it.
@immutable
class ClassHabit {
  const ClassHabit({
    required this.questTitle,
    required this.habitName,
    required this.kind,
    required this.attribute,
    required this.finished,
  });

  final String questTitle;
  final String habitName;
  final HabitKind kind;
  final Stat attribute;

  /// Finished commissions so far.
  final int finished;
}

@immutable
class ClassRequest {
  const ClassRequest({
    required this.requestId,
    required this.heroName,
    this.identity,
    required this.config,
    this.world,
    this.currentClass,
    required this.level,
    required this.stats,
    required this.habits,
  });

  final String requestId;
  final String heroName;
  final String? identity;
  final StoryConfig config;
  final WorldBible? world;

  /// Set when changing class.
  final String? currentClass;
  final int level;

  /// Stat values, strongest first.
  final List<(Stat, int)> stats;
  final List<ClassHabit> habits;
}

/// Portrait ids the AI may pick; must match `PixelPortraits.all`.
const kPortraitIds = ['knight', 'mage', 'ranger', 'rogue', 'cleric'];

@immutable
class ClassResult {
  const ClassResult({
    required this.name,
    required this.stats,
    this.flavor = '',
    required this.portraitId,
    this.ceremony = '',
  });

  final String name;

  /// One or two primary stats.
  final List<Stat> stats;
  final String flavor;
  final String portraitId;

  /// What the guild says while handing over the class.
  final String ceremony;
}

// ---------------------------------------------------------------- title

@immutable
class TitleRequest {
  const TitleRequest({
    required this.requestId,
    required this.config,
    required this.record,
    this.currentTitle,
  });

  final String requestId;
  final StoryConfig config;

  /// The adventure record as JSON (see `AdventureRecord.toJson`).
  final Map<String, Object?> record;
  final String? currentTitle;
}

@immutable
class TitleResult {
  const TitleResult({required this.title, this.reason = ''});

  final String title;

  /// Why the guild grants it, citing the record.
  final String reason;
}

// -------------------------------------------------------------- upgrade

/// Ask for a quest's next tier right when the offer is opened.
@immutable
class UpgradeRequest {
  const UpgradeRequest({
    required this.requestId,
    required this.config,
    this.world,
    required this.reason,
    required this.questTitle,
    this.questSubtitle = '',
    required this.habitName,
    this.unit,
    this.currentTarget,
    this.suggestedTarget,
    this.minTarget,
    this.maxTarget,
    required this.nextRank,
  });

  final String requestId;
  final StoryConfig config;
  final WorldBible? world;
  final UpgradeReason reason;
  final String questTitle;
  final String questSubtitle;
  final String habitName;
  final String? unit;

  /// Null for yes/no habits and seals.
  final double? currentTarget;
  final double? suggestedTarget;

  /// The AI's target is clamped to this range.
  final double? minTarget;
  final double? maxTarget;
  final QuestRank nextRank;
}

@immutable
class UpgradeProposal {
  const UpgradeProposal({
    required this.title,
    required this.subtitle,
    this.npcLine = '',
    this.target,
  });

  final String title;
  final String subtitle;
  final String npcLine;
  final double? target;
}
