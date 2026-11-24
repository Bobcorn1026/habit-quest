import 'package:flutter/foundation.dart';

import '../domain/quest_rank.dart';

/// Inflation: everything paid or charged in gold grows with the guild rank,
/// except the shop's cosmetics, which keep their price and so get easier to
/// afford. The level of a week is fixed when it starts; a promotion in the
/// middle of the week moves prices the Monday after.
@immutable
class PriceRules {
  const PriceRules({
    this.percentByRank = const {
      QuestRank.f: 100,
      QuestRank.e: 120,
      QuestRank.d: 150,
      QuestRank.c: 180,
      QuestRank.b: 220,
      QuestRank.a: 260,
      QuestRank.s: 300,
      QuestRank.ss: 350,
      QuestRank.sss: 400,
    },
  });

  /// Price level by guild rank, in percent of the F-rank amounts.
  final Map<QuestRank, int> percentByRank;

  int percentOf(QuestRank guildRank) => percentByRank[guildRank] ?? 100;
}

/// [base] gold at price level [percent], rounded to the nearest coin (halves
/// go up).
int inflate(int base, int percent) {
  assert(base >= 0 && percent >= 0);
  return (base * percent + 50) ~/ 100;
}
