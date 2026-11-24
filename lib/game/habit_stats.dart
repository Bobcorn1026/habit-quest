import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import 'period.dart';

/// How one habit went during one period.
@immutable
class HabitPeriodStats {
  const HabitPeriodStats({
    required this.habitId,
    required this.period,
    required this.scheduled,
    required this.completion,
    this.done = 0,
    this.partial = 0,
    this.resisted = 0,
    this.relapsed = 0,
    this.averageAmount,
    this.target,
    this.notes = const [],
  });

  final int habitId;
  final Period period;

  /// Check-ins expected in the counted days.
  final int scheduled;

  /// 0–1. Partial check-ins count by how much of the target they reached.
  final double completion;
  final int done;
  final int partial;
  final int resisted;
  final int relapsed;

  /// Mean amount over done/partial check-ins that reported one.
  final double? averageAmount;
  final double? target;
  final List<String> notes;

  int get reported => done + partial + resisted + relapsed;
}

/// Summarizes [checkIns] of [habit] inside [period], counting only days on
/// or after the habit's [firstDay] and on or before [asOf].
HabitPeriodStats computePeriodStats({
  required Habit habit,
  required double? target,
  required Period period,
  required Iterable<CheckIn> checkIns,
  required LogicalDay firstDay,
  required LogicalDay asOf,
  Set<LogicalDay> restDays = const {},
}) {
  // A daily habit expects nothing on a rest day without a report.
  final reportedDays = habit.isDaily && restDays.isNotEmpty
      ? {
          for (final c in checkIns)
            if (c.habitId == habit.id) c.day,
        }
      : const <LogicalDay>{};
  final counted = period.dayList
      .where(
        (d) =>
            !d.isBefore(firstDay) &&
            !d.isAfter(asOf) &&
            !(habit.isDaily &&
                restDays.contains(d) &&
                !reportedDays.contains(d)),
      )
      .toSet();
  final activeDays = counted.length;
  final scheduled = activeDays == 0
      ? 0
      : habit.isDaily
      ? activeDays
      : (habit.timesPerWeek * activeDays / 7).ceil();

  var done = 0, partial = 0, resisted = 0, relapsed = 0;
  var credit = 0.0;
  final amounts = <double>[];
  final notes = <String>[];
  for (final c in checkIns) {
    if (c.habitId != habit.id || !counted.contains(c.day)) continue;
    switch (c.outcome) {
      case CheckInOutcome.done:
        done++;
        credit += 1;
      case CheckInOutcome.partial:
        partial++;
        final t = target;
        credit += (t != null && t > 0 && c.amount != null)
            ? (c.amount! / t).clamp(0, 1).toDouble()
            : 0.5;
      case CheckInOutcome.resisted:
        resisted++;
        credit += 1;
      case CheckInOutcome.relapsed:
        relapsed++;
    }
    if (c.amount != null &&
        (c.outcome == CheckInOutcome.done ||
            c.outcome == CheckInOutcome.partial)) {
      amounts.add(c.amount!);
    }
    final note = c.note?.trim();
    if (note != null && note.isNotEmpty) notes.add(note);
  }

  return HabitPeriodStats(
    habitId: habit.id,
    period: period,
    scheduled: scheduled,
    completion: scheduled == 0 ? 0 : (credit / scheduled).clamp(0, 1),
    done: done,
    partial: partial,
    resisted: resisted,
    relapsed: relapsed,
    averageAmount: amounts.isEmpty
        ? null
        : amounts.reduce((a, b) => a + b) / amounts.length,
    target: target,
    notes: notes,
  );
}
