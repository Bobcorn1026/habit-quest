import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/bank_repository.dart';
import '../data/casino_repository.dart';
import '../data/database.dart';
import '../data/settings_repository.dart';
import '../domain/bank.dart';
import '../game/bank_rules.dart';
import '../game/game_rules.dart';
import 'local_profile.dart';
import 'providers.dart';

enum TransferResult { done, notAllowed, notEnough, tooSmall }

enum ArchiveResult { done, kept, notEmpty }

/// What the vault has set aside for a yearly bill.
@immutable
class ReserveLine {
  const ReserveLine(this.id, this.name, this.amount);
  final String id;
  final String name;
  final int amount;
}

/// Everything the bank's pages show, read in one go.
@immutable
class BankView {
  const BankView({
    required this.today,
    this.accounts = const [],
    this.balances = const {},
    this.month,
    this.claimed = const {},
    this.reserves = const [],
    this.inbox = const [],
  });

  final LogicalDay today;

  /// All accounts, the hidden ones and the archived ones too.
  final List<BankAccountRow> accounts;
  final Map<int, int> balances;

  /// This month, once the bank is open.
  final BankMonthRow? month;

  /// Days of [month] whose meal money was handed out.
  final Set<LogicalDay> claimed;
  final List<ReserveLine> reserves;

  /// Rows from Notion waiting to be filed under an account; their money
  /// sits in the vault meanwhile.
  final List<BankTxnRow> inbox;

  bool get opened => accounts.any((a) => a.role == AccountRole.central);

  BankAccountRow? byRole(AccountRole role) =>
      accounts.where((a) => a.role == role).firstOrNull;

  int balanceOf(BankAccountRow? account) =>
      account == null ? 0 : balances[account.id] ?? 0;

  /// What the real account holds.
  int get total => balances.values.fold(0, (a, b) => a + b);
  int get vault => balanceOf(byRole(AccountRole.central));
  int get pool => balanceOf(byRole(AccountRole.pool));

  /// The envelopes the player sees.
  List<BankAccountRow> get envelopes => [
    for (final a in accounts)
      if (!kSystemRoles.contains(a.role) && a.archivedAt == null) a,
  ];

  List<BankAccountRow> get archived => [
    for (final a in accounts)
      if (!kSystemRoles.contains(a.role) && a.archivedAt != null) a,
  ];

  /// Today's meal money; null when there is none to hand out today.
  int? get todayMeal {
    final amount = month?.mealOn(today);
    return amount != null && amount > 0 ? amount : null;
  }

  bool get claimedToday => claimed.contains(today);

  /// Earlier days of the month whose meal money is still waiting.
  List<LogicalDay> get missedDays {
    final m = month;
    if (m == null) return const [];
    return [
      for (
        var day = m.firstDay;
        day.isBefore(today) && !day.isAfter(m.lastDay);
        day = day.addDays(1)
      )
        if (!claimed.contains(day) && (m.mealOn(day) ?? 0) > 0) day,
    ];
  }

  /// Meal money of this month still in the vault.
  int get mealAhead {
    final m = month;
    if (m == null) return 0;
    var sum = 0;
    for (var i = 0; i < m.mealPlan.length; i++) {
      if (!claimed.contains(m.firstDay.addDays(i))) sum += m.mealPlan[i];
    }
    return sum;
  }

  /// What the vault holds for yearly bills.
  int get reserved => reserves.fold(0, (sum, r) => sum + r.amount);
}

/// The bank: opening it, turning its months over, and every way the player
/// moves money. All of it in NT dollars, apart from the game's gold.
class BankService {
  BankService({
    required this.clock,
    required this.rules,
    required this.db,
    required this.bank,
    required this.casino,
    required this.settings,
    required this.random,
    this.defaults = const BankConfig(),
  });

  final Clock clock;
  final GameRules rules;
  final AppDatabase db;
  final BankRepository bank;
  final CasinoRepository casino;
  final SettingsRepository settings;
  final math.Random random;

