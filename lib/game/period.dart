import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';

/// A run of consecutive logical days: a story chapter or a calendar week.
@immutable
class Period {
  const Period(this.start, this.days);

  final LogicalDay start;
  final int days;

  LogicalDay get endExclusive => start.addDays(days);
  LogicalDay get last => start.addDays(days - 1);

  bool contains(LogicalDay day) =>
      !day.isBefore(start) && day.isBefore(endExclusive);

  Iterable<LogicalDay> get dayList sync* {
    for (var i = 0; i < days; i++) {
      yield start.addDays(i);
    }
  }

  Period get next => Period(endExclusive, days);
  Period get previous => Period(start.addDays(-days), days);

  @override
  bool operator ==(Object other) =>
      other is Period && other.start == start && other.days == days;

  @override
  int get hashCode => Object.hash(start, days);

  @override
  String toString() => 'Period($start, $days days)';
}

/// Cuts time into equal periods starting from [anchor].
@immutable
class PeriodCalendar {
  const PeriodCalendar({required this.anchor, required this.lengthDays})
    : assert(lengthDays > 0);

  /// Calendar weeks starting on [weekStartsOn].
  factory PeriodCalendar.weeks({int weekStartsOn = DateTime.monday}) {
    // 2024-01-01 was a Monday; shift to the requested weekday.
    final anchor = const LogicalDay(2024, 1, 1).addDays(weekStartsOn - 1);
    return PeriodCalendar(anchor: anchor, lengthDays: 7);
  }

  final LogicalDay anchor;
  final int lengthDays;

  Period periodOf(LogicalDay day) {
    final offset = day.differenceInDays(anchor);
    final index = (offset / lengthDays).floor();
    return Period(anchor.addDays(index * lengthDays), lengthDays);
  }

  /// Every period that ended at or before [day] since [from] (oldest first),
  /// skipping the one still running.
  List<Period> finishedBetween(LogicalDay from, LogicalDay day) {
    final out = <Period>[];
    var p = periodOf(from);
    final current = periodOf(day);
    while (p.start.isBefore(current.start)) {
      out.add(p);
      p = p.next;
    }
    return out;
  }
}
