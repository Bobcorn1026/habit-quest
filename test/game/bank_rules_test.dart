import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/bank.dart';
import 'package:habit_quest/game/bank_rules.dart';

void main() {
  int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);

  group('mealPlan', () {
    test('adds up exactly, within bounds, in steps, for any month', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final days in [1, 2, 14, 28, 29, 30, 31]) {
          final rng = math.Random(seed);
          final total = days == 1 ? 200 : 5000 * days ~/ 30 ~/ 10 * 10;
          final plan = mealPlan(
            total: total,
            days: days,
            min: 120,
            max: 220,
            step: 10,
            rng: rng,
          );
          expect(plan, isNotNull, reason: 'seed $seed, $days days');
          expect(plan, hasLength(days));
          expect(sum(plan!), total);
          for (final amount in plan) {
            expect(amount % 10, 0);
            expect(amount, inInclusiveRange(120, 220));
          }
        }
      }
    });

    test('is not the same every month', () {
      List<int> plan(int seed) => mealPlan(
        total: 5000,
        days: 30,
        min: 120,
        max: 220,
        step: 10,
        rng: math.Random(seed),
      )!;
      expect(plan(1), isNot(plan(2)));
      expect(plan(1).toSet().length, greaterThan(3));
    });

    test('spreads the forced days over the month', () {
      // Without the shuffle the bounds would pile up at the end.
      var lastIsBound = 0;
      for (var seed = 0; seed < 200; seed++) {
        final plan = mealPlan(
          total: 6400,
          days: 30,
          min: 120,
          max: 220,
          step: 10,
          rng: math.Random(seed),
        )!;
        if (plan.last == 220) lastIsBound++;
      }
      expect(lastIsBound, lessThan(200));
    });

    test('is null when the bounds or steps make it impossible', () {
      final rng = math.Random(0);
      List<int>? plan(int total, int days, {int min = 120, int max = 220}) =>
          mealPlan(
            total: total,
            days: days,
            min: min,
            max: max,
            step: 10,
            rng: rng,
          );
      expect(plan(8000, 31), isNull, reason: 'over 31 × 220');
      expect(plan(3000, 28), isNull, reason: 'under 28 × 120');
      expect(plan(5005, 30), isNull, reason: 'not in steps of 10');
      expect(plan(5000, 0), isNull);
      expect(plan(5000, 30, min: 230, max: 220), isNull);
      expect(plan(6600, 30), hasLength(30), reason: 'exactly 30 × 220');
    });
  });

  test('evenSplit hands out the remainder one by one', () {
    expect(evenSplit(8000, 31), hasLength(31));
    expect(sum(evenSplit(8000, 31)), 8000);
    expect(evenSplit(10, 3), [4, 3, 3]);
    expect(evenSplit(10, 0), isEmpty);
  });

  test('transferFee: free from general, banned from meal, 10% rounded up', () {
    int? fee(int amount, AccountRole? role) =>
        transferFee(amount: amount, fromRole: role);
    expect(fee(100, null), 10);
    expect(fee(101, null), 11);
    expect(fee(1, null), 1);
    expect(fee(95, AccountRole.invest), 10);
    expect(fee(100, AccountRole.general), 0);
    expect(fee(100, AccountRole.meal), isNull);
    expect(fee(100, AccountRole.central), isNull);
    expect(fee(100, AccountRole.pool), isNull);
  });

  test('prorate rounds to the nearest step', () {
    expect(prorate(5000, daysLeft: 14, daysInMonth: 30, step: 10), 2330);
    expect(prorate(3900, daysLeft: 14, daysInMonth: 30), 1820);
    expect(prorate(300, daysLeft: 14, daysInMonth: 30), 140);
    expect(prorate(5000, daysLeft: 1, daysInMonth: 31, step: 10), 160);
    expect(prorate(100, daysLeft: 1, daysInMonth: 2), 50);
    expect(prorate(5000, daysLeft: 30, daysInMonth: 30, step: 10), 5000);
    expect(prorate(5000, daysLeft: 0, daysInMonth: 30, step: 10), 0);
  });

  test('month helpers', () {
    expect(monthKeyOf(const LogicalDay(2026, 11, 17)), '2026-11');
    expect(
      nextMonthStart(const LogicalDay(2026, 12, 31)),
      const LogicalDay(2027, 1, 1),
    );
    expect(daysInMonthOf(const LogicalDay(2028, 2, 3)), 29);
    expect(daysInMonthOf(const LogicalDay(2026, 2, 3)), 28);
    expect(
      monthStartOf(const LogicalDay(2026, 11, 17)),
      const LogicalDay(2026, 11, 1),
    );
  });

  test('the default config leaves 3,900 a month for the pool', () {
    expect(const BankConfig().refill, 3900);
    expect(
      const BankConfig(income: 100, meal: 6000).refill,
      0,
      reason: 'never negative',
    );
  });

  test('BankConfig survives JSON, and bad JSON falls back', () {
    final config = const BankConfig().copyWith(
      income: 9000,
      fixed: [const FixedCost(id: 'x', name: 'X', amount: 1, reserve: true)],
    );
    expect(BankConfig.fromJson(config.toJson()), config);
    expect(BankConfig.fromJson(null), const BankConfig());
    expect(BankConfig.fromJson({'income': -5}).income, 10000);
  });

  group('openMonth', () {
    const config = BankConfig();

    test('a full month: income, charges, reserves, pool, 5,000 of meals', () {
      final open = openMonth(
        config: config,
        firstDay: const LogicalDay(2026, 12, 1),
        first: false,
        rng: math.Random(3),
      );
      expect(open.income, 10000);
      expect(open.charges, {'gym': 800});
      expect(open.reserves, {'subscription': 300});
      expect(open.refill, 3900);
      expect(open.mealPlan, hasLength(31));
      expect(sum(open.mealPlan), 5000);
    });

    test('the month the bank opens: only the days left, nothing charged', () {
      final open = openMonth(
        config: config,
        firstDay: const LogicalDay(2026, 11, 17),
        first: true,
        rng: math.Random(3),
      );
      expect(open.income, 0);
      expect(open.charges, isEmpty);
      expect(open.reserves, {'subscription': 140});
      expect(open.refill, 1820);
      expect(open.mealPlan, hasLength(14));
      expect(sum(open.mealPlan), 2330);
    });

    test('opened on the 1st, the first month is whole but still uncharged', () {
      final open = openMonth(
        config: config,
        firstDay: const LogicalDay(2026, 12, 1),
        first: true,
        rng: math.Random(3),
      );
      expect(open.income, 0);
      expect(open.charges, isEmpty);
      expect(open.refill, 3900);
      expect(sum(open.mealPlan), 5000);
    });

    test('impossible bounds fall back to an even split', () {
      final open = openMonth(
        config: config.copyWith(meal: 9000),
        firstDay: const LogicalDay(2026, 12, 1),
        first: false,
        rng: math.Random(3),
      );
      expect(open.mealPlan, hasLength(31));
      expect(sum(open.mealPlan), 9000);
      expect(open.mealPlan.toSet(), {290, 291});
    });
  });

  test('closeMeal: leftovers to the pool, overdraft from pool then vault', () {
    var close = closeMeal(mealBalance: 120, poolFree: 0);
    expect((close.toPool, close.fromPool, close.fromVault), (120, 0, 0));
    close = closeMeal(mealBalance: -300, poolFree: 1000);
    expect((close.toPool, close.fromPool, close.fromVault), (0, 300, 0));
    close = closeMeal(mealBalance: -300, poolFree: 100);
    expect((close.toPool, close.fromPool, close.fromVault), (0, 100, 200));
    close = closeMeal(mealBalance: -300, poolFree: -50);
    expect((close.toPool, close.fromPool, close.fromVault), (0, 0, 300));
  });
}
