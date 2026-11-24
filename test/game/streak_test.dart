import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/game/streak.dart';

import '../support/builders.dart';

void main() {
  final habit = buildHabit();

  StreakState streak(List<CheckIn> checkIns, int todayOffset, {Habit? h}) =>
      computeStreak(
        habit: h ?? habit,
        checkIns: checkIns,
        firstDay: monday,
        today: monday.addDays(todayOffset),
      );

  test('counts consecutive days including today once done', () {
    final s = streak(daily(monday, 5), 4);
    expect(s.length, 5);
    expect(s.clean, 5);
    expect(s.wounded, isFalse);
  });

  test('today not yet done is neither a hit nor a miss', () {
    final s = streak(daily(monday, 4), 4);
    expect(s.length, 4);
    expect(s.wounded, isFalse);
    expect(s.broken, isFalse);
  });

  test('one missed day only wounds the streak (never miss twice)', () {
    final checkIns = [...daily(monday, 3), checkIn(monday.addDays(4))];
    // Day 3 missed, day 4 done: run continues with 4 hits, but only the
    // last one is spotless.
    expect(streak(checkIns, 4).length, 4);
    expect(streak(checkIns, 4).clean, 1);

    // Day 4 is today and not done yet: wounded.
    final wounded = streak(daily(monday, 3), 4);
    expect(wounded.length, 3);
    expect(wounded.wounded, isTrue);
  });

  test('two missed days in a row break the streak', () {
    final checkIns = [...daily(monday, 3), checkIn(monday.addDays(5))];
    final s = streak(checkIns, 5);
    expect(s.length, 1);

    final broken = streak(daily(monday, 3), 5);
    expect(broken.length, 0);
    expect(broken.broken, isTrue);
  });

  test('a relapse counts as a miss for seals', () {
    final seal = buildHabit(kind: HabitKind.quit);
    final checkIns = [
      ...daily(monday, 3, outcome: CheckInOutcome.resisted),
      checkIn(monday.addDays(3), outcome: CheckInOutcome.relapsed),
    ];
    final s = streak(checkIns, 3, h: seal);
    expect(s.length, 3);
    expect(s.wounded, isFalse, reason: 'today is the relapse, still open');

    final next = streak(checkIns, 4, h: seal);
    expect(next.wounded, isTrue);
  });

  test('weekly-quota habits count weeks', () {
    final gym = buildHabit(timesPerWeek: 3);
    final checkIns = [
      for (final w in [0, 7, 14])
        for (final d in [0, 2, 4]) checkIn(monday.addDays(w + d)),
    ];
    final s = streak(checkIns, 16, h: gym);
    expect(s.slotDays, 7);
    expect(s.length, 3);
    expect(s.days, 21);
  });

  test('every weekly count from 1 to 6 needs exactly that many hits', () {
    for (var times = 1; times <= 6; times++) {
      final h = buildHabit(timesPerWeek: times);
      List<CheckIn> hits(int week, int n) => [
        for (var d = 0; d < n; d++) checkIn(monday.addDays(week * 7 + d)),
      ];
      // Two full weeks at the quota: both weeks count.
      final met = streak([...hits(0, times), ...hits(1, times)], 13, h: h);
      expect(met.length, 2, reason: '$times a week, quota met');
      expect(met.slotDays, 7);

      // One hit short in the running week: it is not met yet, but it is
      // not a miss either, so the earlier week still counts.
      final short = streak(
        [...hits(0, times), ...hits(1, times - 1)],
        13,
        h: h,
      );
      expect(short.length, 1, reason: '$times a week, one short');
      expect(short.wounded, isFalse);

      // A finished week one short wounds the streak instead.
      final missed = streak(
        [...hits(0, times), ...hits(1, times - 1), ...hits(2, times)],
        20,
        h: h,
      );
      expect(missed.length, 2, reason: 'one short week only wounds');
      expect(missed.clean, 1);
    }
  });
}
