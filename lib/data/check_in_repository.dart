import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/check_in.dart';
import 'database.dart';

class CheckInRepository {
  CheckInRepository(this._db);
  final AppDatabase _db;

  /// Saves the day's report, replacing an earlier one for the same habit/day.
  Future<void> upsert(CheckIn c) => _db
      .into(_db.checkIns)
      .insert(
        CheckInsCompanion.insert(
          habitId: c.habitId,
          questId: c.questId,
          day: c.day,
          outcome: c.outcome,
          amount: Value(c.amount),
          note: Value(c.note),
          xp: Value(c.xp),
          gold: Value(c.gold),
          createdAt: c.createdAt,
        ),
        onConflict: DoUpdate.withExcluded(
          (old, excluded) => CheckInsCompanion.custom(
            questId: excluded.questId,
            outcome: excluded.outcome,
            amount: excluded.amount,
            note: excluded.note,
            xp: excluded.xp,
            gold: excluded.gold,
            createdAt: excluded.createdAt,
          ),
          target: [_db.checkIns.habitId, _db.checkIns.day],
        ),
      );

  Future<void> remove(int habitId, LogicalDay day) => (_db.delete(
    _db.checkIns,
  )..where((t) => t.habitId.equals(habitId) & t.day.equalsValue(day))).go();

  /// Check-ins with `from <= day <= to`.
  Future<List<CheckIn>> between(LogicalDay from, LogicalDay to) =>
      _between(from, to).get().then(_mapAll);

  Stream<List<CheckIn>> watchBetween(LogicalDay from, LogicalDay to) =>
      _between(from, to).watch().map(_mapAll);

  Future<List<CheckIn>> forHabit(int habitId) =>
      (_db.select(_db.checkIns)
            ..where((t) => t.habitId.equals(habitId))
            ..orderBy([(t) => OrderingTerm.asc(t.day)]))
          .get()
          .then(_mapAll);

  Future<int> addXpEvent({
    required int amount,
    required String source,
    int? refId,
    required DateTime at,
  }) => _db
      .into(_db.xpEvents)
      .insert(
        XpEventsCompanion.insert(
          amount: amount,
          source: source,
          refId: Value(refId),
          at: at,
        ),
      );

  /// Check-in XP plus bonus events.
  Stream<int> watchTotalXp() => _db
      .customSelect(
        'SELECT (SELECT COALESCE(SUM(xp), 0) FROM check_ins) + '
        '(SELECT COALESCE(SUM(amount), 0) FROM xp_events) AS total',
        readsFrom: {_db.checkIns, _db.xpEvents},
      )
      .watchSingle()
      .map((row) => row.read<int>('total'));

  Future<int> totalXp() => watchTotalXp().first;

  /// Lifetime check-in XP per quest tier.
  Stream<Map<int, int>> watchXpByQuest() => _db
      .customSelect(
        'SELECT quest_id, SUM(xp) AS xp FROM check_ins GROUP BY quest_id',
        readsFrom: {_db.checkIns},
      )
      .watch()
      .map(
        (rows) => {
          for (final r in rows) r.read<int>('quest_id'): r.read<int>('xp'),
        },
      );

  SimpleSelectStatement<$CheckInsTable, CheckInRow> _between(
    LogicalDay from,
    LogicalDay to,
  ) => _db.select(_db.checkIns)
    ..where(
      (t) =>
          t.day.isBiggerOrEqualValue(from.toKey()) &
          t.day.isSmallerOrEqualValue(to.toKey()),
    )
    ..orderBy([(t) => OrderingTerm.asc(t.day)]);

  static List<CheckIn> _mapAll(List<CheckInRow> rows) => [
    for (final r in rows)
      CheckIn(
        id: r.id,
        habitId: r.habitId,
        questId: r.questId,
        day: r.day,
        outcome: r.outcome,
        amount: r.amount,
        note: r.note,
        xp: r.xp,
        gold: r.gold,
        createdAt: r.createdAt,
      ),
  ];
}
