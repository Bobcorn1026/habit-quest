import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';

/// Title of the player's Notion ledger (記帳 → 收支紀錄). The app finds
/// it by this title among the data sources shared with the integration, so
/// no workspace ids live in the code.
const kLedgerTitle = '收支紀錄';

/// The budget data source that the ledger's 預算項目 relation points to,
/// read from the ledger's [schema]; null when there is no such relation.
String? budgetSourceOf(Map<String, Object?> schema) {
  final props = schema['properties'];
  final budget = props is Map ? props[LedgerProps.budget] : null;
  final relation = budget is Map ? budget['relation'] : null;
  final id = relation is Map ? relation['data_source_id'] : null;
  return id is String ? id : null;
}

/// Property names in 收支紀錄.
abstract final class LedgerProps {
  static const title = '品項';
  static const amount = '金額';
  static const flow = '收支';
  static const category = '分類';
  static const source = '來源';
  static const account = '帳戶';
  static const appId = 'App ID';
  static const date = '日期';
  static const note = '備註';
  static const budget = '預算項目';
}

const kFlowExpense = '支出';
const kFlowIncome = '收入';

/// 來源 of the rows this app writes.
const kSourceApp = '勇者日課';

/// 帳戶 that means the vault.
const kVaultName = '中央';

/// Rows the bank already counts on its own: the monthly fixed costs it
/// charges and the monthly income it records.
const kSkippedSources = {'週期扣款'};
const kSkippedCategories = {'生活費'};

/// The ledger's categories, in its order.
const kExpenseCategories = [
  '餐飲',
  '飲料零食',
  '交通',
  '日用品',
  '購物',
  '3C 電子',
  '學業書籍',
  '娛樂',
  '旅遊',
  '訂閱服務',
  '社交聚會',
  '健身保健',
  '醫療',
  '房租水電',
  '通訊',
  '其他支出',
];
const kIncomeCategories = ['家教收入', '打工', '獎學金', '其他收入'];

/// The account a row with no 帳戶 is guessed into, by category (the
/// player agreed to this table on 2026-11-18). Categories not here go to
/// the inbox. Names are the default account names; a renamed account no
/// longer matches and its rows go to the inbox too.
const kCategoryAccount = {
  '餐飲': '餐費',
  '飲料零食': '額外食物',
  '社交聚會': '社交',
  '娛樂': '其他娛樂',
  '旅遊': '其他娛樂',
  '學業書籍': '專案',
  '日用品': '通用',
  '交通': '通用',
  '通訊': '通用',
  '醫療': '通用',
  '房租水電': '通用',
  '健身保健': '通用',
  '其他支出': '通用',
  '家教收入': kVaultName,
  '打工': kVaultName,
  '獎學金': kVaultName,
  '其他收入': kVaultName,
};

/// The category an expense from an account starts with in the app's form.
const kAccountCategory = {
  '餐費': '餐飲',
  '額外食物': '飲料零食',
  '社交': '社交聚會',
  '遊戲': '娛樂',
  '其他娛樂': '娛樂',
  '外表': '購物',
  '專案': '學業書籍',
};

String defaultCategory({required bool income, required String account}) =>
    income ? '其他收入' : kAccountCategory[account] ?? '其他支出';

/// One page of 收支紀錄, as far as the bank cares.
@immutable
class LedgerRow {
  const LedgerRow({
    required this.pageId,
    required this.editedAt,
    required this.createdAt,
    this.title = '',
    this.amount,
    this.income,
    this.category,
    this.source,
    this.account,
    this.appId,
    this.day,
    this.note = '',
    this.trashed = false,
  });

  /// Reads a page object; properties that are missing or of another type
  /// read as empty.
  factory LedgerRow.parse(Map<String, Object?> page) {
    final props = page['properties'];
    Map<String, Object?> prop(String name) {
      final p = props is Map ? props[name] : null;
      return p is Map ? p.cast<String, Object?>() : const {};
    }

    String text(String name) {
      final p = prop(name);
      final parts = p['title'] ?? p['rich_text'];
      if (parts is! List) return '';
      return parts
          .map((t) => t is Map ? '${t['plain_text'] ?? ''}' : '')
          .join()
          .trim();
    }

    String? select(String name) {
      final s = prop(name)['select'];
      final value = s is Map ? '${s['name'] ?? ''}'.trim() : '';
      return value.isEmpty ? null : value;
    }

    final number = prop(LedgerProps.amount)['number'];
    final date = prop(LedgerProps.date)['date'];
    final start = date is Map ? '${date['start'] ?? ''}' : '';
    final flow = select(LedgerProps.flow);
    final appId = text(LedgerProps.appId);
    return LedgerRow(
      pageId: '${page['id']}',
      editedAt: _time(page['last_edited_time']),
      createdAt: _time(page['created_time']),
      title: text(LedgerProps.title),
      amount: number is num ? number.round() : null,
      income: flow == kFlowIncome
          ? true
          : flow == kFlowExpense
          ? false
          : null,
      category: select(LedgerProps.category),
      source: select(LedgerProps.source),
      account: select(LedgerProps.account),
      appId: appId.isEmpty ? null : appId,
      day: _day(start),
      note: text(LedgerProps.note),
      trashed: page['in_trash'] == true || page['archived'] == true,
    );
  }

