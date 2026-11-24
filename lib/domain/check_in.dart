import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';

enum CheckInOutcome {
  /// Reached the target (or a yes/no habit was done).
  done,

  /// Did some, but less than the target.
  partial,

  /// Quit habit: held the seal today.
  resisted,

  /// Quit habit: gave in today.
  relapsed;

  /// Whether this outcome keeps a streak alive.
  bool get keepsStreak => this != relapsed;
}

/// One habit's report for one logical day.
@immutable
class CheckIn {
  const CheckIn({
    this.id,
    required this.habitId,
    required this.questId,
    required this.day,
    required this.outcome,
    this.amount,
    this.note,
    this.xp = 0,
    this.gold = 0,
    required this.createdAt,
  });

  final int? id;
  final int habitId;
  final int questId;
  final LogicalDay day;
  final CheckInOutcome outcome;
  final double? amount;
  final String? note;
  final int xp;
  final int gold;
  final DateTime createdAt;
}
