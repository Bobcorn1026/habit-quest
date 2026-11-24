import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/game/habit_stats.dart';
import 'package:habit_quest/game/judgement.dart';
import 'package:habit_quest/game/period.dart';
import 'package:habit_quest/game/promotion.dart';
import 'package:habit_quest/game/streak.dart';

import '../support/builders.dart';

void main() {
  const rules = GameRules();
  final habit = buildHabit();
  final week0 = Period(monday, 7);

  HabitPeriodStats stats(
    Period p,
    List<CheckIn> checkIns, {
    Habit? h,
    LogicalDay? asOf,
    double? target = 20,
  }) => computePeriodStats(
    habit: h ?? habit,
    target: target,
    period: p,
    checkIns: checkIns,
    firstDay: monday,
    asOf: asOf ?? p.last,
  );

  group('period stats', () {
    test('full week of done is complete', () {
      final s = stats(week0, daily(monday, 7, amount: 20));
      expect(s.scheduled, 7);
      expect(s.completion, 1);
      expect(s.averageAmount, 20);
    });

    test('partial check-ins count by fraction of target', () {
      final s = stats(week0, [
        ...daily(monday, 6, amount: 20),
        checkIn(monday.addDays(6), outcome: CheckInOutcome.partial, amount: 10),
      ]);
      expect(s.completion, closeTo(6.5 / 7, 1e-9));
    });

    test('only days up to asOf are scheduled', () {
      final s = stats(
        week0,
        daily(monday, 3, amount: 20),
        asOf: monday.addDays(2),
      );
      expect(s.scheduled, 3);
      expect(s.completion, 1);
    });

    test('weekly quota habits are scheduled by quota', () {
      final gym = buildHabit(timesPerWeek: 3);
      final s = stats(week0, daily(monday, 3), h: gym);
      expect(s.scheduled, 3);
      expect(s.completion, 1);
    });

    test('every weekly count schedules exactly that many check-ins', () {
      for (var times = 1; times <= 6; times++) {
        final h = buildHabit(timesPerWeek: times);
        final full = stats(week0, daily(monday, times), h: h);
        expect(full.scheduled, times, reason: '$times a week');
        expect(full.completion, 1);
        final half = stats(week0, daily(monday, times - 1), h: h);
        expect(half.completion, closeTo((times - 1) / times, 1e-9));
      }
    });

    test('notes are collected for the story', () {
      final s = stats(week0, [checkIn(monday, amount: 20, note: '看完一篇新聞')]);
      expect(s.notes, ['看完一篇新聞']);
    });
  });

  group('judgement', () {
    test('score maps to TRPG verdicts', () {
      expect(judge(0.95, rules.judgement), Judgement.triumph);
      expect(judge(0.75, rules.judgement), Judgement.success);
      expect(judge(0.5, rules.judgement), Judgement.struggle);
      expect(judge(0.1, rules.judgement), Judgement.setback);
    });

    test('unscheduled habits do not drag the score down', () {
      final a = stats(week0, daily(monday, 7, amount: 20));
      final b = HabitPeriodStats(
        habitId: 2,
        period: week0,
        scheduled: 0,
        completion: 0,
      );
      expect(performanceScore([a, b]), 1);
      expect(performanceScore([]), 0);
    });
  });

  group('promotion', () {
    final quest = buildQuest();

    List<HabitPeriodStats> weeks(int count, {double amount = 20}) => [
      for (var w = 0; w < count; w++)
        stats(
          Period(monday.addDays(7 * w), 7),
          daily(monday.addDays(7 * w), 7, amount: amount),
        ),
    ];

    PromotionVerdict assess(
      List<HabitPeriodStats> w, {
      Habit? h,
      StreakState streak = const StreakState(),
    }) => assessPromotion(
      habit: h ?? habit,
      quest: quest,
      weeks: w,
      streak: streak,
      rules: rules.promotion,
    );

    test('doing exactly the target is never flagged', () {
      final v = assess(weeks(9));
      expect(v.offersUpgrade, isFalse);
    });

    test('consistently beating the target invites an upgrade', () {
      expect(assess(weeks(3, amount: 40)).surpassed, isTrue);
      expect(assess(weeks(2, amount: 40)).surpassed, isFalse);
    });

    test('one ordinary week resets the surpass run', () {
      final w = weeks(4, amount: 40);
      w[3] = stats(
        Period(monday.addDays(21), 7),
        daily(monday.addDays(21), 7, amount: 20),
      );
      expect(assess(w).surpassed, isFalse);
    });

    test('yes/no habits have nothing to surpass', () {
      final yesNo = buildHabit(target: null, unit: null);
      final v = assessPromotion(
        habit: yesNo,
        quest: buildQuest(target: null),
        weeks: const [],
        streak: const StreakState(),
        rules: rules.promotion,
      );
      expect(v.offersUpgrade, isFalse);
    });

    test('seals are mastered after 30 crack-free days', () {
      final seal = buildHabit(kind: HabitKind.quit);
      expect(
        assess(
          [],
          h: seal,
          streak: const StreakState(length: 40, clean: 29),
        ).sealMastered,
        isFalse,
        reason: 'a recent crack resets the clean run',
      );
      expect(
        assess(
          [],
          h: seal,
          streak: const StreakState(length: 30, clean: 30),
        ).sealMastered,
        isTrue,
      );
    });

    test('upgrade targets grow within bounds and stay whole', () {
      const r = PromotionRules();
      expect(suggestedUpgradeTarget(20, r), 25);
      expect(suggestedUpgradeTarget(1, r), 2);
      expect(suggestedUpgradeTarget(2.5, r), 3.1);
    });
  });
}
