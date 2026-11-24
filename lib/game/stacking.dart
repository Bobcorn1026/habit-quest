import 'package:flutter/foundation.dart';

/// Habit stacking: a habit can say "do this after ___", either another
/// habit of the player or a free-text cue. Pure rules, no storage.

/// True when anchoring [habitId] to [anchorId] is not allowed: the habit
/// itself, or a habit whose own chain of anchors leads back to [habitId].
/// [anchors] maps a habit id to the habit it is anchored to (if any).
bool anchorWouldCycle(int habitId, int anchorId, Map<int, int?> anchors) {
  var at = anchorId;
  final seen = <int>{};
  while (true) {
    if (at == habitId) return true;
    if (!seen.add(at)) return false; // an older loop not through [habitId]
    final next = anchors[at];
    if (next == null) return false;
    at = next;
  }
}

/// A habit that can be picked as an anchor.
@immutable
class AnchorChoice {
  const AnchorChoice(this.habitId, this.title);
  final int habitId;
  final String title;

  @override
  bool operator ==(Object other) =>
      other is AnchorChoice && other.habitId == habitId && other.title == title;

  @override
  int get hashCode => Object.hash(habitId, title);
}

/// What tonight's reminder says about a stack that is still pending.
@immutable
class StackHint {
  const StackHint({
    required this.cue,
    required this.habitName,
    required this.anchorIsHabit,
  });

  /// The anchor: the free text, or the anchor quest's title.
  final String cue;

  /// The habit that comes next.
  final String habitName;
  final bool anchorIsHabit;

  /// One short line, e.g. 「刷完牙了嗎？接著讀英文吧」.
  String get line =>
      anchorIsHabit ? '$cue完成了嗎？接著$habitName吧' : '$cue了嗎？接著$habitName吧';

  @override
  bool operator ==(Object other) =>
      other is StackHint &&
      other.cue == cue &&
      other.habitName == habitName &&
      other.anchorIsHabit == anchorIsHabit;

  @override
  int get hashCode => Object.hash(cue, habitName, anchorIsHabit);
}
