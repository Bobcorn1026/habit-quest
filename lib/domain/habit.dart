import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';

enum HabitKind {
  /// A habit to build; shown as a quest.
  build,

  /// A habit to break; shown as a seal holding a monster.
  quit,
}

/// What the user actually wants to do, in their own words.
@immutable
class Habit {
  const Habit({
    required this.id,
    required this.kind,
    required this.name,
    this.unit,
    this.target,
    this.timesPerWeek = 7,
    this.intention,
    required this.firstDay,
    required this.createdAt,
    this.archivedAt,
    this.cursedOn,
    this.anchorHabitId,
    this.anchorText,
  });

  final int id;
  final HabitKind kind;

  /// e.g. 「讀英文」or「十一點後滑手機」.
  final String name;

  /// e.g. 「分鐘」「頁」; null when the habit is a simple yes/no.
  final String? unit;

  /// Daily amount in [unit]; null for yes/no habits.
  final double? target;

  /// How many days a week the habit is scheduled (7 = daily). Quit habits
  /// are always daily.
  final int timesPerWeek;

  /// Optional implementation intention: 「我會在＿＿時於＿＿做＿＿」.
  final String? intention;

  /// The logical day the habit was added; nothing before it is scheduled.
  final LogicalDay firstDay;

  final DateTime createdAt;
  final DateTime? archivedAt;

  /// Edited on this day: the quest is cursed and must be done that day.
  final LogicalDay? cursedOn;

  /// Habit stacking: "do this after" another habit (by id; the habit may
  /// have been archived since) ...
  final int? anchorHabitId;

  /// ... or after a free-text cue such as 「刷完牙」. At most one is set.
  final String? anchorText;

  bool cursedToday(LogicalDay today) => cursedOn == today;

  bool get isDaily => kind == HabitKind.quit || timesPerWeek >= 7;
  bool get hasAmount => target != null && target! > 0;
}
