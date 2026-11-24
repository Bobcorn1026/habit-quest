import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import 'stat.dart';

/// Shown until the class appraisal in week 2.
const kNoviceClass = '見習冒險者';

/// The adventurer's class, appraised from what their quests train. Quests of
/// its [stats] grow those stats faster and pay a little more XP.
@immutable
class HeroClass {
  const HeroClass({
    required this.name,
    required this.stats,
    required this.since,
    this.flavor = '',
  });

  final String name;

  /// One or two primary stats.
  final List<Stat> stats;

  /// The day the class was taken; mastery counts from here.
  final LogicalDay since;
  final String flavor;
}