  /// The numbers a bank starts with before the player sets their own.
  final BankConfig defaults;

  LogicalDay _today() =>
      LogicalDay.of(clock.now(), dayStartHour: rules.dayStartHour);

  Future<BankConfig> config() async => BankConfig.fromJson(
    await settings.read(SettingKeys.bank),
    defaults: defaults,
  );

  /// Counts from the next month on.
  Future<void> saveConfig(BankConfig config) =>
      settings.write(SettingKeys.bank, config.toJson());

  Future<bool> isOpen() async =>
      await bank.byRole(AccountRole.central) != null &&
      await bank.latestMonth() != null;

  /// Opens the bank with the vault holding [balance], the real account's
  /// balance today; this month counts from today.
  Future<void> open({required int balance}) => db.transaction(() async {
    if (await isOpen()) return;
    final now = clock.now();
    final today = _today();
    await _ensureAccounts(now);
    final vault = await _id(AccountRole.central);
    if (balance != 0) {
      await bank.addTxn(
        kind: TxnKind.opening,
        fromId: balance < 0 ? vault : null,
        toId: balance > 0 ? vault : null,
        amount: balance.abs(),
        day: today,
        at: now,
        title: '開戶',
        ref: 'opening',
      );
    }
    await _openMonth(today, first: true, now: now);
  });

  /// Opens the bank with made-up money in a few envelopes, as if the casino
  /// had paid out; for trying the pages in a debug build.
  Future<void> openDemo() => db.transaction(() async {
    await open(balance: 20000);
    final v = await view();
    final pool = v.byRole(AccountRole.pool)!.id;
    final now = clock.now();
    for (final (name, amount) in [('通用', 180), ('遊戲', 120), ('社交', 60)]) {
      final envelope = v.envelopes.where((e) => e.name == name).firstOrNull;
      if (envelope == null) continue;
      await bank.addTxn(
        kind: TxnKind.transfer,
        fromId: pool,
        toId: envelope.id,
        amount: amount,
        day: v.today,
        at: now,
        title: '示範獎金',
        ref: 'demo:$name',
      );
    }
    final looks = v.envelopes.where((e) => e.name == '外表').firstOrNull;
    if (looks != null && !await bank.hasRef('demo:looks')) {
      await bank.addTxn(
        kind: TxnKind.expense,
        fromId: looks.id,
        amount: 250,
        day: v.today,
        at: now,
        title: '剪頭髮',
        ref: 'demo:looks',
      );
    }
  });

  Future<void> _ensureAccounts(DateTime now) async {
    if (await bank.byRole(AccountRole.central) == null) {
      await bank.addAccount(
        name: '中央銀行',
        icon: 'vault',
        role: AccountRole.central,
        sortOrder: -2,
        at: now,
      );
    }
    if (await bank.byRole(AccountRole.pool) == null) {
      await bank.addAccount(
        name: '獎池',
        icon: 'pool',
        role: AccountRole.pool,
        sortOrder: -1,
        at: now,
      );
    }
    final hasEnvelopes = (await bank.accounts()).any(
      (a) => !kSystemRoles.contains(a.role),
    );
    for (final (i, d) in kDefaultAccounts.indexed) {
      // A bank restored without some role gets it back; a new bank gets all.
      if (hasEnvelopes &&
          (d.role == null || await bank.byRole(d.role!) != null)) {
        continue;
      }
      await bank.addAccount(
        name: d.name,
        icon: d.icon,
        role: d.role,
        weight: d.weight,
        sortOrder: i,
        at: now,
      );
    }
  }

  Future<int> _id(AccountRole role) async => (await bank.byRole(role))!.id;

  /// Closes the months that ended and opens the ones up to today's. Months
  /// the app was not opened in are run through one by one.
  Future<void> rollover() async {
    final key = monthKeyOf(_today());
    while (true) {
      final latest = await bank.latestMonth();
      if (latest == null || latest.month.compareTo(key) >= 0) return;
      await db.transaction(() async {
        final now = clock.now();
        final row = await bank.month(latest.month);
        if (row == null) return;
        await _closeMonth(row, now);
        await _openMonth(nextMonthStart(row.firstDay), first: false, now: now);
      });
    }
  }

