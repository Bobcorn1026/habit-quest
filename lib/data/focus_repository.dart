import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../game/focus.dart';
import 'database.dart';

/// The weeks and sessions of the training ground.
class FocusRepository {
  FocusRepository(this._db);
  final AppDatabase _db;

  SimpleSelectStatement<$FocusWeeksTable, FocusWeekRow> _week(
    LogicalDay weekStart,
  ) =>
      _db.select(_db.focusWeeks)
        ..where((t) => t.weekStart.equalsValue(weekStart));

  Future<FocusWeekRow?> week(LogicalDay weekStart) =>
      _week(weekStart).getSingleOrNull();

  Stream<FocusWeekRow?> watchWeek(LogicalDay weekStart) =>
      _week(weekStart).watchSingleOrNull();

  /// The day focus was switched on; null until it is.
  Future<LogicalDay?> firstDay() async {
    final first =
        await (_db.select(_db.focusWeeks)
              ..orderBy([(t) => OrderingTerm.asc(t.weekStart)])
              ..limit(1))
            .getSingleOrNull();
    return first?.fromDay;
  }

  /// Weeks that started before [weekStart] and are not settled, oldest
  /// first.
  Future<List<FocusWeekRow>> unsettledBefore(LogicalDay weekStart) =>
      (_db.select(_db.focusWeeks)
            ..where(
              (t) =>
                  t.settledAt.isNull() &
                  t.weekStart.isSmallerThanValue(weekStart.toKey()),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.weekStart)]))
          .get();

  /// Opens the week that starts on [weekStart] on [terms], unless it already
  /// is: a week keeps the terms it started with.
  Future<void> openWeek(
    LogicalDay weekStart, {
    required LogicalDay fromDay,
    required FocusTerms terms,
  }) => _db.transaction(() async {
    if (await week(weekStart) != null) return;
    await _db
        .into(_db.focusWeeks)
        .insert(
          FocusWeeksCompanion.insert(
            weekStart: weekStart,
            fromDay: fromDay,
            dailyMinutes: terms.dailyMinutes,
            capMinutes: terms.capMinutes,
            earnCapMinutes: terms.earnCapMinutes,
            goldPerHour: terms.goldPerHour,
          ),
        );
  });

  /// Closes the week with what was still owed and the gold taken for it.
  Future<void> settle(
    LogicalDay weekStart, {
    required DateTime at,
    required int unpaidSeconds,
    required int penalty,
  }) =>
      (_db.update(
        _db.focusWeeks,
      )..where((t) => t.weekStart.equalsValue(weekStart))).write(
        FocusWeeksCompanion(
          settledAt: Value(at),
          unpaidSeconds: Value(unpaidSeconds),
          penalty: Value(penalty),
        ),
      );

  SimpleSelectStatement<$FocusSessionsTable, FocusSessionRow> _sessions(
    LogicalDay from,
    LogicalDay to,
  ) => _db.select(_db.focusSessions)
    ..where(
      (t) =>
          t.day.isBiggerOrEqualValue(from.toKey()) &
          t.day.isSmallerOrEqualValue(to.toKey()),
    )
    ..orderBy([(t) => OrderingTerm.asc(t.id)]);

  /// Sessions of the days from [from] through [to], oldest first.
  Stream<List<FocusSessionRow>> watchSessions(LogicalDay from, LogicalDay to) =>
      _sessions(from, to).watch();

  /// Focused seconds by day from [from] through [to], running sessions
  /// included as far as they were saved.
  Future<Map<LogicalDay, int>> secondsByDay(
    LogicalDay from,
    LogicalDay to,
  ) async => sumByDay(await _sessions(from, to).get());

  /// Starts a session on [day] at [at]; returns its id.
  Future<int> startSession(LogicalDay day, DateTime at) => _db
      .into(_db.focusSessions)
      .insert(
        FocusSessionsCompanion.insert(day: day, startedAt: at, lastSeenAt: at),
      );

  /// Saves how far a running session has got. [hiddenAt] is set while the
  /// app is in the background and cleared otherwise.
  Future<void> saveSession(
    int id, {
    required int seconds,
    required DateTime at,
    DateTime? hiddenAt,
    int? awaySeconds,
  }) => (_db.update(_db.focusSessions)..where((t) => t.id.equals(id))).write(
    FocusSessionsCompanion(
      seconds: Value(seconds),
      lastSeenAt: Value(at),
      hiddenAt: Value(hiddenAt),
      awaySeconds: awaySeconds == null
          ? const Value.absent()
          : Value(awaySeconds),
    ),
  );

  /// Ends a session at [at] with its final [seconds].
  Future<void> endSession(
    int id, {
    required DateTime at,
    required int seconds,
    required String reason,
  }) => (_db.update(_db.focusSessions)..where((t) => t.id.equals(id))).write(
    FocusSessionsCompanion(
      seconds: Value(seconds),
      endedAt: Value(at),
      endReason: Value(reason),
    ),
  );

  /// Whether a session of the days from [from] through [to] has not ended.
  Future<bool> hasOpenSession(LogicalDay from, LogicalDay to) async =>
      (await _sessions(from, to).get()).any((s) => s.endedAt == null);

  /// Sessions that never ended: the app died while they ran.
  Future<List<FocusSessionRow>> openSessions() =>
      (_db.select(_db.focusSessions)..where((t) => t.endedAt.isNull())).get();
}

/// Focused seconds of [sessions] by day.
Map<LogicalDay, int> sumByDay(Iterable<FocusSessionRow> sessions) {
  final byDay = <LogicalDay, int>{};
  for (final row in sessions) {
    byDay.update(
      row.day,
      (seconds) => seconds + row.seconds,
      ifAbsent: () => row.seconds,
    );
  }
  return byDay;
}

extension FocusWeekTerms on FocusWeekRow {
  /// The terms the week was opened on.
  FocusTerms get terms => FocusTerms(
    dailyMinutes: dailyMinutes,
    capMinutes: capMinutes,
    earnCapMinutes: earnCapMinutes,
    goldPerHour: goldPerHour,
  );
}
