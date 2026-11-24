import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/quest_rank.dart';
import 'database.dart';

/// The price level of each week, kept so that it stays what it was when the
/// week started.
class PriceRepository {
  PriceRepository(this._db);
  final AppDatabase _db;

  SimpleSelectStatement<$PriceWeeksTable, PriceWeekRow> _week(
    LogicalDay weekStart,
  ) =>
      _db.select(_db.priceWeeks)
        ..where((t) => t.weekStart.equalsValue(weekStart));

  /// The price level of the week that starts on [weekStart]. A week that has
  /// none yet takes [percent], the level of guild rank [rank], and keeps it
  /// whatever is passed later.
  Future<int> ensureWeek(
    LogicalDay weekStart, {
    required QuestRank rank,
    required int percent,
  }) => _db.transaction(() async {
    final row = await _week(weekStart).getSingleOrNull();
    if (row != null) return row.percent;
    await _db
        .into(_db.priceWeeks)
        .insert(
          PriceWeeksCompanion.insert(
            weekStart: weekStart,
            rank: rank,
            percent: percent,
          ),
        );
    return percent;
  });

  /// The level of that week; null until it is fixed.
  Stream<int?> watchWeek(LogicalDay weekStart) =>
      _week(weekStart).watchSingleOrNull().map((row) => row?.percent);
}
