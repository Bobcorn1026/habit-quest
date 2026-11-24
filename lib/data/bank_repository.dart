import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../core/logical_day.dart';
import '../domain/bank.dart';
import 'database.dart';

/// Ref of a day's meal money: `meal:<yyyy-MM-dd>`.
const kMealRefPrefix = 'meal:';

/// The bank's accounts, money moves and months. Balances are never stored:
/// they are what came in minus what went out over the rows not voided.
class BankRepository {
  BankRepository(this._db, {math.Random? random})
    : _random = random ?? math.Random.secure();
  final AppDatabase _db;
  final math.Random _random;

  /// Everything a change of the bank touches, for watching it whole.
  Set<ResultSetImplementation<dynamic, dynamic>> get tables => {
    _db.bankAccounts,
    _db.bankTxns,
    _db.bankMonths,
  };

  /// Fires after each write to the bank (once per transaction).
  Stream<void> watchChanges() =>
      _db.tableUpdates(TableUpdateQuery.onAllTables(tables));

  /// A fresh id for a row or a group of rows.
  String newUid() => [
    for (var i = 0; i < 4; i++)
      _random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0'),
  ].join();

  // Accounts

  Future<List<BankAccountRow>> accounts() =>
      (_db.select(_db.bankAccounts)..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
          .get();

  Future<BankAccountRow?> account(int id) => (_db.select(
    _db.bankAccounts,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<BankAccountRow?> byRole(AccountRole role) =>
      (_db.select(_db.bankAccounts)
            ..where((t) => t.role.equalsValue(role))
            ..orderBy([(t) => OrderingTerm.asc(t.id)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> addAccount({
    required String name,
    required String icon,
    required DateTime at,
    AccountRole? role,
    int weight = 0,
    int? sortOrder,
  }) async {
    final order =
        sortOrder ??
        await _db
            .customSelect(
              'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next '
              'FROM bank_accounts',
              readsFrom: {_db.bankAccounts},
            )
            .map((r) => r.read<int>('next'))
            .getSingle();
    return _db
        .into(_db.bankAccounts)
        .insert(
          BankAccountsCompanion.insert(
            name: name,
            role: Value(role),
            icon: icon,
            weight: Value(weight),
            sortOrder: Value(order),
            createdAt: at,
          ),
        );
  }

  Future<void> updateAccount(
    int id, {
    String? name,
    String? icon,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => (_db.update(_db.bankAccounts)..where((t) => t.id.equals(id))).write(
    BankAccountsCompanion(
      name: name == null ? const Value.absent() : Value(name),
      icon: icon == null ? const Value.absent() : Value(icon),
      archivedAt: archivedAt,
    ),
  );

  /// Balance of every account by id.
  Future<Map<int, int>> balances() async {
    final rows = await _db
        .customSelect(
          'SELECT a.id AS id, '
          '(SELECT COALESCE(SUM(amount), 0) FROM bank_txns '
          ' WHERE to_id = a.id AND voided_at IS NULL) - '
          '(SELECT COALESCE(SUM(amount), 0) FROM bank_txns '
          ' WHERE from_id = a.id AND voided_at IS NULL) AS balance '
          'FROM bank_accounts a',
          readsFrom: {_db.bankAccounts, _db.bankTxns},
        )
        .get();
    return {for (final r in rows) r.read<int>('id'): r.read<int>('balance')};
  }

  // Money moves

  /// Records a money move unless [ref] was used before; true when it was
  /// recorded.
  Future<bool> addTxn({
    required TxnKind kind,
    int? fromId,
    int? toId,
    required int amount,
    required LogicalDay day,
    required DateTime at,
    String title = '',
    String note = '',
    String? ref,
    String? groupId,
    String? fixedId,
    String? category,
  }) async {
    assert(amount > 0 && (fromId != null || toId != null));
    if (ref != null && await hasRef(ref)) return false;
    await _db
        .into(_db.bankTxns)
        .insert(
          BankTxnsCompanion.insert(
            uid: newUid(),
            kind: kind,
            fromId: Value(fromId),
            toId: Value(toId),
            amount: amount,
            day: day,
            at: at,
            title: Value(title),
            note: Value(note),
            ref: Value(ref),
            groupId: Value(groupId),
            fixedId: Value(fixedId),
            category: Value(category),
          ),
        );
    return true;
  }

  // Notion

  Future<BankTxnRow?> txnByPage(String pageId) => (_db.select(
    _db.bankTxns,
  )..where((t) => t.notionPageId.equals(pageId))).getSingleOrNull();

  Future<BankTxnRow?> txnByUid(String uid) => (_db.select(
    _db.bankTxns,
  )..where((t) => t.uid.equals(uid))).getSingleOrNull();

  /// Rows tied to a Notion page, recorded at [from] or later.
  Future<List<BankTxnRow>> linkedTxns({required DateTime from}) =>
      (_db.select(_db.bankTxns)..where(
            (t) => t.notionPageId.isNotNull() & t.at.isBiggerOrEqualValue(from),
          ))
          .get();

  /// Rows tied to a Notion page that the page has to catch up with: voided
  /// here but not trashed there, or filed under another account here.
  Future<List<BankTxnRow>> txnsToUpdate() =>
      (_db.select(_db.bankTxns)..where(
            (t) =>
                t.notionPageId.isNotNull() &
                ((t.voidedAt.isNotNull() &
                        (t.syncState.isNull() |
                            t.syncState.equals(SyncState.trashed).not())) |
                    (t.voidedAt.isNull() &
                        t.syncState.equals(SyncState.dirty))),
          ))
          .get();

  /// Money spent or earned by hand at [since] or later that Notion has
  /// not seen yet. Automatic moves carry a ref and stay in the bank.
  Future<List<BankTxnRow>> txnsToCreate({required DateTime since}) =>
      (_db.select(_db.bankTxns)
            ..where(
              (t) =>
                  t.kind.isInValues([TxnKind.expense, TxnKind.income]) &
                  t.ref.isNull() &
                  t.notionPageId.isNull() &
                  t.voidedAt.isNull() &
                  (t.syncState.isNull() |
                      t.syncState.equals(SyncState.failed).not()) &
                  t.at.isBiggerOrEqualValue(since),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// Rows from Notion that wait to be filed under an account.
  Future<List<BankTxnRow>> inbox() =>
      (_db.select(_db.bankTxns)
            ..where((t) => t.inbox.equals(true) & t.voidedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.desc(t.day),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<int> insertTxn(BankTxnsCompanion row) =>
      _db.into(_db.bankTxns).insert(row);

  Future<void> patchTxn(int id, BankTxnsCompanion change) =>
      (_db.update(_db.bankTxns)..where((t) => t.id.equals(id))).write(change);

  Future<bool> hasRef(String ref) async =>
      await (_db.select(
        _db.bankTxns,
      )..where((t) => t.ref.equals(ref))).getSingleOrNull() !=
      null;

  Future<BankTxnRow?> txn(int id) => (_db.select(
    _db.bankTxns,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Newest first; only those touching [accountId] when given.
  Future<List<BankTxnRow>> txns({int? accountId, int? limit}) {
    final q = _db.select(_db.bankTxns);
    if (accountId != null) {
      q.where((t) => t.fromId.equals(accountId) | t.toId.equals(accountId));
    }
    q.orderBy([
      (t) => OrderingTerm.desc(t.day),
      (t) => OrderingTerm.desc(t.at),
      (t) => OrderingTerm.desc(t.id),
    ]);
    if (limit != null) q.limit(limit);
    return q.get();
  }

  /// Voids [row] and the rows grouped with it.
  Future<void> voidTxn(BankTxnRow row, DateTime at) {
    final q = _db.update(_db.bankTxns);
    final group = row.groupId;
    if (group == null) {
      q.where((t) => t.id.equals(row.id));
    } else {
      q.where((t) => t.groupId.equals(group));
    }
    return q.write(BankTxnsCompanion(voidedAt: Value(at)));
  }

  /// Days from [from] to [to] whose meal money was handed out.
  Future<Set<LogicalDay>> mealDays(LogicalDay from, LogicalDay to) async {
    final rows =
        await (_db.select(_db.bankTxns)..where(
              (t) =>
                  t.kind.equalsValue(TxnKind.meal) &
                  t.day.isBetweenValues(from.toKey(), to.toKey()),
            ))
            .get();
    return {for (final r in rows) r.day};
  }

  /// What was paid towards each fixed cost out of what the vault set aside.
  Future<Map<String, int>> paidFromReserves() async {
    final rows = await _db
        .customSelect(
          'SELECT fixed_id, SUM(amount) AS paid FROM bank_txns '
          "WHERE fixed_id IS NOT NULL AND kind = 'expense' "
          'AND voided_at IS NULL GROUP BY fixed_id',
          readsFrom: {_db.bankTxns},
        )
        .get();
    return {
      for (final r in rows) r.read<String>('fixed_id'): r.read<int>('paid'),
    };
  }

  // Months

  Future<BankMonthRow?> month(String key) => (_db.select(
    _db.bankMonths,
  )..where((t) => t.month.equals(key))).getSingleOrNull();

  Future<BankMonthRow?> latestMonth() =>
      (_db.select(_db.bankMonths)
            ..orderBy([(t) => OrderingTerm.desc(t.month)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<BankMonthRow>> months() => (_db.select(
    _db.bankMonths,
  )..orderBy([(t) => OrderingTerm.asc(t.month)])).get();

  Future<void> insertMonth({
    required String key,
    required LogicalDay firstDay,
    required BankConfig config,
    required List<int> mealPlan,
    required Map<String, int> reserves,
    required int refill,
    required DateTime at,
  }) => _db
      .into(_db.bankMonths)
      .insert(
        BankMonthsCompanion.insert(
          month: key,
          firstDay: firstDay,
          configJson: jsonEncode(config.toJson()),
          mealPlanJson: jsonEncode(mealPlan),
          reservesJson: Value(jsonEncode(reserves)),
          refill: refill,
          openedAt: at,
        ),
      );

  Future<void> closeMonth(String key, DateTime at) =>
      (_db.update(_db.bankMonths)..where((t) => t.month.equals(key))).write(
        BankMonthsCompanion(closedAt: Value(at)),
      );
}

extension BankMonthRowX on BankMonthRow {
  List<int> get mealPlan => [
    for (final v in jsonDecode(mealPlanJson) as List) (v as num).toInt(),
  ];

  Map<String, int> get reserves => {
    for (final e in (jsonDecode(reservesJson) as Map).entries)
      '${e.key}': (e.value as num).toInt(),
  };

  BankConfig get config => BankConfig.fromJson(jsonDecode(configJson));

  /// The day [day]'s meal money, or null when [day] is not in this month.
  int? mealOn(LogicalDay day) {
    final i = day.differenceInDays(firstDay);
    final plan = mealPlan;
    return i >= 0 && i < plan.length ? plan[i] : null;
  }

  LogicalDay get lastDay => firstDay.addDays(mealPlan.length - 1);
}
