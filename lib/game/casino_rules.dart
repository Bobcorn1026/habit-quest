import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/casino.dart';
import '../domain/check_in.dart';
import '../domain/quest_rank.dart';
import 'bank_rules.dart';
import 'price_level.dart';
import 'progression.dart';

/// Numbers of the casino. A week's prize money comes out of the bank's pool
/// on Monday and is cut into tickets, one-ban-kuji style: once every ticket
/// is drawn, the whole week's money has been won.
@immutable
class CasinoRules {
  const CasinoRules({
    this.releaseMinPercent = 70,
    this.releaseMaxPercent = 130,
    this.unit = 5,
    this.minTickets = 24,
    this.maxTickets = 36,
    this.refundTickets = 4,
    this.targetPercent = 95,
    this.topShare = 20,
    this.highShare = 8,
    this.highCount = (2, 3),
    this.midShare = 4,
    this.midCount = (4, 6),
    this.sweepPercent = 50,
  });

  /// A week's prize money, in percent of the month's average week.
  final int releaseMinPercent;
  final int releaseMaxPercent;

  /// Prizes are multiples of this, unless the week is too small for it.
  final int unit;

  /// How many prize tickets a week has, when its money is enough.
  final int minTickets;
  final int maxTickets;

  /// Free tickets that only refund the draw, on top of the prizes.
  final int refundTickets;

  /// The share of the prize tickets a week where everything is done pays
  /// for.
  final int targetPercent;

  /// Each ticket's share of the week's money (percent) by tier: one top
  /// prize, a few high ones, some middle ones, and low ones for the rest.
  final int topShare;
  final int highShare;
  final (int, int) highCount;
  final int midShare;
  final (int, int) midCount;

  /// What a week leaves undrawn: this share goes to the invest envelope,
  /// the rest stays in the pool.
  final int sweepPercent;
}

/// The Mondays from [week] on that share the money the pool got on the 1st
/// of [week]'s month.
List<LogicalDay> mondaysLeftInMonth(LogicalDay week) => [
  for (var d = week; d.month == week.month; d = d.addDays(7)) d,
];

/// A random share of the month for each of [weeks] weeks, in percent of
/// the average week: each within the rules' bounds, averaging exactly 100.
List<int> releasePlan({
  required int weeks,
  required math.Random rng,
  CasinoRules rules = const CasinoRules(),
}) =>
    mealPlan(
      total: 100 * weeks,
      days: weeks,
      min: rules.releaseMinPercent,
      max: rules.releaseMaxPercent,
      step: 1,
      rng: rng,
    ) ??
    List.filled(weeks, 100);

/// One of the weeks still to come in a month: its share from the
/// [releasePlan] and how many days the casino is open in it.
typedef WeekShare = ({int percent, int days});

/// What a week takes out of the pool's [poolFree]: its part of what the
/// month has left, by the shares of [weeks] (this week first, then the
/// rest of the month's). Money that comes back into the pool during the
/// month is so spread over the weeks still to come.
int weeklyRelease({
  required int poolFree,
  required List<WeekShare> weeks,
  CasinoRules rules = const CasinoRules(),
}) {
  if (poolFree <= 0 || weeks.isEmpty) return 0;
  final weightOf = [for (final w in weeks) math.max(0, w.percent * w.days)];
  final total = weightOf.fold(0, (a, b) => a + b);
  final share = weeks.length == 1 || total == 0
      ? poolFree
      : poolFree * weightOf.first ~/ total;
  final unit = unitFor(share, rules);
  return share ~/ unit * unit;
}

/// The step prizes of a week holding [release] come in.
int unitFor(int release, [CasinoRules rules = const CasinoRules()]) =>
    release >= rules.unit * rules.minTickets ? rules.unit : 1;

/// The price of one draw and how many prize tickets the week has.
typedef PriceAndCount = ({int price, int count});

