import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/casino.dart';
import 'database.dart';

/// A ticket to put in a new week's deck.
typedef NewTicket = ({
  TicketKind kind,
  PrizeTier? tier,
  int amount,
  int? accountId,
});

/// The casino's weeks and their decks.
class CasinoRepository {
  CasinoRepository(this._db);
  final AppDatabase _db;

  /// Everything a change of the casino touches, for watching it whole.
  Set<ResultSetImplementation<dynamic, dynamic>> get tables => {
    _db.casinoWeeks,
    _db.casinoTickets,
  };

  SimpleSelectStatement<$CasinoWeeksTable, CasinoWeekRow> _week(
    LogicalDay weekStart,
  ) =>
      _db.select(_db.casinoWeeks)
        ..where((t) => t.weekStart.equalsValue(weekStart));

  Future<CasinoWeekRow?> week(LogicalDay weekStart) =>
      _week(weekStart).getSingleOrNull();

  /// The first week the casino was open; null until it opens.
  Future<CasinoWeekRow?> firstWeek() =>
      (_db.select(_db.casinoWeeks)
            ..orderBy([(t) => OrderingTerm.asc(t.weekStart)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<CasinoWeekRow>> weeks() => (_db.select(
    _db.casinoWeeks,
  )..orderBy([(t) => OrderingTerm.asc(t.weekStart)])).get();

  /// The latest week before [weekStart] that started in [weekStart]'s
  /// month, whose plan the month's later weeks follow.
  Future<CasinoWeekRow?> earlierInMonth(LogicalDay weekStart) {
    final first = LogicalDay(weekStart.year, weekStart.month, 1);
    return (_db.select(_db.casinoWeeks)
          ..where(
            (t) =>
                t.weekStart.isBiggerOrEqualValue(first.toKey()) &
                t.weekStart.isSmallerThanValue(weekStart.toKey()),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.weekStart)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Weeks that started before [weekStart] and are not settled, oldest
  /// first.
  Future<List<CasinoWeekRow>> unsettledBefore(LogicalDay weekStart) =>
      (_db.select(_db.casinoWeeks)
            ..where(
              (t) =>
                  t.settledAt.isNull() &
                  t.weekStart.isSmallerThanValue(weekStart.toKey()),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.weekStart)]))
          .get();

  /// Opens a week with its deck, unless it already is.
  Future<bool> openWeek(CasinoWeeksCompanion week, List<NewTicket> tickets) =>
      _db.transaction(() async {
        if (await this.week(week.weekStart.value) != null) return false;
        await _db.into(_db.casinoWeeks).insert(week);
        await _db.batch((b) {
          b.insertAll(_db.casinoTickets, [
            for (final t in tickets)
              CasinoTicketsCompanion.insert(
                weekStart: week.weekStart.value,
                kind: t.kind,
                tier: Value(t.tier),
                amount: Value(t.amount),
                accountId: Value(t.accountId),
              ),
          ]);
        });
        return true;
      });

  Future<void> settle(
    LogicalDay weekStart, {
    required DateTime at,
    required int swept,
  }) =>
      (_db.update(
        _db.casinoWeeks,
      )..where((t) => t.weekStart.equalsValue(weekStart))).write(
        CasinoWeeksCompanion(settledAt: Value(at), swept: Value(swept)),
      );

  Future<List<CasinoTicketRow>> tickets(LogicalDay weekStart) =>
      (_db.select(_db.casinoTickets)
            ..where((t) => t.weekStart.equalsValue(weekStart))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<CasinoTicketRow?> ticket(int id) => (_db.select(
    _db.casinoTickets,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Marks a ticket drawn unless it already was; true when it was marked.
  Future<bool> markDrawn(
    int id, {
    required DateTime at,
    required CasinoGame game,
    required int paid,
  }) async =>
      await (_db.update(
        _db.casinoTickets,
      )..where((t) => t.id.equals(id) & t.drawnAt.isNull())).write(
        CasinoTicketsCompanion(
          drawnAt: Value(at),
          game: Value(game),
          paid: Value(paid),
        ),
      ) ==
      1;

  /// Prize money still in the decks of weeks not settled: the part of the
  /// pool that is promised.
  Future<int> promised() => _db
      .customSelect(
        'SELECT COALESCE(SUM(t.amount), 0) AS promised '
        'FROM casino_tickets t JOIN casino_weeks w '
        'ON w.week_start = t.week_start '
        "WHERE t.kind = 'prize' AND t.drawn_at IS NULL "
        'AND w.settled_at IS NULL',
        readsFrom: tables,
      )
      .map((r) => r.read<int>('promised'))
      .getSingle();
}

/// What a casino week keeps in its `termsJson`.
class CasinoTerms {
  const CasinoTerms({
    this.plan = const {},
    this.days = 7,
    this.questCount = 0,
    this.focusGold = 0,
    this.goldAtOpen = 0,
  });

  factory CasinoTerms.fromJson(String text) {
    Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      json = null;
    }
    if (json is! Map) return const CasinoTerms();
    int number(Object? v) => v is num ? v.toInt() : 0;
    final plan = json['plan'];
    return CasinoTerms(
      plan: plan is Map
          ? {
              for (final e in plan.entries)
                if (e.value is num) '${e.key}': (e.value as num).toInt(),
            }
          : const {},
      days: json['days'] is num ? number(json['days']) : 7,
      questCount: number(json['quests']),
      focusGold: number(json['focusGold']),
      goldAtOpen: number(json['gold']),
    );
  }

  /// The month's share of each of its weeks from this one on, in percent of
  /// the average week, by the key of their Monday.
  final Map<String, int> plan;

  /// Days the price counts: open days of the week (fewer only the first
  /// week) that are not booked rest days.
  final int days;

  /// What the price was set on.
  final int questCount;
  final int focusGold;

  /// The player's gold when the week opened.
  final int goldAtOpen;

  String toJson() => jsonEncode({
    'plan': plan,
    'days': days,
    'quests': questCount,
    'focusGold': focusGold,
    'gold': goldAtOpen,
  });
}

extension CasinoWeekRowTerms on CasinoWeekRow {
  CasinoTerms get terms => CasinoTerms.fromJson(termsJson);
  LogicalDay get lastDay => weekStart.addDays(6);
}
