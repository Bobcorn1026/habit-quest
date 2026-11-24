import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/game/price_level.dart';

void main() {
  const rules = GameRules();
  List<int> byRank(int base) => [
    for (final rank in QuestRank.values)
      inflate(base, rules.prices.percentOf(rank)),
  ];

  test('prices rise with the guild rank, from ×1 at F to ×4 at SSS', () {
    expect(byRank(rules.focus.baseGoldPerHour), [
      20, 24, 30, 36, 44, 52, 60, 70, 80, //
    ]);
    expect(byRank(rules.progression.innPrice), [
      50, 60, 75, 90, 110, 130, 150, 175, 200, //
    ]);
    expect(byRank(rules.progression.goldPerfectDay), [
      10, 12, 15, 18, 22, 26, 30, 35, 40, //
    ]);
    expect(byRank(rules.progression.sideQuestGold), [
      30, 36, 45, 54, 66, 78, 90, 105, 120, //
    ]);
  });

  test('small amounts round to the nearest coin, halves up', () {
    expect(byRank(1), [1, 1, 2, 2, 2, 3, 3, 4, 4]);
    expect(byRank(3), [3, 4, 5, 5, 7, 8, 9, 11, 12]);
    expect(inflate(0, 400), 0);
  });
}
