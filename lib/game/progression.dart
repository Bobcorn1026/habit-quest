import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../data/habit_repository.dart';
import '../domain/adventurer.dart';
import '../domain/check_in.dart';
import '../domain/hero_class.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';

/// Numbers for stats, classes, guild ranks and curses.
@immutable
class ProgressionRules {
  const ProgressionRules({
    this.statBase = 5,
    this.statScale = 0.5,
    this.luckPerPerfectDay = 10,
    this.classStatBonus = 0.3,
    this.masteryStatBonus = 0.06,
    this.classXpBonus = 0.05,
    this.masteryXpBonus = 0.01,
    this.masteryTiers = const [20, 50, 100, 200, 400],
    this.classAfterDays = 7,
    this.classChangeCooldownDays = 14,
    this.rankPoints = const {
      QuestRank.f: 1,
      QuestRank.e: 2,
      QuestRank.d: 3,
      QuestRank.c: 4,
      QuestRank.b: 6,
      QuestRank.a: 8,
      QuestRank.s: 11,
      QuestRank.ss: 15,
      QuestRank.sss: 20,
    },
    // With the commission limits below and ~70% completion, SSS takes
    // well over a year.
    this.rankUpPoints = const {
      QuestRank.f: 80,
      QuestRank.e: 200,
      QuestRank.d: 400,
      QuestRank.c: 750,
      QuestRank.b: 1200,
      QuestRank.a: 2000,
      QuestRank.s: 3200,
      QuestRank.ss: 5000,
    },
    this.trialDays = const {
      QuestRank.e: 1,
      QuestRank.d: 2,
      QuestRank.c: 3,
      QuestRank.b: 5,
      QuestRank.a: 7,
      QuestRank.s: 10,
      QuestRank.ss: 14,
      QuestRank.sss: 21,
    },
    this.baseCommissions = 2,
    this.goldPerRank = const {
      QuestRank.f: 1,
      QuestRank.e: 1,
      QuestRank.d: 2,
      QuestRank.c: 2,
      QuestRank.b: 3,
      QuestRank.a: 4,
      QuestRank.s: 5,
      QuestRank.ss: 6,
      QuestRank.sss: 8,
    },
    this.goldStreakStepDays = 7,
    this.goldStreakCap = 5,
    this.goldPerfectDay = 10,
    this.blessingXpBonus = 0.1,
    this.blessingGold = 1,
    this.blessingCheckEase = 0.15,
    this.sideQuestGold = 30,
    this.sideQuestXp = 40,
    this.cursePenaltyFactor = 3,
    this.innPrice = 50,
    this.innMaxAheadDays = 7,
    this.innPerWeek = 2,
  });

  /// Every stat starts here.
  final int statBase;

  /// Stat = base + ⌊√(xp × weight) × scale⌋: quick early, slower later.
  final double statScale;

  /// Luck counts each perfect day as this much XP.
  final int luckPerPerfectDay;

  /// Extra stat weight for the class's stats, plus more per mastery tier.
  final double classStatBonus;
  final double masteryStatBonus;

  /// Extra XP for quests of the class's stats, plus more per mastery tier.
  /// Kept small: a class shapes stats, it barely speeds up levels.
  final double classXpBonus;
  final double masteryXpBonus;

  /// Matching commissions needed for mastery tiers I, II, III….
  final List<int> masteryTiers;

  /// The class appraisal opens this many days after the adventure began.
  final int classAfterDays;

  /// Days a class must be kept before changing it.
  final int classChangeCooldownDays;

  /// Guild points per finished commission, by quest rank.
  final Map<QuestRank, int> rankPoints;

  /// Points needed at each rank before its promotion trial opens.
  final Map<QuestRank, int> rankUpPoints;

  /// Perfect days in a row the trial for each rank asks for.
  final Map<QuestRank, int> trialDays;

  /// A failed curse costs this × the quest's base XP.
  final int cursePenaltyFactor;

  /// Gold for one night at the inn (a booked rest day).
  final int innPrice;

  /// Rest days may be booked from tomorrow up to this many days ahead.
  final int innMaxAheadDays;

  /// Most rest days that may be booked in one calendar week.
  final int innPerWeek;

  /// Quests and seals an F-rank adventurer may hold at once; each rank
  /// adds one. Starting small is the point (atomic habits).
  final int baseCommissions;

  int commissionLimit(QuestRank rank) => baseCommissions + rank.index;

  /// Gold for one finished commission, by quest rank …
  final Map<QuestRank, int> goldPerRank;

  /// … plus 1 for every [goldStreakStepDays] of its streak, up to
  /// [goldStreakCap] …
  final int goldStreakStepDays;
  final int goldStreakCap;

  /// … and this once for each perfect day.
  final int goldPerfectDay;

  /// What a chapter choice's blessing adds for its stat's quests: EXP
  /// fraction, gold per commission, and completion counted extra in checks.
  final double blessingXpBonus;
  final int blessingGold;
  final double blessingCheckEase;

  /// Paid once when a chapter's side quest is finished in time.
  final int sideQuestGold;
  final int sideQuestXp;
}