/// Picks the number of prize tickets and an integer price so that
/// [targetGold] (a week where everything is done) pays for the rules'
/// target share of them, as near as whole coins allow. [release] limits the
/// tickets to one step each.
PriceAndCount priceAndCount({
  required int targetGold,
  required int release,
  CasinoRules rules = const CasinoRules(),
}) {
  final most = release ~/ unitFor(release, rules);
  if (most <= 0) return (price: 0, count: 0);
  final counts = most < rules.minTickets
      ? [most]
      : [
          for (
            var c = rules.minTickets;
            c <= math.min(rules.maxTickets, most);
            c++
          )
            c,
        ];
  final gold = math.max(1, targetGold);
  PriceAndCount? best;
  var bestMiss = double.infinity;
  for (final count in counts) {
    final price = math.max(
      1,
      (gold * 100 / (rules.targetPercent * count)).round(),
    );
    final miss = (gold * 100 / (price * count) - rules.targetPercent).abs();
    // Ties go to more tickets.
    if (miss <= bestMiss + 1e-9) {
      best = (price: price, count: count);
      bestMiss = miss;
    }
  }
  return best!;
}

/// One prize ticket: its tier and money.
typedef Prize = ({PrizeTier tier, int amount});

/// Cuts [total] into [count] prizes of the rules' tiers, best first. Every
/// prize is at least one step ([unitFor]) and the prizes add up to
/// exactly [total], a multiple of that step.
List<Prize> splitPrizes({
  required int total,
  required int count,
  required math.Random rng,
  CasinoRules rules = const CasinoRules(),
}) {
  if (count <= 0 || total <= 0) return const [];
  final unit = unitFor(total, rules);
  final units = total ~/ unit;
  assert(units >= count && units * unit == total);
  int pick((int, int) range) => range.$1 + rng.nextInt(range.$2 - range.$1 + 1);
  final high = math.min(pick(rules.highCount), (count - 1) ~/ 3);
  final mid = math.min(pick(rules.midCount), (count - 1 - high) ~/ 2);
  final low = count - 1 - high - mid;
  final tiers = [
    PrizeTier.top,
    for (var i = 0; i < high; i++) PrizeTier.high,
    for (var i = 0; i < mid; i++) PrizeTier.mid,
    for (var i = 0; i < low; i++) PrizeTier.low,
  ];
  // What the low prizes share, but never more each than a middle one.
  final left =
      100 - rules.topShare - high * rules.highShare - mid * rules.midShare;
  final lowShare = low == 0
      ? 0.0
      : math.min(rules.midShare.toDouble(), math.max(0, left) / low);
  final weights = [
    for (final t in tiers)
      switch (t) {
        PrizeTier.top => rules.topShare.toDouble(),
        PrizeTier.high => rules.highShare.toDouble(),
        PrizeTier.mid => rules.midShare.toDouble(),
        PrizeTier.low => lowShare,
      },
  ];
  final alloc = largestRemainder(units, weights);
  // A ticket that came out empty takes a step from the biggest prize.
  for (var i = 0; i < count; i++) {
    if (alloc[i] > 0) continue;
    var biggest = 0;
    for (var j = 1; j < count; j++) {
      if (alloc[j] > alloc[biggest]) biggest = j;
    }
    alloc[biggest]--;
    alloc[i]++;
  }
  return [
    for (var i = 0; i < count; i++) (tier: tiers[i], amount: alloc[i] * unit),
  ];
}

/// [total] split by [weights] into whole numbers that add up to exactly
/// [total]: everyone gets the floor of their share, and what is left goes
/// one each to the biggest remainders (earlier ones first on a tie).
List<int> largestRemainder(int total, List<double> weights) {
  final sum = weights.fold(0.0, (a, b) => a + b);
  if (weights.isEmpty) return const [];
  if (sum <= 0) {
    return [for (var i = 0; i < weights.length; i++) i == 0 ? total : 0];
  }
  final exact = [for (final w in weights) total * w / sum];
  final out = [for (final e in exact) e.floor()];
  var left = total - out.fold(0, (a, b) => a + b);
  final order = List.generate(weights.length, (i) => i)
    ..sort((a, b) {
      final byRest = (exact[b] - out[b]).compareTo(exact[a] - out[a]);
      return byRest != 0 ? byRest : a.compareTo(b);
    });
  for (var k = 0; left > 0; k = (k + 1) % order.length, left--) {
    out[order[k]]++;
  }
  return out;
}

