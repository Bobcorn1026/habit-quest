import 'package:flutter_test/flutter_test.dart';
import "package:habit_quest/core/logical_day.dart";
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/adventurer.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/habit_stats.dart';
import 'package:habit_quest/game/period.dart';
import 'package:habit_quest/game/progression.dart';
import 'package:habit_quest/game/streak.dart';

import '../support/builders.dart';

void main() {
  final habit = buildHabit();
  final day = monday.addDays;

  StreakState streak(
    List<CheckIn> checkIns,
    int todayOffset, {
    Set<int> rest = const {},
    Habit? h,
  }) => computeStreak(
    habit: h ?? habit,
    checkIns: checkIns,
    firstDay: monday,
    today: day(todayOffset),
    restDays: {for (final r in rest) day(r)},
  );

  group('streak and injury', () {
    test('an unreported rest day neither counts nor wounds', () {
      final c = daily(monday, 3); // days 0-2 done, day 3 rests, day 4 open
      expect(streak(c, 4).wounded, isTrue, reason: 'control: no rest day');
      final s = streak(c, 4, rest: {3});
      expect(s.wounded, isFalse);
      expect(s.length, 3);
      expect(s.clean, 3);
    });

    test('resting today is never wounded or broken', () {
      final c = daily(monday, 2); // day 2 missed, day 3 is a rest day
      expect(streak(c, 3).wounded, isTrue, reason: 'control');
      final s = streak(c, 3, rest: {3});
      expect(s.wounded, isFalse);
      expect(s.broken, isFalse);
      expect(s.length, 2);
    });

    test('a rest day between two hits does not break the run', () {
      final c = [...daily(monday, 3), checkIn(day(4))];
      final s = streak(c, 4, rest: {3});
      expect(s.length, 4);
      expect(s.clean, 4);
      expect(streak(c, 4).clean, 1, reason: 'control: a miss without rest');
    });

    test('looks past the rest day to the previous working day', () {
      // day 1 missed, day 2 rests, today day 3 open: one miss only.
      final c = [checkIn(monday)];
      final s = streak(c, 3, rest: {2});
      expect(s.wounded, isTrue);
      expect(s.broken, isFalse);
      expect(streak(c, 3).broken, isTrue, reason: 'control: two misses');
    });

    test('a check-in on a rest day counts normally', () {
      final c = [...daily(monday, 3), checkIn(day(3))];
      final s = streak(c, 3, rest: {3});
      expect(s.length, 4);
    });

    test('works for seals too', () {
      final seal = buildHabit(kind: HabitKind.quit);
      final c = daily(monday, 3, outcome: CheckInOutcome.resisted);
      final s = streak(c, 4, rest: {3}, h: seal);
      expect(s.wounded, isFalse);
      expect(s.length, 3);
    });
  });

  group('period stats', () {
    HabitPeriodStats stats(
      List<CheckIn> c, {
      Set<int> rest = const {},
      Habit? h,
    }) => computePeriodStats(
      habit: h ?? habit,
      target: 20,
      period: Period(monday, 7),
      checkIns: c,
      firstDay: monday,
      asOf: day(6),
      restDays: {for (final r in rest) day(r)},
    );

    test('unreported rest days leave the denominator', () {
      final c = daily(monday, 5);
      expect(stats(c).completion, closeTo(5 / 7, 1e-9));
      final s = stats(c, rest: {5, 6});
      expect(s.scheduled, 5);
      expect(s.completion, 1);
    });

    test('a reported rest day still counts', () {
      final s = stats(daily(monday, 6), rest: {5});
      expect(s.scheduled, 7);
    });

    test('weekly targets are unchanged', () {
      final gym = buildHabit(timesPerWeek: 3);
      expect(stats(const [], rest: {5, 6}, h: gym).scheduled, 3);
    });
  });

  group('guild trial', () {
    final reading = ActiveQuest(buildHabit(), buildQuest());
    final index = <int, QuestInfo>{
      10: (attribute: Stat.intel, rank: QuestRank.c),
    };
    final hero = Adventurer(
      id: 1,
      name: '亞倫',
      guildRank: QuestRank.e,
      trialStart: monday,
      createdAt: DateTime(2026, 11, 2),
    );

    GuildProgress guild(List<CheckIn> c, int today, Set<int> rest) =>
        computeGuild(
          adventurer: hero,
          active: [reading],
          checkIns: c,
          questIndex: index,
          today: day(today),
          rules: const ProgressionRules(),
          restDays: {for (final r in rest) day(r)},
        );

    test('an imperfect rest day pauses the trial', () {
      // Rank D asks for 2 perfect days; day 1 is a rest day with nothing.
      final c = [checkIn(monday), checkIn(day(2))];
      expect(guild(c, 3, {}).state, TrialState.failed, reason: 'control');
      final g = guild(c, 3, {1});
      expect(g.state, TrialState.passed);
      expect(g.trialDaysDone, 2);
    });

    test('a rest day does not count toward the days needed', () {
      final g = guild([checkIn(monday)], 3, {1, 2});
      expect(g.state, TrialState.running);
      expect(g.trialDaysDone, 1);
    });
  });

  group('perfect day', () {
    test('a rest day is perfect only if everything was done', () {
      final reading = ActiveQuest(buildHabit(), buildQuest());
      expect(isPerfectDay(monday, [reading], const {}), isFalse);
      expect(
        isPerfectDay(monday, [reading], indexCheckIns([checkIn(monday)])),
        isTrue,
      );
    });
  });

  group('reminders', () {
    test('nothing is scheduled on rest days', () {
      final now = DateTime(2026, 11, 9, 10);
      final plan = planReminders(
        settings: const ReminderSettings(enabled: true, hour: 21),
        now: now,
        dayStartHour: 4,
        pendingToday: 2,
        restDays: {const LogicalDay(2026, 11, 11)},
      );
      expect(plan, hasLength(29));
      expect(plan.any((r) => r.when.day == 11 && r.when.month == 11), isFalse);
    });
  });
}
