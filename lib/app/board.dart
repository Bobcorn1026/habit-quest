import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logical_day.dart';
import '../data/habit_repository.dart';
import '../domain/adventurer.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/upgrade_offer.dart';
import '../game/game_rules.dart';
import '../game/habit_stats.dart';
import '../game/period.dart';
import '../game/promotion.dart';
import '../game/stacking.dart';
import '../game/streak.dart';
import '../game/xp.dart';
import 'providers.dart';

/// One card on the quest board.
@immutable
class BoardEntry {
  const BoardEntry({
    required this.active,
    required this.today,
    required this.streak,
    required this.verdict,
    this.cursed = false,
    this.restToday = false,
    this.offer,
    this.anchorLabel,
    this.nextStep = false,
  });

  final ActiveQuest active;

  /// Today's report, if any.
  final CheckIn? today;
  final StreakState streak;
  final PromotionVerdict verdict;

  /// Edited today: must be fully done (or held) before the day ends.
  final bool cursed;

  /// Today is a booked rest day at the inn.
  final bool restToday;

  /// An open upgrade invitation for this quest.
  final UpgradeOffer? offer;

  /// Habit stacking: what this quest comes after (the anchor quest's title,
  /// or the free text); null when none, or when the anchor was archived.
  final String? anchorLabel;

  /// The anchor quest is reported today and this one is still open.
  final bool nextStep;

  BoardEntry withStack({String? anchorLabel, bool nextStep = false}) =>
      BoardEntry(
        active: active,
        today: today,
        streak: streak,
        verdict: verdict,
        cursed: cursed,
        restToday: restToday,
        offer: offer,
        anchorLabel: anchorLabel,
        nextStep: nextStep,
      );

  Habit get habit => active.habit;
  bool get isSeal => habit.kind == HabitKind.quit;
  bool get reportedToday => today != null;

  /// A cursed quest done today has lifted its curse.
  bool get curseLifted =>
      cursed &&
      (today?.outcome == CheckInOutcome.done ||
          today?.outcome == CheckInOutcome.resisted);
}

@immutable
class BoardState {
  const BoardState({
    required this.today,
    required this.entries,
    required this.level,
    this.gold = 0,
    this.restToday = false,
    this.adventurer,
    this.latestChapter,
  });

  final LogicalDay today;
  final List<BoardEntry> entries;
  final LevelInfo level;
  final int gold;

  /// Today is a booked rest day at the inn.
  final bool restToday;
  final Adventurer? adventurer;
  final Chapter? latestChapter;

  Iterable<BoardEntry> get quests => entries.where((e) => !e.isSeal);
  Iterable<BoardEntry> get seals => entries.where((e) => e.isSeal);

  /// The first stack waiting tonight: a quest whose anchor quest is done
  /// today while it is still open, else one after a free-text cue that is
  /// still open. Null when nothing is pending.
  StackHint? get pendingStack {
    for (final e in entries) {
      if (e.nextStep && e.anchorLabel != null) {
        return StackHint(
          cue: e.anchorLabel!,
          habitName: e.habit.name,
          anchorIsHabit: true,
        );
      }
    }
    for (final e in entries) {
      if (e.habit.anchorText != null &&
          e.anchorLabel != null &&
          !e.reportedToday) {
        return StackHint(
          cue: e.anchorLabel!,
          habitName: e.habit.name,
          anchorIsHabit: false,
        );
      }
    }
    return null;
  }

  /// Daily quests and seals not yet reported today.
  int get unreportedDaily =>
      entries.where((e) => e.habit.isDaily && !e.reportedToday).length;
}

/// Fills in each entry's stacking label and 下一步 flag. The order stays.
/// An anchor that is no longer on the board (archived) counts as cleared.
List<BoardEntry> applyStacks(List<BoardEntry> entries) {
  final byHabit = {for (final e in entries) e.habit.id: e};
  return [
    for (final e in entries)
      if (e.isSeal)
        e
      else if (e.habit.anchorHabitId case final id?)
        if (byHabit[id] case final a?
            when !a.isSeal && a.habit.id != e.habit.id)
          e.withStack(
            anchorLabel: a.active.quest.title,
            nextStep:
                !e.reportedToday &&
                a.today != null &&
                a.today!.outcome != CheckInOutcome.relapsed,
          )
        else
          e
      else if (e.habit.anchorText case final t? when t.trim().isNotEmpty)
        e.withStack(anchorLabel: t.trim())
      else
        e,
  ];
}

