import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import 'quest_rank.dart';
import 'stat.dart';

/// The RPG skin of a habit. Upgrading a quest creates a new tier with a new
/// target; old tiers keep their history.
@immutable
class Quest {
  const Quest({
    required this.id,
    required this.habitId,
    required this.tier,
    required this.rank,
    required this.title,
    required this.subtitle,
    this.flavor = '',
    this.spriteId = 'scroll',
    this.target,
    this.attribute,
    required this.activeFrom,
    this.activeUntil,
  });

  final int id;
  final int habitId;

  /// 1 for the first version; +1 on each upgrade.
  final int tier;
  final QuestRank rank;

  /// e.g. 「破譯古代卷軸」
  final String title;

  /// The chuunibyou or tongue-in-cheek tagline, e.g.「～那些字母在對我低語～」
  final String subtitle;
  final String flavor;
  final String spriteId;

  /// Daily target at this tier (copied from the habit when created).
  final double? target;

  /// The stat this quest trains; null for quests saved before attributes
  /// existed (see `ActiveQuest.attribute`).
  final Stat? attribute;
  final LogicalDay activeFrom;

  /// Last day this tier was active; null while current.
  final LogicalDay? activeUntil;

  bool get isCurrent => activeUntil == null;
}