  final String pageId;
  final DateTime editedAt;
  final DateTime createdAt;
  final String title;
  final int? amount;

  /// Null when 收支 is empty.
  final bool? income;
  final String? category;
  final String? source;
  final String? account;

  /// The bank row's uid, on rows this app wrote.
  final String? appId;
  final LogicalDay? day;
  final String note;
  final bool trashed;

  static DateTime _time(Object? raw) =>
      DateTime.tryParse('${raw ?? ''}')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  static LogicalDay? _day(String start) {
    if (start.length < 10) return null;
    try {
      return LogicalDay.parse(start.substring(0, 10));
    } on FormatException {
      return null;
    }
  }
}

/// What a ledger row becomes in the bank.
sealed class LedgerPlan {
  const LedgerPlan();
}

/// Not the bank's business: unfinished, before the link, or counted by
/// the bank already.
class LedgerSkip extends LedgerPlan {
  const LedgerSkip(this.reason);
  final String reason;

  static const beforeLink = 'before link';

  /// Created before the link: the bank keeps whatever it already has of
  /// it (from an earlier link) instead of dropping it.
  bool get beforeTheLink => reason == beforeLink;
}

/// A move of money from or to outside.
@immutable
class LedgerEntry extends LedgerPlan {
  const LedgerEntry({
    required this.income,
    required this.amount,
    required this.day,
    required this.account,
    required this.title,
    this.category,
    this.note = '',
  });

  final bool income;
  final int amount;
  final LogicalDay day;

  /// The account by name ([kVaultName] for the vault); null for the inbox.
  final String? account;
  final String title;
  final String? category;
  final String note;
}

/// The bank's reading of [row] for a link made at [since]: only rows
/// created after it count, since the vault's opening balance already holds
/// the older ones.
LedgerPlan planRow(LedgerRow row, {required DateTime since}) {
  final amount = row.amount;
  final day = row.day;
  final income = row.income;
  if (row.trashed) return const LedgerSkip('trashed');
  if (amount == null || amount <= 0) return const LedgerSkip('no amount');
  if (day == null) return const LedgerSkip('no date');
  if (income == null) return const LedgerSkip('no flow');
  if (row.createdAt.isBefore(since)) {
    return const LedgerSkip(LedgerSkip.beforeLink);
  }
  if (kSkippedSources.contains(row.source)) {
    return const LedgerSkip('recurring');
  }
  if (kSkippedCategories.contains(row.category)) {
    return const LedgerSkip('monthly income');
  }
  return LedgerEntry(
    income: income,
    amount: amount,
    day: day,
    account: row.account ?? kCategoryAccount[row.category],
    title: row.title.isEmpty
        ? row.category ?? (income ? '收入' : '支出')
        : row.title,
    category: row.category,
    note: row.note,
  );
}

Map<String, Object?> _text(String value) => {
  'rich_text': [
    {
      'text': {'content': _clip(value)},
    },
  ],
};

String _clip(String value) =>
    value.length <= 2000 ? value : value.substring(0, 2000);

Map<String, Object?> _select(String? name) => {
  'select': name == null ? null : {'name': name},
};

/// Properties of a new page for a move recorded in the app.
Map<String, Object?> ledgerPage({
  required String appId,
  required bool income,
  required int amount,
  required LogicalDay day,
  required String title,
  required String? category,
  required String account,
  String note = '',
  String? budgetPage,
}) => {
  LedgerProps.title: {
    'title': [
      {
        'text': {'content': _clip(title)},
      },
    ],
  },
  LedgerProps.amount: {'number': amount},
  LedgerProps.flow: _select(income ? kFlowIncome : kFlowExpense),
  LedgerProps.category: _select(category),
  LedgerProps.account: _select(account),
  LedgerProps.source: _select(kSourceApp),
  LedgerProps.date: {
    'date': {'start': day.toKey()},
  },
  LedgerProps.appId: _text(appId),
  if (note.isNotEmpty) LedgerProps.note: _text(note),
  if (budgetPage != null)
    LedgerProps.budget: {
      'relation': [
        {'id': budgetPage},
      ],
    },
};

/// The change to send when the player files a row under [account].
Map<String, Object?> ledgerAccount(String account) => {
  LedgerProps.account: _select(account),
};

/// The text of a page's title property, whatever it is called.
String pageTitle(Map<String, Object?> page) {
  final props = page['properties'];
  if (props is! Map) return '';
  for (final p in props.values) {
    if (p is Map && p['type'] == 'title' && p['title'] is List) {
      return (p['title'] as List)
          .map((t) => t is Map ? '${t['plain_text'] ?? ''}' : '')
          .join()
          .trim();
    }
  }
  return '';
}
