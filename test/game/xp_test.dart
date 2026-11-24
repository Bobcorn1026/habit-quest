import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/game/xp.dart';

void main() {
  const rules = GameRules();

  int xp({
    QuestRank rank = QuestRank.c,
    CheckInOutcome outcome = CheckInOutcome.done,
    double? amount = 20,
    double? target = 20,
    int streakDays = 1,
    double multiplier = 1,
  }) => checkInXp(
    rules: rules,
    rank: rank,
    outcome: outcome,
    amount: amount,
    target: target,
    streakDays: streakDays,
    multiplier: multiplier,
  );

  test('base XP depends on rank', () {
    expect(xp(rank: QuestRank.f), 5);
    expect(xp(rank: QuestRank.c), 18);
    expect(xp(rank: QuestRank.s), 50);
  });

  test('amount scales XP, capped at 1.5×', () {
    expect(xp(amount: 10, outcome: CheckInOutcome.partial), 9);
    expect(xp(amount: 30), 27);
    expect(xp(amount: 200), 27);
  });

  test('yes/no habits ignore amount; unmeasured partial is half', () {
    expect(xp(amount: null, target: null), 18);
    expect(xp(amount: null, target: null, outcome: CheckInOutcome.partial), 9);
  });

  test('streak bonus grows 2% a day after the first, capped at 30%', () {
    expect(xp(streakDays: 1), 18);
    expect(xp(streakDays: 6), 20); // 18 × 1.10 = 19.8
    expect(xp(streakDays: 100), 23); // 18 × 1.30 = 23.4
  });

  test('a multiplier scales rewards', () {
    expect(xp(multiplier: 0.5), 9);
  });

  test('relapse earns nothing, resisting earns base', () {
    expect(xp(outcome: CheckInOutcome.relapsed), 0);
    expect(
      xp(outcome: CheckInOutcome.resisted, amount: null, target: null),
      18,
    );
  });

  test('quality bonus is clamped to the cap', () {
    expect(
      qualityBonusXp(rules: rules, weekXp: 500, requestedFraction: 0.1),
      50,
    );
    expect(
      qualityBonusXp(rules: rules, weekXp: 500, requestedFraction: 9),
      100,
    );
    expect(qualityBonusXp(rules: rules, weekXp: 500, requestedFraction: -1), 0);
    expect(
      qualityBonusXp(rules: rules, weekXp: 500, requestedFraction: double.nan),
      0,
    );
  });

  group('levels', () {
    test('curve starts at zero and grows', () {
      expect(totalXpForLevel(1, rules), 0);
      expect(totalXpForLevel(2, rules), 60);
      expect(
        totalXpForLevel(3, rules),
        greaterThan(2 * totalXpForLevel(2, rules)),
      );
    });

    test('LevelInfo locates progress inside a level', () {
      final info = LevelInfo.fromTotal(90, rules);
      expect(info.level, 2);
      expect(info.xpIntoLevel, 30);
      expect(info.progress, closeTo(30 / info.xpForLevel, 1e-9));
      expect(LevelInfo.fromTotal(0, rules).level, 1);
    });
  });
}
