import 'package:flutter/foundation.dart';

/// A calendar date in the user's local time, where a new day only begins at
/// `dayStartHour` (so a check-in at 01:30 still counts for "yesterday").
@immutable
class LogicalDay implements Comparable<LogicalDay> {
  const LogicalDay(this.year, this.month, this.day);

  factory LogicalDay.of(DateTime local, {int dayStartHour = 4}) {
    final shifted = local.subtract(Duration(hours: dayStartHour));
    return LogicalDay(shifted.year, shifted.month, shifted.day);
  }

  /// Parses `yyyy-MM-dd`.
  factory LogicalDay.parse(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return LogicalDay(parts[0], parts[1], parts[2]);
  }

  final int year;
  final int month;
  final int day;

  // UTC avoids daylight-saving gaps when doing day arithmetic.
  DateTime get _utc => DateTime.utc(year, month, day);

  /// 1 = Monday … 7 = Sunday.
  int get weekday => _utc.weekday;

  LogicalDay addDays(int days) {
    final d = DateTime.utc(year, month, day + days);
    return LogicalDay(d.year, d.month, d.day);
  }

  /// Whole days from [other] to this (positive when this is later).
  int differenceInDays(LogicalDay other) => _utc.difference(other._utc).inDays;

  bool isBefore(LogicalDay other) => compareTo(other) < 0;
  bool isAfter(LogicalDay other) => compareTo(other) > 0;

  /// The local moment this day starts.
  DateTime startsAt({int dayStartHour = 4}) =>
      DateTime(year, month, day, dayStartHour);

  String toKey() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LogicalDay other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) =>
      other is LogicalDay &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toKey();
}
