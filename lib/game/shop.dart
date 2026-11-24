import 'package:flutter/foundation.dart';

import '../domain/quest_rank.dart';

enum ShopCategory {
  portrait('頭像'),
  frame('稱號框'),
  wood('任務板木紋');

  const ShopCategory(this.label);
  final String label;
}

/// Something the guild sells. The guild rank decides what is on sale;
/// gold pays for it.
@immutable
class ShopItem {
  const ShopItem({
    required this.id,
    required this.category,
    required this.name,
    required this.value,
    required this.rank,
    required this.price,
  });

  final String id;
  final ShopCategory category;
  final String name;

  /// What it equips: a portrait id, a frame id or a `BoardWood` name.
  final String value;

  /// Lowest guild rank that may buy it.
  final QuestRank rank;
  final int price;
}

const kShopItems = <ShopItem>[
  ShopItem(
    id: 'portrait_knight',
    category: ShopCategory.portrait,
    name: '騎士',
    value: 'knight',
    rank: QuestRank.f,
    price: 100,
  ),
  ShopItem(
    id: 'portrait_ranger',
    category: ShopCategory.portrait,
    name: '遊俠',
    value: 'ranger',
    rank: QuestRank.e,
    price: 150,
  ),
  ShopItem(
    id: 'portrait_rogue',
    category: ShopCategory.portrait,
    name: '盜賊',
    value: 'rogue',
    rank: QuestRank.d,
    price: 200,
  ),
  ShopItem(
    id: 'portrait_cleric',
    category: ShopCategory.portrait,
    name: '僧侶',
    value: 'cleric',
    rank: QuestRank.c,
    price: 250,
  ),
  ShopItem(
    id: 'portrait_mage',
    category: ShopCategory.portrait,
    name: '法師',
    value: 'mage',
    rank: QuestRank.b,
    price: 300,
  ),
  ShopItem(
    id: 'frame_bronze',
    category: ShopCategory.frame,
    name: '青銅框',
    value: 'bronze',
    rank: QuestRank.e,
    price: 60,
  ),
  ShopItem(
    id: 'frame_silver',
    category: ShopCategory.frame,
    name: '白銀框',
    value: 'silver',
    rank: QuestRank.c,
    price: 200,
  ),
  ShopItem(
    id: 'frame_gold',
    category: ShopCategory.frame,
    name: '黃金框',
    value: 'gold',
    rank: QuestRank.a,
    price: 500,
  ),
  ShopItem(
    id: 'frame_crystal',
    category: ShopCategory.frame,
    name: '星晶框',
    value: 'crystal',
    rank: QuestRank.ss,
    price: 1000,
  ),
  ShopItem(
    id: 'wood_oak',
    category: ShopCategory.wood,
    name: '淺色橡木',
    value: 'oak',
    rank: QuestRank.e,
    price: 80,
  ),
  ShopItem(
    id: 'wood_walnut',
    category: ShopCategory.wood,
    name: '深色胡桃木',
    value: 'walnut',
    rank: QuestRank.d,
    price: 160,
  ),
  ShopItem(
    id: 'wood_cherry',
    category: ShopCategory.wood,
    name: '櫻桃木',
    value: 'cherry',
    rank: QuestRank.b,
    price: 300,
  ),
  ShopItem(
    id: 'wood_ebony',
    category: ShopCategory.wood,
    name: '黑檀木',
    value: 'ebony',
    rank: QuestRank.s,
    price: 800,
  ),
];

/// What the adventurer has chosen to show. The portrait lives on the
/// adventurer; frame and wood are stored as a setting.
@immutable
class Equipped {
  const Equipped({this.frame, this.wood = 'classic'});

  factory Equipped.fromJson(Object? json) => json is Map
      ? Equipped(
          frame: json['frame'] as String?,
          wood: (json['wood'] as String?) ?? 'classic',
        )
      : const Equipped();

  /// Null shows the title without a frame.
  final String? frame;
  final String wood;

  Map<String, Object?> toJson() => {'frame': frame, 'wood': wood};

  Equipped copyWith({String? frame, String? wood, bool clearFrame = false}) =>
      Equipped(
        frame: clearFrame ? null : frame ?? this.frame,
        wood: wood ?? this.wood,
      );
}
