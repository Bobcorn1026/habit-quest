import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import 'period.dart';

/// A habit's current run, following "never miss twice": one missed slot only
/// wounds the streak; two in a row break it.
@immutable
class StreakState {
  const StreakState({
    this.length = 0,
    this.clean = 0,
    this.slotDays = 1,
    this.wounded = false,
    this.broken = false,
  });

  /// Met slots in the current run (days, or weeks for weekly-quota habits).
  final int length;

  /// Met slots since the most recent miss: the spotless part of the run.
  /// Seals use this for their strength, so a crack always shows.
  final int clean;

  /// 1 for daily habits, 7 when each slot is a week.
  final int slotDays;

  /// The last finished slot was missed and the current one isn't met yet.
  final bool wounded;

  /// The last two finished slots were both missed.
  final bool broken;

  int get days => length * slotDays;
  int get cleanDays => clean * slotDays;
}

/// Computes the streak as of [today]. The current slot only counts once met;
/// until then it is neither a hit nor a miss.
StreakState computeStreak({
  required Habit habit,
  required Iterable<CheckIn> checkIns,
  required LogicalDay firstDay,
  required LogicalDay today,
  int weekStartsOn = DateTime.monday,
  Set<LogicalDay> restDays = const {},
}) {
  final mine = checkIns.where((c) => c.habitId == habit.id).toList();
  if (habit.isDaily) {
    final metDays = {
      for (final c in mine)
        if (c.outcome.keepsStreak) c.day,
    };
    // A rest day with no report is skipped: it neither counts nor breaks.
    final reported = {for (final c in mine) c.day};
    bool skipped(LogicalDay d) => restDays.contains(d) && !reported.contains(d);
    final slots = [
      for (var d = firstDay; !d.isAfter(today); d = d.addDays(1))
        if (!skipped(d)) d,
    ];
    if (!skipped(today)) {
      return _walk(slots: slots, isMet: metDays.contains, slotDays: 1);
    }
    // Resting today: the days before are all finished, but nothing is
    // wounded or broken until a working day passes.
    final s = _walk(
      slots: [...slots, today],
      isMet: metDays.contains,
      slotDays: 1,
    );
    return StreakState(length: s.length, clean: s.clean, slotDays: 1);
  }

  final weeks = PeriodCalendar.weeks(weekStartsOn: weekStartsOn);
  final slots = <Period>[];
  for (var w = weeks.periodOf(firstDay); !w.start.isAfter(today); w = w.next) {
    slots.add(w);
  }
  bool isMet(Period w) {
    final activeDays = w.dayList.where((d) => !d.isBefore(firstDay)).length;
    final quota = (habit.timesPerWeek * activeDays / 7).ceil();
    final hits = mine
        .where((c) => w.contains(c.day) && c.outcome.keepsStreak)
        .length;
    return hits >= quota;
  }

  return _walk(slots: slots, isMet: isMet, slotDays: 7);
}

StreakState _walk<T>({
  required List<T> slots,
  required bool Function(T) isMet,
  required int slotDays,
}) {
  if (slots.isEmpty) return StreakState(slotDays: slotDays);
  final current = slots.last;
  final currentMet = isMet(current);
  var length = currentMet ? 1 : 0;
  var clean = length;
  var consecutiveMisses = 0;
  var leadingMisses = 0;
  var seenHit = false;
  var seenMiss = false;
  for (var i = slots.length - 2; i >= 0; i--) {
    if (isMet(slots[i])) {
      length++;
      if (!seenMiss) clean++;
      consecutiveMisses = 0;
      seenHit = true;
    } else {
      seenMiss = true;
      consecutiveMisses++;
      if (!seenHit) leadingMisses++;
      if (consecutiveMisses >= 2) break;
    }
  }
  return StreakState(
    length: length,
    clean: clean,
    slotDays: slotDays,
    wounded: !currentMet && leadingMisses == 1,
    broken: !currentMet && leadingMisses >= 2,
  );
}
