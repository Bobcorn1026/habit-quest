import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/bank.dart';

/// Numbers of the bank that are not the player's to set (those are
/// `BankConfig`).
@immutable
class BankRules {
  const BankRules({this.mealStep = 10, this.transferFeePercent = 10});

  /// A day's meal money is a multiple of this.
  final int mealStep;

  /// Moving money between envelopes costs this share, rounded up; it goes
  /// to the casino's pool. Free out of the everyday envelope.
  final int transferFeePercent;
}

/// `yyyy-MM` of the month [day] is in.
String monthKeyOf(LogicalDay day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}';

/// The first day of the month [day] is in.
LogicalDay monthStartOf(LogicalDay day) => LogicalDay(day.year, day.month, 1);

/// The first day of the month after the one [day] is in.
LogicalDay nextMonthStart(LogicalDay day) {
  final d = DateTime.utc(day.year, day.month + 1);
  return LogicalDay(d.year, d.month, 1);
}

int daysInMonthOf(LogicalDay day) =>
    DateTime.utc(day.year, day.month + 1, 0).day;

/// [monthly] for the part of a month from [daysLeft] of its [daysInMonth]
/// days on, rounded to the nearest [step] (halves go up).
int prorate(
  int monthly, {
  required int daysLeft,
  required int daysInMonth,
  int step = 1,
}) {
  assert(monthly >= 0 && daysLeft >= 0 && daysInMonth > 0 && step > 0);
  final num = monthly * daysLeft;
  final den = daysInMonth * step;
  return (2 * num + den) ~/ (2 * den) * step;
}

/// [total] in [days] amounts, each a multiple of [step] between [min] and
/// [max], in random order. Null when no such split exists.
///
/// Each day draws uniformly from what still leaves the rest a way to add
/// up; the order is shuffled afterwards so the forced last days don't
/// always come at the end of the month.
List<int>? mealPlan({
  required int total,
  required int days,
  required int min,
  required int max,
  required int step,
  required math.Random rng,
}) {
  if (days <= 0 || step <= 0 || total % step != 0) return null;
  final lo = (min + step - 1) ~/ step;
  final hi = max ~/ step;
  var left = total ~/ step;
  if (lo > hi || left < lo * days || left > hi * days) return null;
  final plan = <int>[];
  for (var k = days; k > 0; k--) {
    final from = math.max(lo, left - (k - 1) * hi);
    final to = math.min(hi, left - (k - 1) * lo);
    final units = from + rng.nextInt(to - from + 1);
    plan.add(units * step);
    left -= units;
  }
  return plan..shuffle(rng);
}

/// [total] in [days] amounts as equal as can be, the bigger ones first.
/// What the bank falls back on when the bounds make [mealPlan] impossible.
List<int> evenSplit(int total, int days) {
  if (days <= 0) return const [];
  final base = total ~/ days;
  final extra = total - base * days;
  return [for (var i = 0; i < days; i++) base + (i < extra ? 1 : 0)];
}

/// The fee for moving [amount] out of an envelope with [fromRole]; null
/// when that envelope can't be moved out of.
int? transferFee({
  required int amount,
  required AccountRole? fromRole,
  BankRules rules = const BankRules(),
}) {
  assert(amount > 0);
  return switch (fromRole) {
    AccountRole.general => 0,
    AccountRole.meal || AccountRole.central || AccountRole.pool => null,
    _ => (amount * rules.transferFeePercent + 99) ~/ 100,
  };
}

/// What a month starts with.
@immutable
class MonthOpening {
  const MonthOpening({
    required this.income,
    required this.charges,
    required this.reserves,
    required this.refill,
    required this.mealPlan,
  });

  /// Into the vault.
  final int income;

  /// Fixed costs charged to the vault, by id.
  final Map<String, int> charges;

  /// Fixed costs set aside in the vault, by id.
  final Map<String, int> reserves;

  /// From the vault to the casino's pool.
  final int refill;

  /// Meal money of each day from the month's first day on.
  final List<int> mealPlan;
}

/// Opens the month that runs from [firstDay] to its end on [config].
///
/// The month the bank opens in ([first]) starts from the balance the player
/// typed, which already holds that month's income and charges: only what
/// is handed out over the month (meals, the pool, what is set aside) is
/// counted, and only for the days left.
MonthOpening openMonth({
  required BankConfig config,
  required LogicalDay firstDay,
  required bool first,
  required math.Random rng,
  BankRules rules = const BankRules(),
}) {
  final daysInMonth = daysInMonthOf(firstDay);
  final daysLeft = daysInMonth - firstDay.day + 1;
  int part(int monthly, {int step = 1}) => first
      ? prorate(
          monthly,
          daysLeft: daysLeft,
          daysInMonth: daysInMonth,
          step: step,
        )
      : monthly;
  final meal = part(config.meal, step: rules.mealStep);
  return MonthOpening(
    income: first ? 0 : config.income,
    charges: {
      for (final f in config.fixed)
        if (!f.reserve && !first && f.amount > 0) f.id: f.amount,
    },
    reserves: {
      for (final f in config.fixed)
        if (f.reserve && f.amount > 0) f.id: part(f.amount),
    },
    refill: part(config.refill),
    mealPlan:
        mealPlan(
          total: meal,
          days: daysLeft,
          min: config.mealMin,
          max: config.mealMax,
          step: rules.mealStep,
          rng: rng,
        ) ??
        evenSplit(meal, daysLeft),
  );
}

/// How the meal envelope goes back to zero when its month ends.
@immutable
class MealClose {
  const MealClose({this.toPool = 0, this.fromPool = 0, this.fromVault = 0});

  /// What was left over, into the casino's pool.
  final int toPool;

  /// An overdraft paid by the pool's free money first…
  final int fromPool;

  /// …and by the vault for the rest.
  final int fromVault;
}

/// Empties the meal envelope holding [mealBalance] once the month's meals
/// are all handed out. [poolFree] is what the pool has that no casino
/// ticket is waiting for.
MealClose closeMeal({required int mealBalance, required int poolFree}) {
  if (mealBalance >= 0) return MealClose(toPool: mealBalance);
  final owed = -mealBalance;
  final fromPool = math.min(owed, math.max(0, poolFree));
  return MealClose(fromPool: fromPool, fromVault: owed - fromPool);
}