/// Gold for one check-in: its quest rank, plus a streak bonus. Partial
/// work earns half, a crack nothing.
int checkInGold({
  required ProgressionRules rules,
  required QuestRank rank,
  required CheckInOutcome outcome,
  required int streakDays,
}) {
  final base = rules.goldPerRank[rank] ?? 1;
  final streak = math.min(
    rules.goldStreakCap,
    streakDays ~/ rules.goldStreakStepDays,
  );
  return switch (outcome) {
    CheckInOutcome.done || CheckInOutcome.resisted => base + streak,
    CheckInOutcome.partial => base ~/ 2,
    CheckInOutcome.relapsed => 0,
  };
}

/// Whether [c] counts as a finished commission.
bool counts(CheckIn c) =>
    c.outcome == CheckInOutcome.done ||
    c.outcome == CheckInOutcome.partial ||
    c.outcome == CheckInOutcome.resisted;

/// A day where every daily quest was fully done and every seal held. With
/// no daily habits, one finished commission makes the day.
bool isPerfectDay(
  LogicalDay day,
  List<ActiveQuest> active,
  Map<(int, LogicalDay), CheckIn> byHabitDay,
) {
  final daily = [
    for (final aq in active)
      if (aq.habit.isDaily && !aq.habit.firstDay.isAfter(day)) aq.habit.id,
  ];
  if (daily.isEmpty) {
    return active.any((aq) => byHabitDay[(aq.habit.id, day)] != null);
  }
  return daily.every((id) {
    final c = byHabitDay[(id, day)];
    return c != null &&
        (c.outcome == CheckInOutcome.done ||
            c.outcome == CheckInOutcome.resisted);
  });
}

Map<(int, LogicalDay), CheckIn> indexCheckIns(Iterable<CheckIn> checkIns) => {
  for (final c in checkIns) (c.habitId, c.day): c,
};

/// Perfect days from the first habit's first day through [today].
int countPerfectDays({
  required List<ActiveQuest> active,
  required List<CheckIn> checkIns,
  required LogicalDay today,
}) {
  if (active.isEmpty) return 0;
  final index = indexCheckIns(checkIns);
  var day = active
      .map((a) => a.habit.firstDay)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  var n = 0;
  for (; !day.isAfter(today); day = day.addDays(1)) {
    if (isPerfectDay(day, active, index)) n++;
  }
  return n;
}

/// Share of each day's commissions finished, from [from] through [today]:
/// 1.0 is a perfect day. Days with nothing scheduled are left out.
Map<LogicalDay, double> dailyCompletion({
  required List<ActiveQuest> active,
  required List<CheckIn> checkIns,
  required LogicalDay from,
  required LogicalDay today,
}) {
  final index = indexCheckIns(checkIns);
  final out = <LogicalDay, double>{};
  for (var day = from; !day.isAfter(today); day = day.addDays(1)) {
    final daily = [
      for (final aq in active)
        if (aq.habit.isDaily && !aq.habit.firstDay.isAfter(day)) aq.habit.id,
    ];
    if (daily.isEmpty) continue;
    if (isPerfectDay(day, active, index)) {
      out[day] = 1;
      continue;
    }
    var done = 0.0;
    for (final id in daily) {
      final c = index[(id, day)];
      if (c == null) continue;
      done += c.outcome == CheckInOutcome.partial ? 0.5 : (counts(c) ? 1 : 0);
    }
    out[day] = (done / daily.length).clamp(0, 0.99);
  }
  return out;
}

@immutable
class StatSheet {
  const StatSheet(this.values, this.xp);

  final Map<Stat, int> values;

  /// Lifetime XP that went into each stat (luck: perfect days × weight).
  final Map<Stat, int> xp;

  int operator [](Stat s) => values[s] ?? 0;

  /// The attributes with the most XP, strongest first.
  List<Stat> get ranked =>
      [...Stat.attributes]..sort((a, b) => (xp[b] ?? 0).compareTo(xp[a] ?? 0));
}

StatSheet computeStats({
  required Map<int, int> xpByQuest,
  required Map<int, QuestInfo> questIndex,
  required int perfectDays,
  HeroClass? heroClass,
  int masteryTier = 0,
  required ProgressionRules rules,
}) {
  final xp = {for (final s in Stat.values) s: 0};
  for (final MapEntry(key: questId, value: amount) in xpByQuest.entries) {
    final info = questIndex[questId];
    if (info == null || amount <= 0) continue;
    xp[info.attribute] = xp[info.attribute]! + amount;
  }
  xp[Stat.luk] = perfectDays * rules.luckPerPerfectDay;

  final classWeight =
      1 + rules.classStatBonus + masteryTier * rules.masteryStatBonus;
  return StatSheet({
    for (final s in Stat.values)
      s:
          rules.statBase +
          (math.sqrt(
                    xp[s]! *
                        (heroClass?.stats.contains(s) == true
                            ? classWeight
                            : 1),
                  ) *
                  rules.statScale)
              .floor(),
  }, xp);
}