/// A prize ticket with the envelope it pays into.
typedef DeckPrize = ({PrizeTier tier, int amount, int accountId});

/// Gives each of [prizes] an envelope, by [weights] (envelope id to its
/// share): the top prize to an envelope drawn by weight, then the others,
/// biggest first, each to the envelope furthest below its share. With no
/// weights at all, everything goes to [fallbackAccount].
List<DeckPrize> buildDeck({
  required List<Prize> prizes,
  required Map<int, int> weights,
  required int fallbackAccount,
  required math.Random rng,
}) {
  final shares = {
    for (final e in weights.entries)
      if (e.value > 0) e.key: e.value,
  };
  if (shares.isEmpty) {
    return [
      for (final p in prizes)
        (tier: p.tier, amount: p.amount, accountId: fallbackAccount),
    ];
  }
  final ids = shares.keys.toList()..sort();
  final weightSum = shares.values.fold(0, (a, b) => a + b);
  final total = prizes.fold(0, (a, p) => a + p.amount);
  final got = {for (final id in ids) id: 0};
  double owed(int id) => total * shares[id]! / weightSum - got[id]!;

  final order = List.generate(prizes.length, (i) => i)
    ..sort((a, b) {
      final t = prizes[a].tier.index.compareTo(prizes[b].tier.index);
      return t != 0 ? t : prizes[b].amount.compareTo(prizes[a].amount);
    });
  final account = List.filled(prizes.length, fallbackAccount);
  for (final i in order) {
    final int id;
    if (prizes[i].tier == PrizeTier.top) {
      var roll = rng.nextInt(weightSum);
      id = ids.firstWhere((id) {
        roll -= shares[id]!;
        return roll < 0;
      });
    } else {
      id = ids.reduce((best, id) {
        final byOwed = owed(id).compareTo(owed(best));
        if (byOwed != 0) return byOwed > 0 ? id : best;
        return shares[id]! > shares[best]! ? id : best;
      });
    }
    account[i] = id;
    got[id] = got[id]! + prizes[i].amount;
  }
  return [
    for (var i = 0; i < prizes.length; i++)
      (tier: prizes[i].tier, amount: prizes[i].amount, accountId: account[i]),
  ];
}

/// A commission as the casino's price sees it.
typedef QuestOutlook = ({QuestRank rank, int timesPerWeek, int streakDays});

/// The gold of a week where everything is done (G*): every commission on
/// each of [days] open days (weekly ones as often as they ask), a perfect
/// day each of those days, and the training ground's whole [focusGold].
/// A daily commission's streak grows one day at a time. Side quests and
/// blessings don't count.
int expectedWeeklyGold({
  required List<QuestOutlook> quests,
  required int days,
  required int pricePercent,
  required int focusGold,
  ProgressionRules rules = const ProgressionRules(),
}) {
  if (days <= 0) return focusGold;
  var gold = focusGold;
  for (final q in quests) {
    final daily = q.timesPerWeek >= 7;
    final times = daily ? days : math.min(q.timesPerWeek, days);
    for (var i = 0; i < times; i++) {
      gold += inflate(
        checkInGold(
          rules: rules,
          rank: q.rank,
          outcome: CheckInOutcome.done,
          streakDays: q.streakDays + (daily ? i : 0),
        ),
        pricePercent,
      );
    }
  }
  return gold + days * inflate(rules.goldPerfectDay, pricePercent);
}

/// What a week that ends with [undrawn] money in its deck sends to the
/// invest envelope; the rest stays in the pool for the weeks to come.
int sweepOf(int undrawn, [CasinoRules rules = const CasinoRules()]) =>
    undrawn <= 0 ? 0 : undrawn * rules.sweepPercent ~/ 100;
