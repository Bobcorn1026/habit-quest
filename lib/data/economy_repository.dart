import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import 'database.dart';

/// Purchases whose item id starts with this are inn bookings (rest days),
/// not shop items: `inn:<yyyy-MM-dd>`.
const kInnPrefix = 'inn:';

enum InnBookResult { booked, alreadyBooked, notEnoughGold }

enum SpendResult { spent, alreadySpent, notEnoughGold }

/// Guild gold: earned with each commission (stored on the check-in), from
/// perfect days, side quests and focus time (gold events), and spent in the
/// shop (purchases) or on repeatable things (negative gold events).
class EconomyRepository {
  EconomyRepository(this._db);
  final AppDatabase _db;

  Stream<int> watchBalance() => _db
      .customSelect(
        'SELECT (SELECT COALESCE(SUM(gold), 0) FROM check_ins) + '
        '(SELECT COALESCE(SUM(amount), 0) FROM gold_events) - '
        '(SELECT COALESCE(SUM(price), 0) FROM purchases) AS balance',
        readsFrom: {_db.checkIns, _db.goldEvents, _db.purchases},
      )
      .watchSingle()
      .map((row) => row.read<int>('balance'));

  Future<int> balance() => watchBalance().first;

  /// Adds [amount] for [source]/[ref] unless that pair was already paid.
  Future<bool> reward({
    required int amount,
    required String source,
    required String ref,
    required DateTime at,
  }) => _db.transaction(() async {
    final existing = await (_db.select(
      _db.goldEvents,
    )..where((t) => t.source.equals(source) & t.ref.equals(ref))).get();
    if (existing.isNotEmpty) return false;
    await _db
        .into(_db.goldEvents)
        .insert(
          GoldEventsCompanion.insert(
            amount: amount,
            source: source,
            ref: Value(ref),
            at: at,
          ),
        );
    return true;
  });

  Future<void> revoke({required String source, required String ref}) =>
      (_db.delete(
        _db.goldEvents,
      )..where((t) => t.source.equals(source) & t.ref.equals(ref))).go();

  /// What [source]/[ref] has paid in all; null while it has paid nothing.
  Stream<int?> watchEvent({required String source, required String ref}) =>
      (_db.select(
        _db.goldEvents,
      )..where((t) => t.source.equals(source) & t.ref.equals(ref))).watch().map(
        (rows) => rows.isEmpty
            ? null
            : rows.fold<int>(0, (sum, row) => sum + row.amount),
      );

  /// Takes [amount] as a negative gold event if the balance allows. Unlike a
  /// purchase this can happen any number of times, once per [source]/[ref].
  Future<SpendResult> spend({
    required int amount,
    required String source,
    required String ref,
    required DateTime at,
  }) {
    assert(amount > 0);
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.goldEvents,
      )..where((t) => t.source.equals(source) & t.ref.equals(ref))).get();
      if (existing.isNotEmpty) return SpendResult.alreadySpent;
      if (await balance() < amount) return SpendResult.notEnoughGold;
      await _db
          .into(_db.goldEvents)
          .insert(
            GoldEventsCompanion.insert(
              amount: -amount,
              source: source,
              ref: Value(ref),
              at: at,
            ),
          );
      return SpendResult.spent;
    });
  }

  /// Makes [amount] the whole of what [source]/[ref] is worth: for a total
  /// that keeps changing (the day's focus gold). 0 removes it. False when
  /// nothing had to change, so that watchers of the balance are left alone.
  Future<bool> setEvent({
    required int amount,
    required String source,
    required String ref,
    required DateTime at,
  }) => _db.transaction(() async {
    final existing =
        await (_db.select(_db.goldEvents)
              ..where((t) => t.source.equals(source) & t.ref.equals(ref))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    if (existing.isEmpty) {
      if (amount == 0) return false;
      await _db
          .into(_db.goldEvents)
          .insert(
            GoldEventsCompanion.insert(
              amount: amount,
              source: source,
              ref: Value(ref),
              at: at,
            ),
          );
      return true;
    }
    if (existing.length == 1 && existing.single.amount == amount) return false;
    if (amount == 0) {
      await revoke(source: source, ref: ref);
      return true;
    }
    // The table has no unique index: fold any duplicates into the first row.
    final keep = existing.first.id;
    if (existing.length > 1) {
      await (_db.delete(_db.goldEvents)..where(
            (t) =>
                t.source.equals(source) &
                t.ref.equals(ref) &
                t.id.isNotValue(keep),
          ))
          .go();
    }
    await (_db.update(_db.goldEvents)..where((t) => t.id.equals(keep))).write(
      GoldEventsCompanion(amount: Value(amount), at: Value(at)),
    );
    return true;
  });

  /// Shop items bought so far (inn bookings are not items).
  Stream<Set<String>> watchOwned() => _db
      .select(_db.purchases)
      .watch()
      .map(
        (rows) => {
          for (final r in rows)
            if (!r.itemId.startsWith(kInnPrefix)) r.itemId,
        },
      );

  /// Days booked at the inn, past and future.
  Stream<Set<LogicalDay>> watchBookedDays() =>
      _db.select(_db.purchases).watch().map((rows) {
        final days = <LogicalDay>{};
        for (final r in rows) {
          if (!r.itemId.startsWith(kInnPrefix)) continue;
          try {
            days.add(LogicalDay.parse(r.itemId.substring(kInnPrefix.length)));
          } on FormatException {
            // Not a day key: ignore.
          }
        }
        return days;
      });

  Future<Set<LogicalDay>> bookedDays() => watchBookedDays().first;

  /// Books [day] for [price] if it is free and the balance allows.
  Future<InnBookResult> bookInn(LogicalDay day, int price, DateTime at) =>
      _db.transaction(() async {
        final id = '$kInnPrefix${day.toKey()}';
        final existing = await (_db.select(
          _db.purchases,
        )..where((t) => t.itemId.equals(id))).get();
        if (existing.isNotEmpty) return InnBookResult.alreadyBooked;
        if (await balance() < price) return InnBookResult.notEnoughGold;
        await _db
            .into(_db.purchases)
            .insert(
              PurchasesCompanion.insert(itemId: id, price: price, at: at),
            );
        return InnBookResult.booked;
      });

  /// Cancels the booking of [day]. The price that was paid comes back with
  /// the row gone and is returned; null when there was no booking.
  Future<int?> cancelInn(LogicalDay day) => _db.transaction(() async {
    final id = '$kInnPrefix${day.toKey()}';
    final row = await (_db.select(
      _db.purchases,
    )..where((t) => t.itemId.equals(id))).getSingleOrNull();
    if (row == null) return null;
    await (_db.delete(_db.purchases)..where((t) => t.itemId.equals(id))).go();
    return row.price;
  });

  /// Buys [itemId] if the balance allows; false when it doesn't.
  Future<bool> buy(String itemId, int price, DateTime at) =>
      _db.transaction(() async {
        if (await balance() < price) return false;
        await _db
            .into(_db.purchases)
            .insert(
              PurchasesCompanion.insert(itemId: itemId, price: price, at: at),
              mode: InsertMode.insertOrIgnore,
            );
        return true;
      });
}
