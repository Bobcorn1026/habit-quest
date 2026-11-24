import 'package:flutter/foundation.dart';

/// What an account of the bank is for. Plain envelopes have no role.
enum AccountRole {
  /// The money nobody has assigned: the real account minus everything else.
  /// Hidden; shown as the vault.
  central,

  /// What the casino pays out from. Hidden.
  pool,

  /// The everyday envelope; transfers out of it are free.
  general,

  /// Filled a little each day; can't be transferred out of and is reset
  /// when the month ends.
  meal,

  /// Where the casino's leftovers go.
  invest,
}

/// Roles whose accounts the player never sees as an envelope.
const kSystemRoles = {AccountRole.central, AccountRole.pool};

/// Roles whose accounts can't be archived.
const kKeptRoles = {
  AccountRole.central,
  AccountRole.pool,
  AccountRole.general,
  AccountRole.meal,
  AccountRole.invest,
};

/// What moved the money. Stored by name: never rename a value.
enum TxnKind {
  /// The vault's balance when the bank was opened.
  opening,

  /// Money from outside, by hand or the monthly income.
  income,

  /// Money spent outside.
  expense,

  /// A monthly fixed cost charged to the vault.
  fixed,

  /// A day's meal money, vault to meal envelope.
  meal,

  /// The monthly top-up of the casino's pool from the vault.
  refill,

  /// What the meal envelope had left when the month ended, to the pool.
  mealSweep,

  /// The meal envelope's overdraft covered when the month ended.
  mealCover,

  /// Between envelopes.
  transfer,

  /// The fee of a transfer, to the pool.
  fee,

  /// A correction so the bank matches the real account.
  adjust,

  /// A casino prize, pool to envelope.
  prize,

  /// What a casino week left undrawn, partly to the invest envelope.
  invest,
}

/// Kinds the player may undo: what was recorded by hand (a transfer with
/// its fee), and the monthly income and fixed costs (a month they didn't
/// happen).
const kVoidableKinds = {
  TxnKind.income,
  TxnKind.expense,
  TxnKind.fixed,
  TxnKind.transfer,
  TxnKind.fee,
  TxnKind.adjust,
};

/// `bank_txns.sync_state` of rows tied to a Notion page.
abstract final class SyncState {
  /// Matches its page.
  static const synced = 'synced';

  /// Filed under another account here; the page still says the old one.
  static const dirty = 'dirty';

  /// Voided, and its page is in the trash (or gone for good).
  static const trashed = 'trashed';

  /// Recorded here; its page is being made. Seen again, the page may exist
  /// already, so it is looked up by App ID before making another.
  static const creating = 'creating';

  /// Recorded here; Notion turned the page down for good (the reason was
  /// shown once). Not tried again.
  static const failed = 'failed';
}

/// A cost that comes every month: charged to the vault on the 1st, or only
/// set aside in it ([reserve]) for a bill that comes once a year.
@immutable
class FixedCost {
  const FixedCost({
    required this.id,
    required this.name,
    required this.amount,
    this.reserve = false,
  });

  factory FixedCost.fromJson(Map<Object?, Object?> json) => FixedCost(
    id: '${json['id']}',
    name: '${json['name']}',
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    reserve: json['reserve'] == true,
  );

  final String id;
  final String name;
  final int amount;
  final bool reserve;

  FixedCost copyWith({String? name, int? amount, bool? reserve}) => FixedCost(
    id: id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    reserve: reserve ?? this.reserve,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    if (reserve) 'reserve': true,
  };

  @override
  bool operator ==(Object other) =>
      other is FixedCost &&
      other.id == id &&
      other.name == name &&
      other.amount == amount &&
      other.reserve == reserve;

  @override
  int get hashCode => Object.hash(id, name, amount, reserve);
}

/// The monthly numbers of the bank as the player set them. A month keeps
/// the numbers it opened with; a change counts from the next month.
@immutable
class BankConfig {
  const BankConfig({
    this.income = 10000,
    this.meal = 5000,
    this.mealMin = 120,
    this.mealMax = 220,
    this.fixed = const [
      FixedCost(id: 'gym', name: '健身房', amount: 800),
      FixedCost(id: 'subscription', name: '年費訂閱', amount: 300, reserve: true),
    ],
  });

  /// Missing or broken fields fall back to [defaults]: the player's own
  /// numbers from the local profile, or the generic ones in the code.
  factory BankConfig.fromJson(
    Object? json, {
    BankConfig defaults = const BankConfig(),
  }) {
    if (json is! Map) return defaults;
    final d = defaults;
    int amount(Object? value, int fallback) =>
        value is num && value >= 0 ? value.toInt() : fallback;
    final fixed = json['fixed'];
    return BankConfig(
      income: amount(json['income'], d.income),
      meal: amount(json['meal'], d.meal),
      mealMin: amount(json['mealMin'], d.mealMin),
      mealMax: amount(json['mealMax'], d.mealMax),
      fixed: fixed is List
          ? [
              for (final f in fixed)
                if (f is Map) FixedCost.fromJson(f),
            ]
          : d.fixed,
    );
  }

  /// Comes into the vault on the 1st.
  final int income;

  /// The month's meal money, handed out day by day.
  final int meal;

  /// Bounds of one day's meal money.
  final int mealMin;
  final int mealMax;

  final List<FixedCost> fixed;

  /// What is left for the casino's pool each month.
  int get refill {
    final left = income - meal - fixed.fold<int>(0, (sum, f) => sum + f.amount);
    return left < 0 ? 0 : left;
  }

  BankConfig copyWith({
    int? income,
    int? meal,
    int? mealMin,
    int? mealMax,
    List<FixedCost>? fixed,
  }) => BankConfig(
    income: income ?? this.income,
    meal: meal ?? this.meal,
    mealMin: mealMin ?? this.mealMin,
    mealMax: mealMax ?? this.mealMax,
    fixed: fixed ?? this.fixed,
  );

  Map<String, Object?> toJson() => {
    'income': income,
    'meal': meal,
    'mealMin': mealMin,
    'mealMax': mealMax,
    'fixed': [for (final f in fixed) f.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      other is BankConfig &&
      other.income == income &&
      other.meal == meal &&
      other.mealMin == mealMin &&
      other.mealMax == mealMax &&
      listEquals(other.fixed, fixed);

  @override
  int get hashCode =>
      Object.hash(income, meal, mealMin, mealMax, Object.hashAll(fixed));
}

/// An envelope the bank starts with.
@immutable
class DefaultAccount {
  const DefaultAccount(this.name, this.icon, this.weight, [this.role]);
  final String name;
  final String icon;

  /// Share of the casino's prizes (M3).
  final int weight;
  final AccountRole? role;
}

/// The envelopes a new bank opens with, in the order shown.
const kDefaultAccounts = [
  DefaultAccount('通用', 'general', 30, AccountRole.general),
  DefaultAccount('餐費', 'meal', 0, AccountRole.meal),
  DefaultAccount('額外食物', 'snack', 15),
  DefaultAccount('社交', 'social', 15),
  DefaultAccount('遊戲', 'game', 10),
  DefaultAccount('其他娛樂', 'fun', 10),
  DefaultAccount('外表', 'looks', 10),
  DefaultAccount('專案', 'project', 10),
  DefaultAccount('投資', 'invest', 0, AccountRole.invest),
];