/// How far the adventurer has specialised in their class.
@immutable
class Mastery {
  const Mastery({required this.count, required this.tier, this.nextAt});

  /// Finished commissions of the class's stats since taking the class.
  final int count;

  /// 0 (none) … `masteryTiers.length`.
  final int tier;

  /// Count needed for the next tier; null at the top.
  final int? nextAt;
}

Mastery computeMastery({
  required HeroClass heroClass,
  required List<CheckIn> checkIns,
  required Map<int, QuestInfo> questIndex,
  required ProgressionRules rules,
}) {
  final count = checkIns
      .where(
        (c) =>
            counts(c) &&
            !c.day.isBefore(heroClass.since) &&
            heroClass.stats.contains(questIndex[c.questId]?.attribute),
      )
      .length;
  final tier = rules.masteryTiers.where((t) => count >= t).length;
  return Mastery(
    count: count,
    tier: tier,
    nextAt: tier < rules.masteryTiers.length ? rules.masteryTiers[tier] : null,
  );
}

/// XP multiplier for a quest training [attribute].
double classXpMultiplier({
  required HeroClass? heroClass,
  required Stat attribute,
  required int masteryTier,
  required ProgressionRules rules,
}) => heroClass != null && heroClass.stats.contains(attribute)
    ? 1 + rules.classXpBonus + masteryTier * rules.masteryXpBonus
    : 1;

enum TrialState {
  /// Not enough points yet (or already SSS).
  none,

  /// Enough points: the guild offers the promotion trial.
  available,
  running,
  passed,

  /// A trial day went by imperfect; it can be retried.
  failed,
}

@immutable
class GuildProgress {
  const GuildProgress({
    required this.rank,
    required this.points,
    this.needed,
    this.trialDays = 0,
    this.trialDaysDone = 0,
    this.state = TrialState.none,
  });

  final QuestRank rank;

  /// Points earned since the last promotion.
  final int points;

  /// Points for the next trial; null at the top rank.
  final int? needed;

  /// Perfect days the next trial asks for.
  final int trialDays;
  final int trialDaysDone;
  final TrialState state;

  bool get canStartTrial =>
      state == TrialState.available || state == TrialState.failed;

  double get progress =>
      needed == null || needed == 0 ? 1 : (points / needed!).clamp(0, 1);
}

int rankPointsFor(CheckIn c, QuestRank rank, ProgressionRules rules) {
  final base = rules.rankPoints[rank] ?? 1;
  return switch (c.outcome) {
    CheckInOutcome.done || CheckInOutcome.resisted => base,
    CheckInOutcome.partial => math.max(1, base ~/ 2),
    CheckInOutcome.relapsed => 0,
  };
}

GuildProgress computeGuild({
  required Adventurer adventurer,
  required List<ActiveQuest> active,
  required List<CheckIn> checkIns,
  required Map<int, QuestInfo> questIndex,
  required LogicalDay today,
  required ProgressionRules rules,
  Set<LogicalDay> restDays = const {},
}) {
  final rank = adventurer.guildRank;
  final since = adventurer.rankSince;
  var points = 0;
  for (final c in checkIns) {
    if (since != null && !c.day.isAfter(since)) continue;
    points += rankPointsFor(
      c,
      questIndex[c.questId]?.rank ?? QuestRank.f,
      rules,
    );
  }
  if (rank.isTop) return GuildProgress(rank: rank, points: points);

  final needed = rules.rankUpPoints[rank] ?? 0;
  final days = rules.trialDays[rank.next] ?? 1;
  final start = adventurer.trialStart;
  if (start == null) {
    return GuildProgress(
      rank: rank,
      points: points,
      needed: needed,
      trialDays: days,
      state: points >= needed ? TrialState.available : TrialState.none,
    );
  }

  final index = indexCheckIns(checkIns);
  var done = 0;
  var state = TrialState.running;
  // An imperfect rest day pauses the trial: it neither counts nor fails.
  for (var day = start; done < days; day = day.addDays(1)) {
    if (day.isAfter(today)) break;
    if (isPerfectDay(day, active, index)) {
      done++;
    } else if (restDays.contains(day)) {
      continue;
    } else if (day.isBefore(today)) {
      state = TrialState.failed;
      break;
    } else {
      break;
    }
  }
  if (done >= days) state = TrialState.passed;
  return GuildProgress(
    rank: rank,
    points: points,
    needed: needed,
    trialDays: days,
    trialDaysDone: done,
    state: state,
  );
}

/// A curse that ran out with its day, as the board reports it.
typedef CurseNews = ({String quest, bool lifted, int penalty});

/// What happened to a curse once its day ended.
enum CurseOutcome { lifted, failed }

/// A curse placed on [day] is lifted by fully doing (or holding) the quest
/// that day.
CurseOutcome judgeCurse(CheckIn? onThatDay) =>
    onThatDay != null &&
        (onThatDay.outcome == CheckInOutcome.done ||
            onThatDay.outcome == CheckInOutcome.resisted)
    ? CurseOutcome.lifted
    : CurseOutcome.failed;
