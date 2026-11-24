import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/casino_rules.dart';

void main() {
  int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);
  const rules = CasinoRules();

  test('mondaysLeftInMonth stops at the month', () {
    expect(mondaysLeftInMonth(const LogicalDay(2026, 11, 17)), const [
      LogicalDay(2026, 11, 17),
      LogicalDay(2026, 11, 24),
    ]);
    expect(mondaysLeftInMonth(const LogicalDay(2026, 12, 1)), hasLength(5));
    expect(mondaysLeftInMonth(const LogicalDay(2026, 11, 30)), const [
      LogicalDay(2026, 11, 30),
    ]);
  });

  group('releasePlan', () {
    test('averages 100 and stays within 70–130', () {
      for (var seed = 0; seed < 200; seed++) {
        for (var weeks = 1; weeks <= 5; weeks++) {
          final plan = releasePlan(weeks: weeks, rng: math.Random(seed));
          expect(plan, hasLength(weeks));
          expect(sum(plan), 100 * weeks);
          for (final p in plan) {
            expect(p, inInclusiveRange(70, 130));
          }
        }
      }
    });

    test('is not the same every month', () {
      final plans = {
        for (var seed = 0; seed < 20; seed++)
          releasePlan(weeks: 4, rng: math.Random(seed)).join(','),
      };
      expect(plans.length, greaterThan(10));
    });
  });

  group('weeklyRelease', () {
    /// Runs a month: each week takes its release out of the pool, and
    /// [comeBack] is added to the pool after the week it is keyed by.
    List<int> month(
      int pool,
      List<WeekShare> shares, {
      Map<int, int> comeBack = const {},
    }) {
      final out = <int>[];
      for (var k = 0; k < shares.length; k++) {
        final w = weeklyRelease(poolFree: pool, weeks: shares.sublist(k));
        out.add(w);
        pool -= w;
        pool += comeBack[k] ?? 0;
      }
      return out;
    }

    test('hands out the month within the bounds, a step or so off', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final weeks in [1, 4, 5]) {
          for (final pool in [1276, 595, 3000]) {
            final plan = releasePlan(weeks: weeks, rng: math.Random(seed));
            final shares = [for (final p in plan) (percent: p, days: 7)];
            final released = month(pool, shares);
            final leftover = pool - sum(released);
            expect(leftover, inInclusiveRange(0, rules.unit - 1));
            final avg = pool / weeks;
            for (var k = 0; k < weeks; k++) {
              expect(released[k] % unitFor(released[k]), 0);
              expect(
                released[k],
                inInclusiveRange(
                  (0.7 * avg).floor() - rules.unit,
                  (1.3 * avg).ceil() + rules.unit * weeks,
                ),
                reason: 'seed $seed, pool $pool, week $k of $weeks',
              );
              // Each week follows its share of the plan.
              expect(
                (released[k] - avg * plan[k] / 100).abs(),
                lessThanOrEqualTo(rules.unit * weeks),
              );
            }
          }
        }
      }
    });

    test('spreads money that comes back over the weeks left', () {
      const shares = [
        (percent: 100, days: 7),
        (percent: 100, days: 7),
        (percent: 100, days: 7),
        (percent: 100, days: 7),
      ];
      final plain = month(1200, shares);
      expect(plain, [300, 300, 300, 300]);
      final back = month(1200, shares, comeBack: {0: 90});
      expect(back, [300, 330, 330, 330]);
    });

    test('a short first week gets its days\' part', () {
      final w = weeklyRelease(
        poolFree: 1000,
        weeks: const [(percent: 100, days: 3), (percent: 100, days: 7)],
      );
      expect(w, 300);
    });

    test('the last week takes everything, and an empty pool nothing', () {
      expect(
        weeklyRelease(poolFree: 437, weeks: const [(percent: 80, days: 7)]),
        435,
      );
      expect(
        weeklyRelease(poolFree: 37, weeks: const [(percent: 80, days: 7)]),
        37,
      );
      expect(
        weeklyRelease(poolFree: 0, weeks: const [(percent: 100, days: 7)]),
        0,
      );
      expect(
        weeklyRelease(poolFree: -20, weeks: const [(percent: 100, days: 7)]),
        0,
      );
    });
  });

  group('priceAndCount', () {
    test('the F-rank example: about 95% for everything done', () {
      final pc = priceAndCount(targetGold: 167, release: 319);
      expect(pc.count, inInclusiveRange(24, 36));
      expect(167 * 100 / (pc.price * pc.count), closeTo(95, 1));
    });

    test('lands near 95% for any week', () {
      for (var gold = 50; gold <= 5000; gold += 7) {
        final pc = priceAndCount(targetGold: gold, release: 1000);
        expect(pc.count, inInclusiveRange(24, 36));
        expect(pc.price, greaterThanOrEqualTo(1));
        expect(
          gold * 100 / (pc.price * pc.count),
          closeTo(95, 2),
          reason: 'G* $gold → ${pc.price} × ${pc.count}',
        );
      }
    });

    test('a small week has fewer tickets', () {
      expect(priceAndCount(targetGold: 167, release: 10).count, 10);
      expect(
        priceAndCount(targetGold: 167, release: 119).count,
        inInclusiveRange(24, 36),
      );
      // 120 is the first release in steps of 5: 24 tickets at most.
      expect(priceAndCount(targetGold: 167, release: 120).count, 24);
      expect(priceAndCount(targetGold: 167, release: 0).count, 0);
    });
  });

  group('splitPrizes', () {
    test('adds up exactly, in steps, best first, for any week', () {
      for (var total = 1; total <= 2000; total += total < 200 ? 1 : 5) {
        final count = priceAndCount(targetGold: 167, release: total).count;
        final unit = unitFor(total);
        final total0 = total ~/ unit * unit;
        if (total0 != total) continue; // not a release weeklyRelease gives
        final prizes = splitPrizes(
          total: total,
          count: count,
          rng: math.Random(total),
        );
        expect(prizes, hasLength(count));
        expect(sum(prizes.map((p) => p.amount)), total, reason: 'W $total');
        for (var i = 0; i < prizes.length; i++) {
          expect(prizes[i].amount % unit, 0);
          expect(prizes[i].amount, greaterThanOrEqualTo(unit));
          if (i > 0) {
            expect(
              prizes[i].tier.index,
              greaterThanOrEqualTo(prizes[i - 1].tier.index),
            );
            // A worse tier never pays more than a step over a better one.
            if (prizes[i].tier != prizes[i - 1].tier) {
              expect(
                prizes[i].amount,
                lessThanOrEqualTo(prizes[i - 1].amount + unit),
              );
            }
          }
        }
        expect(prizes.where((p) => p.tier == PrizeTier.top), hasLength(1));
      }
    });

    test('a typical week: top about 20%, a few at 8% and 4%', () {
      final prizes = splitPrizes(total: 320, count: 29, rng: math.Random(1));
      final top = prizes.first;
      expect(top.tier, PrizeTier.top);
      expect(top.amount, closeTo(64, 5));
      final high = prizes.where((p) => p.tier == PrizeTier.high).toList();
      expect(high.length, inInclusiveRange(2, 3));
      for (final p in high) {
        expect(p.amount, closeTo(25.6, 5));
      }
      final mid = prizes.where((p) => p.tier == PrizeTier.mid).toList();
      expect(mid.length, inInclusiveRange(4, 6));
      for (final p in mid) {
        expect(p.amount, closeTo(12.8, 5));
      }
    });

    test('nothing to split', () {
      expect(splitPrizes(total: 0, count: 0, rng: math.Random(1)), isEmpty);
    });
  });

  group('buildDeck', () {
    const weights = {1: 30, 3: 15, 4: 15, 5: 10, 6: 10, 7: 10, 8: 10, 9: 0};

    test('each envelope gets its share, give or take the top prize', () {
      for (var seed = 0; seed < 100; seed++) {
        final rng = math.Random(seed);
        final prizes = splitPrizes(total: 320, count: 29, rng: rng);
        final deck = buildDeck(
          prizes: prizes,
          weights: weights,
          fallbackAccount: 1,
          rng: rng,
        );
        expect(deck, hasLength(prizes.length));
        final byAccount = <int, int>{};
        for (final d in deck) {
          byAccount[d.accountId] = (byAccount[d.accountId] ?? 0) + d.amount;
        }
        expect(byAccount.containsKey(9), isFalse);
        expect(sum(byAccount.values), 320);
        for (final e in weights.entries.where((e) => e.value > 0)) {
          final target = 320 * e.value / 100;
          expect(
            ((byAccount[e.key] ?? 0) - target).abs(),
            lessThanOrEqualTo(prizes.first.amount),
            reason: 'seed $seed, account ${e.key}',
          );
        }
      }
    });

    test('the top prize goes where the weights say', () {
      final topTo = <int, int>{};
      for (var seed = 0; seed < 2000; seed++) {
        final rng = math.Random(seed);
        final deck = buildDeck(
          prizes: splitPrizes(total: 320, count: 29, rng: rng),
          weights: weights,
          fallbackAccount: 1,
          rng: rng,
        );
        final top = deck.firstWhere((d) => d.tier == PrizeTier.top);
        topTo[top.accountId] = (topTo[top.accountId] ?? 0) + 1;
      }
      expect(topTo[1]! / 2000, closeTo(0.30, 0.05));
      expect(topTo[5]! / 2000, closeTo(0.10, 0.04));
      expect(topTo.containsKey(9), isFalse);
    });

    test('with no weights, all to the fallback', () {
      final deck = buildDeck(
        prizes: splitPrizes(total: 320, count: 29, rng: math.Random(1)),
        weights: const {2: 0, 9: 0},
        fallbackAccount: 1,
        rng: math.Random(1),
      );
      expect(deck.every((d) => d.accountId == 1), isTrue);
    });
  });

  group('expectedWeeklyGold', () {
    test('F rank, two daily commissions, no streak: the plan\'s 167', () {
      final gold = expectedWeeklyGold(
        quests: const [
          (rank: QuestRank.f, timesPerWeek: 7, streakDays: 0),
          (rank: QuestRank.f, timesPerWeek: 7, streakDays: 0),
        ],
        days: 7,
        pricePercent: 100,
        focusGold: 83,
      );
      expect(gold, 14 + 70 + 83);
    });

    test('streaks grow through the week; weekly quests count their times', () {
      final gold = expectedWeeklyGold(
        quests: const [
          // 1 gold, +1 from day 7 of the streak: days 5..11 → 2 at 7..11.
          (rank: QuestRank.f, timesPerWeek: 7, streakDays: 5),
          // 2 gold three times, streak of 2 weeks: +2 each.
          (rank: QuestRank.d, timesPerWeek: 3, streakDays: 14),
        ],
        days: 7,
        pricePercent: 100,
        focusGold: 0,
      );
      expect(gold, (1 + 1 + 2 * 5) + 3 * 4 + 70);
    });

    test('inflates each payment, and a short week counts its days', () {
      final gold = expectedWeeklyGold(
        quests: const [
          (rank: QuestRank.f, timesPerWeek: 7, streakDays: 0),
          (rank: QuestRank.f, timesPerWeek: 5, streakDays: 0),
        ],
        days: 3,
        pricePercent: 150,
        focusGold: 125,
      );
      // 1 gold at ×1.5 rounds to 2; the perfect day 10 → 15.
      expect(gold, 3 * 2 + 3 * 2 + 3 * 15 + 125);
    });
  });

  test('sweepOf sends half of what is left to the invest envelope', () {
    expect(sweepOf(101), 50);
    expect(sweepOf(0), 0);
  });
}