  Future<void> _openMonth(
    LogicalDay firstDay, {
    required bool first,
    required DateTime now,
  }) async {
    final key = monthKeyOf(firstDay);
    if (await bank.month(key) != null) return;
    final config = await this.config();
    final opening = openMonth(
      config: config,
      firstDay: firstDay,
      first: first,
      rng: random,
      rules: rules.bank,
    );
    final vault = await _id(AccountRole.central);
    if (opening.income > 0) {
      await bank.addTxn(
        kind: TxnKind.income,
        toId: vault,
        amount: opening.income,
        day: firstDay,
        at: now,
        title: '每月收入',
        ref: 'income:$key',
      );
    }
    for (final f in config.fixed) {
      final amount = opening.charges[f.id];
      if (amount == null) continue;
      await bank.addTxn(
        kind: TxnKind.fixed,
        fromId: vault,
        amount: amount,
        day: firstDay,
        at: now,
        title: f.name,
        ref: 'fixed:$key:${f.id}',
        fixedId: f.id,
      );
    }
    if (opening.refill > 0) {
      await bank.addTxn(
        kind: TxnKind.refill,
        fromId: vault,
        toId: await _id(AccountRole.pool),
        amount: opening.refill,
        day: firstDay,
        at: now,
        title: '補充獎池',
        ref: 'refill:$key',
      );
    }
    await bank.insertMonth(
      key: key,
      firstDay: firstDay,
      config: config,
      mealPlan: opening.mealPlan,
      reserves: opening.reserves,
      refill: opening.refill,
      at: now,
    );
  }

  /// Hands out the meals nobody claimed and brings the meal envelope back
  /// to zero.
  Future<void> _closeMonth(BankMonthRow row, DateTime now) async {
    if (row.closedAt != null) return;
    final claimed = await bank.mealDays(row.firstDay, row.lastDay);
    final plan = row.mealPlan;
    for (var i = 0; i < plan.length; i++) {
      final day = row.firstDay.addDays(i);
      if (plan[i] > 0 && !claimed.contains(day)) {
        await _claim(day, plan[i], now);
      }
    }
    final balances = await bank.balances();
    final meal = await _id(AccountRole.meal);
    final pool = await _id(AccountRole.pool);
    final vault = await _id(AccountRole.central);
    final close = closeMeal(
      mealBalance: balances[meal] ?? 0,
      poolFree: await poolFree(balances),
    );
    final key = row.month;
    Future<void> move(int amount, int from, int to, String ref) async {
      if (amount <= 0) return;
      await bank.addTxn(
        kind: from == meal ? TxnKind.mealSweep : TxnKind.mealCover,
        fromId: from,
        toId: to,
        amount: amount,
        day: row.lastDay,
        at: now,
        title: from == meal ? '餐費結餘' : '餐費透支',
        ref: ref,
      );
    }

    await move(close.toPool, meal, pool, 'mealsweep:$key');
    await move(close.fromPool, pool, meal, 'mealcover:$key');
    await move(close.fromVault, vault, meal, 'mealcover:$key:vault');
    await bank.closeMonth(key, now);
  }

  /// What the pool has that no casino ticket is waiting for.
  Future<int> poolFree([Map<int, int>? balances]) async =>
      ((balances ?? await bank.balances())[await _id(AccountRole.pool)] ?? 0) -
      await casino.promised();

  Future<bool> _claim(LogicalDay day, int amount, DateTime now) async =>
      bank.addTxn(
        kind: TxnKind.meal,
        fromId: await _id(AccountRole.central),
        toId: await _id(AccountRole.meal),
        amount: amount,
        day: day,
        at: now,
        title: '餐費',
        ref: '$kMealRefPrefix${day.toKey()}',
      );

