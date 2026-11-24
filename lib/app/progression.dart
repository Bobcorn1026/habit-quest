import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logical_day.dart';
import '../domain/adventurer.dart';
import '../domain/quest_rank.dart';
import '../game/progression.dart';
import 'board.dart';
import 'providers.dart';

/// Stats, class mastery and guild rank, derived from the whole history.
@immutable
class ProgressionState {
  const ProgressionState({
    required this.stats,
    required this.guild,
    required this.perfectDays,
    required this.adventureDays,
    this.mastery,
    this.adventurer,
    required this.rules,
  });

  final StatSheet stats;
  final GuildProgress guild;
  final int perfectDays;

  /// Days since the adventure began (day 1 is the first day).
  final int adventureDays;
  final Mastery? mastery;
  final Adventurer? adventurer;
  final ProgressionRules rules;

  /// Week 2 has begun and no class has been appraised yet.
  bool get classAppraisalOpen =>
      adventurer != null &&
      !adventurer!.hasClass &&
      adventureDays > rules.classAfterDays;

  /// Days until the appraisal opens (0 once open).
  int get daysUntilAppraisal =>
      (rules.classAfterDays + 1 - adventureDays).clamp(0, 999);

  /// A class kept long enough may be changed (mastery starts over).
  bool canChangeClass(LogicalDay today) {
    final c = adventurer?.classInfo;
    return c != null &&
        today.differenceInDays(c.since) >= rules.classChangeCooldownDays;
  }
}

final progressionProvider = Provider<AsyncValue<ProgressionState>>((ref) {
  final board = ref.watch(boardProvider);
  final checkIns = ref.watch(recentCheckInsProvider);
  final index = ref.watch(questIndexProvider);
  final xpByQuest = ref.watch(xpByQuestProvider);
  final rules = ref.watch(gameRulesProvider).progression;
  final restDays = ref.watch(restDaysProvider).value ?? const <LogicalDay>{};

  for (final v in [board, checkIns, index, xpByQuest]) {
    if (v.hasError) return AsyncError(v.error!, v.stackTrace!);
  }
  if (!board.hasValue ||
      !checkIns.hasValue ||
      !index.hasValue ||
      !xpByQuest.hasValue) {
    return const AsyncLoading();
  }

  final state = board.value!;
  final today = state.today;
  final hero = state.adventurer;
  final active = [for (final e in state.entries) e.active];
  final perfect = countPerfectDays(
    active: active,
    checkIns: checkIns.value!,
    today: today,
  );
  final cls = hero?.classInfo;
  final mastery = cls == null
      ? null
      : computeMastery(
          heroClass: cls,
          checkIns: checkIns.value!,
          questIndex: index.value!,
          rules: rules,
        );
  final start = hero == null
      ? today
      : LogicalDay.of(
          hero.createdAt,
          dayStartHour: ref.read(gameRulesProvider).dayStartHour,
        );

  return AsyncData(
    ProgressionState(
      stats: computeStats(
        xpByQuest: xpByQuest.value!,
        questIndex: index.value!,
        perfectDays: perfect,
        heroClass: cls,
        masteryTier: mastery?.tier ?? 0,
        rules: rules,
      ),
      guild: hero == null
          ? const GuildProgress(rank: QuestRank.f, points: 0)
          : computeGuild(
              adventurer: hero,
              active: active,
              checkIns: checkIns.value!,
              questIndex: index.value!,
              today: today,
              rules: rules,
              restDays: restDays,
            ),
      perfectDays: perfect,
      adventureDays: today.differenceInDays(start) + 1,
      mastery: mastery,
      adventurer: hero,
      rules: rules,
    ),
  );
});
