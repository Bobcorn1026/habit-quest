import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/price_repository.dart';
import '../domain/quest_rank.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import 'providers.dart';

/// The price level gold amounts are paid and charged at (`PriceRules`).
class PriceService {
  PriceService({
    required this.rules,
    required this.prices,
    required this.adventurers,
  });

  final GameRules rules;
  final PriceRepository prices;
  final AdventurerRepository adventurers;

  LogicalDay _weekOf(LogicalDay day) =>
      PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn)
          .periodOf(day)
          .start;

  /// The price level, in percent, of the week [day] is in. The first call of
  /// a week fixes it at the adventurer's guild rank of that moment; a
  /// promotion later in the week changes nothing until the next one.
  Future<int> percentFor(LogicalDay day) async {
    final hero = await adventurers.get();
    // Before there is an adventurer nothing is paid; don't fix the week yet.
    if (hero == null) return rules.prices.percentOf(QuestRank.f);
    return prices.ensureWeek(
      _weekOf(day),
      rank: hero.guildRank,
      percent: rules.prices.percentOf(hero.guildRank),
    );
  }

  Stream<int> watchPercent(LogicalDay day) async* {
    yield await percentFor(day);
    yield* prices
        .watchWeek(_weekOf(day))
        .asyncMap((percent) async => percent ?? await percentFor(day));
  }
}

final priceServiceProvider = Provider<PriceService>(
  (ref) => PriceService(
    rules: ref.watch(gameRulesProvider),
    prices: ref.watch(priceRepoProvider),
    adventurers: ref.watch(adventurerRepoProvider),
  ),
);

/// This week's price level in percent. `AppEffects` keeps it alive, so the
/// week is fixed as soon as the app is opened in it.
final priceLevelProvider = StreamProvider<int>((ref) {
  // Nothing is fixed without an adventurer: look again once there is one
  // (after onboarding), not only when the week changes.
  ref.watch(adventurerProvider.select((hero) => hero.value != null));
  return ref.watch(priceServiceProvider).watchPercent(ref.watch(todayProvider));
});

/// What a side quest's reward paid, by its reward ref; null until it has.
final sideQuestPaidProvider = StreamProvider.family<int?, String>(
  (ref, rewardRef) =>
      ref.watch(economyRepoProvider).watchEvent(source: 'side', ref: rewardRef),
);