  /// Hands out [day]'s meal money: its amount, or null when there is none
  /// to hand out (already claimed, not this month, or a day to come).
  Future<int?> claimMeal(LogicalDay day) => db.transaction(() async {
    if (day.isAfter(_today())) return null;
    final row = await bank.month(monthKeyOf(day));
    if (row == null || row.closedAt != null) return null;
    final amount = row.mealOn(day);
    if (amount == null || amount <= 0) return null;
    return await _claim(day, amount, clock.now()) ? amount : null;
  });

  /// Money spent outside from [accountId]; [fixedId] when it pays a fixed
  /// cost out of what the vault set aside for it.
  Future<void> spend({
    required int accountId,
    required int amount,
    required String title,
    String note = '',
    LogicalDay? day,
    String? fixedId,
    String? category,
  }) => bank.addTxn(
    kind: TxnKind.expense,
    fromId: accountId,
    amount: amount,
    day: day ?? _today(),
    at: clock.now(),
    title: title,
    note: note,
    fixedId: fixedId,
    category: category,
  );

  /// Money from outside into [accountId].
  Future<void> earn({
    required int accountId,
    required int amount,
    required String title,
    String note = '',
    LogicalDay? day,
    String? category,
  }) => bank.addTxn(
    kind: TxnKind.income,
    toId: accountId,
    amount: amount,
    day: day ?? _today(),
    at: clock.now(),
    title: title,
    note: note,
    category: category,
  );

  /// Files a row from Notion's inbox under [accountId]; false when it is
  /// not waiting there.
  Future<bool> file(int txnId, int accountId) => db.transaction(() async {
    final row = await bank.txn(txnId);
    if (row == null || !row.inbox || row.voidedAt != null) return false;
    final income = row.kind == TxnKind.income;
    await bank.patchTxn(
      txnId,
      BankTxnsCompanion(
        fromId: income ? const Value.absent() : Value(accountId),
        toId: income ? Value(accountId) : const Value.absent(),
        inbox: const Value(false),
        syncState: row.notionPageId == null
            ? const Value.absent()
            : const Value(SyncState.dirty),
      ),
    );
    return true;
  });

  /// The fee for moving [amount] out of [from]; null when it can't move.
  int? feeFor(BankAccountRow from, int amount) => amount <= 0
      ? null
      : transferFee(amount: amount, fromRole: from.role, rules: rules.bank);

  /// Moves [amount] from one envelope to another; the fee comes out of it
  /// and goes to the pool.
  Future<TransferResult> transfer({
    required int fromId,
    required int toId,
    required int amount,
    String note = '',
  }) => db.transaction(() async {
    final from = await bank.account(fromId);
    final to = await bank.account(toId);
    if (from == null ||
        to == null ||
        fromId == toId ||
        amount <= 0 ||
        from.archivedAt != null ||
        to.archivedAt != null ||
        kSystemRoles.contains(to.role)) {
      return TransferResult.notAllowed;
    }
    final fee = feeFor(from, amount);
    if (fee == null) return TransferResult.notAllowed;
    if (amount - fee <= 0) return TransferResult.tooSmall;
    if ((await bank.balances())[fromId]! < amount) {
      return TransferResult.notEnough;
    }
    final now = clock.now();
    final today = _today();
    final group = bank.newUid();
    await bank.addTxn(
      kind: TxnKind.transfer,
      fromId: fromId,
      toId: toId,
      amount: amount - fee,
      day: today,
      at: now,
      title: '轉帳',
      note: note,
      groupId: group,
    );
    if (fee > 0) {
      await bank.addTxn(
        kind: TxnKind.fee,
        fromId: fromId,
        toId: await _id(AccountRole.pool),
        amount: fee,
        day: today,
        at: now,
        title: '手續費',
        groupId: group,
      );
    }
    return TransferResult.done;
  });

