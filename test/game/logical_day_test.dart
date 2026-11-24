import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/game/period.dart';

void main() {
  group('LogicalDay', () {
    test('a check-in before 4 a.m. belongs to the previous day', () {
      expect(
        LogicalDay.of(DateTime(2026, 11, 5, 1, 30)),
        const LogicalDay(2026, 11, 4),
      );
      expect(
        LogicalDay.of(DateTime(2026, 11, 5, 4)),
        const LogicalDay(2026, 11, 5),
      );
    });

    test('day start hour is configurable', () {
      expect(
        LogicalDay.of(DateTime(2026, 11, 5, 5), dayStartHour: 6),
        const LogicalDay(2026, 11, 4),
      );
    });

    test('crosses month and year boundaries', () {
      expect(
        const LogicalDay(2026, 12, 31).addDays(1),
        const LogicalDay(2027, 1, 1),
      );
      expect(
        const LogicalDay(2027, 3, 1).addDays(-1),
        const LogicalDay(2027, 2, 28),
      );
    });

    test('round-trips through its key', () {
      const d = LogicalDay(2026, 1, 9);
      expect(d.toKey(), '2026-01-09');
      expect(LogicalDay.parse(d.toKey()), d);
    });

    test('weekday and difference', () {
      expect(const LogicalDay(2026, 11, 2).weekday, DateTime.monday);
      expect(
        const LogicalDay(
          2026,
          11,
          9,
        ).differenceInDays(const LogicalDay(2026, 11, 2)),
        7,
      );
    });
  });

  group('PeriodCalendar', () {
    test('weeks start on the configured weekday', () {
      final weeks = PeriodCalendar.weeks();
      final p = weeks.periodOf(const LogicalDay(2026, 11, 5)); // Thursday
      expect(p.start, const LogicalDay(2026, 11, 2));
      expect(p.last, const LogicalDay(2026, 11, 8));

      final sundayWeeks = PeriodCalendar.weeks(weekStartsOn: DateTime.sunday);
      expect(
        sundayWeeks.periodOf(const LogicalDay(2026, 11, 5)).start,
        const LogicalDay(2026, 11, 1),
      );
    });

    test('custom lengths count from the anchor, also before it', () {
      const cal = PeriodCalendar(
        anchor: LogicalDay(2026, 11, 2),
        lengthDays: 3,
      );
      expect(
        cal.periodOf(const LogicalDay(2026, 11, 6)).start,
        const LogicalDay(2026, 11, 5),
      );
      expect(
        cal.periodOf(const LogicalDay(2026, 11, 1)).start,
        const LogicalDay(2026, 10, 30),
      );
    });

    test('finishedBetween skips the running period', () {
      final weeks = PeriodCalendar.weeks();
      final done = weeks.finishedBetween(
        const LogicalDay(2026, 11, 4),
        const LogicalDay(2026, 11, 18),
      );
      expect(done.map((p) => p.start.toKey()), ['2026-11-02', '2026-11-09']);
    });
  });
}
