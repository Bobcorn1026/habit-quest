import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import 'hero_class.dart';
import 'quest_rank.dart';

/// The player character. (Not `Hero`, which Flutter already uses.)
@immutable
class Adventurer {
  const Adventurer({
    required this.id,
    required this.name,
    this.identity,
    this.heroClass,
    this.classInfo,
    this.title,
    this.portraitId,
    this.guildRank = QuestRank.f,
    this.rankSince,
    this.trialStart,
    required this.createdAt,
  });

  final int id;
  final String name;

  /// Identity-based habit statement: 「我想成為＿＿的人」.
  final String? identity;

  /// Shown class name, e.g. 「見習冒險者」 before the class appraisal.
  final String? heroClass;

  /// Set once the class has been appraised (from week 2).
  final HeroClass? classInfo;

  /// Current earned title, e.g. 「卷軸破譯者」.
  final String? title;

  /// Chosen portrait; null follows the class name.
  final String? portraitId;

  final QuestRank guildRank;

  /// The day of the last guild promotion; rank points count after it.
  final LogicalDay? rankSince;

  /// First day of a running promotion trial.
  final LogicalDay? trialStart;
  final DateTime createdAt;

  bool get hasClass => classInfo != null;
}
