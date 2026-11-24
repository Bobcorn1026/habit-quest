import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../data/adventurer_repository.dart';
import '../data/economy_repository.dart';
import '../data/settings_repository.dart';
import '../game/shop.dart';
import 'providers.dart';

enum BuyResult { bought, rankTooLow, notEnoughGold }

/// Buying and equipping things from the guild shop.
class ShopService {
  ShopService({
    required this.clock,
    required this.adventurers,
    required this.economy,
    required this.settings,
  });

  final Clock clock;
  final AdventurerRepository adventurers;
  final EconomyRepository economy;
  final SettingsRepository settings;

  Future<BuyResult> buy(ShopItem item) async {
    final hero = await adventurers.get();
    if (hero == null || hero.guildRank.index < item.rank.index) {
      return BuyResult.rankTooLow;
    }
    final ok = await economy.buy(item.id, item.price, clock.now());
    if (!ok) return BuyResult.notEnoughGold;
    await equip(item);
    return BuyResult.bought;
  }

  Future<Equipped> _equipped() async =>
      Equipped.fromJson(await settings.read(SettingKeys.equipped));

  Future<void> equip(ShopItem item) async {
    switch (item.category) {
      case ShopCategory.portrait:
        final hero = await adventurers.get();
        if (hero != null) await adventurers.setPortrait(hero.id, item.value);
      case ShopCategory.frame:
        await settings.write(
          SettingKeys.equipped,
          (await _equipped()).copyWith(frame: item.value).toJson(),
        );
      case ShopCategory.wood:
        await settings.write(
          SettingKeys.equipped,
          (await _equipped()).copyWith(wood: item.value).toJson(),
        );
    }
  }

  /// Back to the free look of [category]: the class portrait, no frame,
  /// the classic board.
  Future<void> unequip(ShopCategory category) async {
    switch (category) {
      case ShopCategory.portrait:
        final hero = await adventurers.get();
        if (hero != null) await adventurers.setPortrait(hero.id, null);
      case ShopCategory.frame:
        await settings.write(
          SettingKeys.equipped,
          (await _equipped()).copyWith(clearFrame: true).toJson(),
        );
      case ShopCategory.wood:
        await settings.write(
          SettingKeys.equipped,
          (await _equipped()).copyWith(wood: 'classic').toJson(),
        );
    }
  }
}

final shopServiceProvider = Provider<ShopService>(
  (ref) => ShopService(
    clock: ref.watch(clockProvider),
    adventurers: ref.watch(adventurerRepoProvider),
    economy: ref.watch(economyRepoProvider),
    settings: ref.watch(settingsRepoProvider),
  ),
);