  /// Makes the bank's total match [actual], the real account's balance, by
  /// correcting the vault; the correction made.
  Future<int> reconcile(int actual) => db.transaction(() async {
    final total = (await bank.balances()).values.fold(0, (a, b) => a + b);
    final diff = actual - total;
    if (diff != 0) {
      final vault = await _id(AccountRole.central);
      await bank.addTxn(
        kind: TxnKind.adjust,
        fromId: diff < 0 ? vault : null,
        toId: diff > 0 ? vault : null,
        amount: diff.abs(),
        day: _today(),
        at: clock.now(),
        title: '對帳',
      );
    }
    return diff;
  });

  /// Undoes a move the player may undo (`kVoidableKinds`), with the rows
  /// that go with it; false when it can't be undone.
  Future<bool> voidTxn(int id) => db.transaction(() async {
    final row = await bank.txn(id);
    if (row == null ||
        row.voidedAt != null ||
        !kVoidableKinds.contains(row.kind)) {
      return false;
    }
    await bank.voidTxn(row, clock.now());
    return true;
  });

  Future<int> addEnvelope({required String name, required String icon}) =>
      bank.addAccount(name: name, icon: icon, weight: 10, at: clock.now());

  Future<void> editEnvelope(int id, {String? name, String? icon}) =>
      bank.updateAccount(id, name: name, icon: icon);

  /// Hides an empty envelope; the ones with a role stay.
  Future<ArchiveResult> archive(int id) => db.transaction(() async {
    final account = await bank.account(id);
    if (account == null || kKeptRoles.contains(account.role)) {
      return ArchiveResult.kept;
    }
    if (((await bank.balances())[id] ?? 0) != 0) return ArchiveResult.notEmpty;
    await bank.updateAccount(id, archivedAt: Value(clock.now()));
    return ArchiveResult.done;
  });

  Future<void> unarchive(int id) =>
      bank.updateAccount(id, archivedAt: const Value(null));

  Future<BankView> view() async {
    final today = _today();
    final accounts = await bank.accounts();
    final month = await bank.month(monthKeyOf(today));
    final names = <String, String>{
      for (final m in await bank.months())
        for (final f in m.config.fixed) f.id: f.name,
      for (final f in (await config()).fixed) f.id: f.name,
    };
    final saved = <String, int>{};
    for (final m in await bank.months()) {
      for (final MapEntry(:key, :value) in m.reserves.entries) {
        saved[key] = (saved[key] ?? 0) + value;
      }
    }
    final paid = await bank.paidFromReserves();
    return BankView(
      today: today,
      accounts: accounts,
      balances: await bank.balances(),
      month: month,
      claimed: month == null
          ? const {}
          : await bank.mealDays(month.firstDay, month.lastDay),
      reserves: [
        for (final MapEntry(:key, :value) in saved.entries)
          ReserveLine(
            key,
            names[key] ?? key,
            math.max(0, value - (paid[key] ?? 0)),
          ),
      ],
      inbox: await bank.inbox(),
    );
  }

  /// [view] again after every change to the bank.
  Stream<BankView> watchView() async* {
    yield await view();
    await for (final _ in bank.watchChanges()) {
      yield await view();
    }
  }
}

final bankServiceProvider = Provider<BankService>(
  (ref) => BankService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    db: ref.watch(databaseProvider),
    bank: ref.watch(bankRepoProvider),
    casino: ref.watch(casinoRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    random: ref.watch(randomProvider),
    defaults: ref.watch(localProfileProvider).bank,
  ),
);

/// The bank as of today; follows every change.
final bankViewProvider = StreamProvider<BankView>((ref) {
  ref.watch(todayProvider);
  return ref.watch(bankServiceProvider).watchView();
});

/// The vault's amount is covered up on the bank's pages.
final bankHiddenProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.bankHidden)
      .map((v) => v == true),
);

/// The bank's money moves, newest first; only one account's when given.
final bankTxnsProvider = FutureProvider.family<List<BankTxnRow>, int?>((
  ref,
  accountId,
) {
  // Read again after every change to the bank.
  ref.watch(bankViewProvider);
  return ref.read(bankRepoProvider).txns(accountId: accountId, limit: 400);
});