/// The quests that can be picked as [forHabit]'s anchor: every other build
/// quest on the board, minus those that would make a cycle.
List<AnchorChoice> anchorChoices(
  Iterable<BoardEntry> entries, {
  int? forHabit,
}) {
  final anchors = {for (final e in entries) e.habit.id: e.habit.anchorHabitId};
  return [
    for (final e in entries)
      if (!e.isSeal &&
          e.habit.id != forHabit &&
          (forHabit == null ||
              !anchorWouldCycle(forHabit, e.habit.id, anchors)))
        AnchorChoice(e.habit.id, e.active.quest.title),
  ];
}

/// Finished calendar weeks lying entirely inside the quest's current tier.
List<HabitPeriodStats> tierWeeks({
  required ActiveQuest active,
  required List<CheckIn> history,
  required LogicalDay today,
  required GameRules rules,
  Set<LogicalDay> restDays = const {},
}) {
  final quest = active.quest;
  // Weeks start on or after activeFrom, so earlier check-ins never count.
  final inTier = [
    for (final c in history)
      if (!c.day.isBefore(quest.activeFrom)) c,
  ];
  final weeks = PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn)
      .finishedBetween(quest.activeFrom, today)
      .where((w) => !w.start.isBefore(quest.activeFrom));
  return [
    for (final w in weeks)
      computePeriodStats(
        habit: active.habit,
        target: quest.target,
        period: w,
        checkIns: inTier,
        firstDay: active.habit.firstDay,
        asOf: w.last,
        restDays: restDays,
      ),
  ];
}

/// [checkIns] may hold the whole history; pass [habitCheckIns] (already
/// filtered to this habit) to skip the scan.
BoardEntry buildEntry({
  required ActiveQuest active,
  required List<CheckIn> checkIns,
  List<CheckIn>? habitCheckIns,
  required LogicalDay today,
  required GameRules rules,
  Set<LogicalDay> restDays = const {},
  UpgradeOffer? offer,
}) {
  final history =
      habitCheckIns ??
      checkIns.where((c) => c.habitId == active.habit.id).toList();
  final streak = computeStreak(
    habit: active.habit,
    checkIns: history,
    firstDay: active.habit.firstDay,
    today: today,
    weekStartsOn: rules.weekStartsOn,
    restDays: restDays,
  );
  return BoardEntry(
    active: active,
    today: history.where((c) => c.day == today).firstOrNull,
    streak: streak,
    verdict: assessPromotion(
      habit: active.habit,
      quest: active.quest,
      weeks: tierWeeks(
        active: active,
        history: history,
        today: today,
        rules: rules,
        restDays: restDays,
      ),
      streak: streak,
      rules: rules.promotion,
    ),
    cursed: active.habit.cursedToday(today) && !restDays.contains(today),
    restToday: restDays.contains(today),
    offer: offer,
  );
}

final boardProvider = Provider<AsyncValue<BoardState>>((ref) {
  final quests = ref.watch(activeQuestsProvider);
  final checkIns = ref.watch(recentCheckInsProvider);
  final xp = ref.watch(totalXpProvider);
  final adventurer = ref.watch(adventurerProvider);
  final chapters = ref.watch(chaptersProvider);
  final offers = ref.watch(openOffersProvider);
  final gold = ref.watch(goldProvider).value ?? 0;
  final today = ref.watch(todayProvider);
  final rules = ref.watch(gameRulesProvider);
  final restDays = ref.watch(restDaysProvider).value ?? const <LogicalDay>{};

  for (final v in [quests, checkIns, xp, adventurer, chapters, offers]) {
    if (v.hasError) return AsyncError(v.error!, v.stackTrace!);
  }
  if (!quests.hasValue ||
      !checkIns.hasValue ||
      !xp.hasValue ||
      !adventurer.hasValue ||
      !chapters.hasValue ||
      !offers.hasValue) {
    return const AsyncLoading();
  }

  final byHabit = <int, List<CheckIn>>{};
  for (final c in checkIns.value!) {
    (byHabit[c.habitId] ??= []).add(c);
  }
  final offerByQuest = {for (final o in offers.value!) o.questId: o};
  return AsyncData(
    BoardState(
      today: today,
      entries: applyStacks([
        for (final aq in quests.value!)
          buildEntry(
            active: aq,
            checkIns: const [],
            habitCheckIns: byHabit[aq.habit.id] ?? const [],
            today: today,
            rules: rules,
            restDays: restDays,
            offer: offerByQuest[aq.quest.id],
          ),
      ]),
      level: LevelInfo.fromTotal(xp.value!, rules),
      gold: gold,
      restToday: restDays.contains(today),
      adventurer: adventurer.value,
      latestChapter: chapters.value!.firstOrNull,
    ),
  );
});
