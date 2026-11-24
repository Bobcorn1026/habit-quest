import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/notion/ledger.dart';

Map<String, Object?> _title(String s) => {
  'id': 'title',
  'type': 'title',
  'title': [
    {
      'type': 'text',
      'plain_text': s,
      'text': {'content': s},
    },
  ],
};

Map<String, Object?> _rich(String s) => {
  'type': 'rich_text',
  'rich_text': s.isEmpty
      ? []
      : [
          {
            'type': 'text',
            'plain_text': s,
            'text': {'content': s},
          },
        ],
};

Map<String, Object?> _sel(String? s) => {
  'type': 'select',
  'select': s == null ? null : {'name': s},
};

Map<String, Object?> _page({
  String title = '午餐',
  Object? amount = 120,
  String? flow = '支出',
  String? category = '餐飲',
  String? source,
  String? account,
  String appId = '',
  String? start = '2026-11-20',
  String note = '',
  Map<String, Object?> extra = const {},
}) => {
  'id': 'page-1',
  'created_time': '2026-11-20T01:00:00.000Z',
  'last_edited_time': '2026-11-20T02:00:00.000Z',
  'in_trash': false,
  'properties': {
    LedgerProps.title: _title(title),
    LedgerProps.amount: {'type': 'number', 'number': amount},
    LedgerProps.flow: _sel(flow),
    LedgerProps.category: _sel(category),
    LedgerProps.source: _sel(source),
    LedgerProps.account: _sel(account),
    LedgerProps.appId: _rich(appId),
    LedgerProps.date: {
      'type': 'date',
      'date': start == null ? null : {'start': start},
    },
    LedgerProps.note: _rich(note),
  },
  ...extra,
};

LedgerRow _row({
  int? amount = 100,
  bool? income = false,
  String? category,
  String? source,
  String? account,
  LogicalDay? day = const LogicalDay(2026, 11, 20),
  String title = 'x',
  bool trashed = false,
  DateTime? createdAt,
}) => LedgerRow(
  pageId: 'p',
  editedAt: DateTime.utc(2026, 11, 20),
  createdAt: createdAt ?? DateTime.utc(2026, 11, 20),
  title: title,
  amount: amount,
  income: income,
  category: category,
  source: source,
  account: account,
  day: day,
  trashed: trashed,
);

void main() {
  final since = DateTime.utc(2026, 11, 18);

  group('LedgerRow.parse', () {
    test('reads every field', () {
      final row = LedgerRow.parse(
        _page(source: '捷徑', account: '餐費', appId: 'uid-1', note: '備註文字'),
      );
      expect(row.pageId, 'page-1');
      expect(row.title, '午餐');
      expect(row.amount, 120);
      expect(row.income, false);
      expect(row.category, '餐飲');
      expect(row.source, '捷徑');
      expect(row.account, '餐費');
      expect(row.appId, 'uid-1');
      expect(row.day, const LogicalDay(2026, 11, 20));
      expect(row.note, '備註文字');
      expect(row.trashed, false);
      expect(row.createdAt.toUtc(), DateTime.utc(2026, 11, 20, 1));
      expect(row.editedAt.toUtc(), DateTime.utc(2026, 11, 20, 2));
    });

    test('amount rounds', () {
      expect(LedgerRow.parse(_page(amount: 120.4)).amount, 120);
      expect(LedgerRow.parse(_page(amount: 120.6)).amount, 121);
      expect(LedgerRow.parse(_page(amount: null)).amount, isNull);
    });

    test('income is true, false or null', () {
      expect(LedgerRow.parse(_page(flow: '收入')).income, true);
      expect(LedgerRow.parse(_page(flow: '支出')).income, false);
      expect(LedgerRow.parse(_page(flow: null)).income, isNull);
    });

    test('empty selects and app id read as null', () {
      final row = LedgerRow.parse(_page(category: null));
      expect(row.category, isNull);
      expect(row.source, isNull);
      expect(row.account, isNull);
      expect(row.appId, isNull);
      expect(row.note, '');
    });

    test('day from a datetime start', () {
      final row = LedgerRow.parse(
        _page(start: '2026-11-20T09:30:00.000+08:00'),
      );
      expect(row.day, const LogicalDay(2026, 11, 20));
    });

    test('missing or short start gives null day', () {
      expect(LedgerRow.parse(_page(start: null)).day, isNull);
      expect(LedgerRow.parse(_page(start: '2026-11')).day, isNull);
    });

    test('trashed by in_trash or legacy archived', () {
      expect(LedgerRow.parse(_page(extra: {'in_trash': true})).trashed, true);
      expect(LedgerRow.parse(_page(extra: {'archived': true})).trashed, true);
    });

    test('missing properties and wrong types do not throw', () {
      final row = LedgerRow.parse({'id': 'x'});
      expect(row.title, '');
      expect(row.amount, isNull);
      expect(row.income, isNull);
      expect(row.day, isNull);
      expect(row.trashed, false);

      final odd = LedgerRow.parse({
        'id': 'y',
        'properties': {
          LedgerProps.title: 'oops',
          LedgerProps.amount: {'number': 'abc'},
          LedgerProps.flow: {'select': 'x'},
          LedgerProps.date: {'date': 5},
          LedgerProps.note: {'rich_text': 'nope'},
        },
      });
      expect(odd.title, '');
      expect(odd.amount, isNull);
      expect(odd.income, isNull);
      expect(odd.day, isNull);
      expect(odd.note, '');
      final noProps = LedgerRow.parse({'id': 'z', 'properties': 3});
      expect(noProps.title, '');
    });
  });

  group('planRow', () {
    void expectSkip(LedgerRow row) =>
        expect(planRow(row, since: since), isA<LedgerSkip>());

    test('skips unfinished or counted rows', () {
      expectSkip(_row(trashed: true));
      expectSkip(_row(amount: null));
      expectSkip(_row(amount: 0));
      expectSkip(_row(amount: -5));
      expectSkip(_row(day: null));
      expectSkip(_row(income: null));
      expectSkip(_row(createdAt: DateTime.utc(2026, 11, 17, 23, 59)));
      expectSkip(_row(source: '週期扣款'));
      expectSkip(_row(category: '生活費'));
    });

    test('createdAt equal to since is not skipped', () {
      expect(planRow(_row(createdAt: since), since: since), isA<LedgerEntry>());
    });

    LedgerEntry entry(LedgerRow row) =>
        planRow(row, since: since) as LedgerEntry;

    test('account is the row account when set', () {
      expect(entry(_row(category: '餐飲', account: '遊戲')).account, '遊戲');
    });

    test('account guessed from category', () {
      expect(entry(_row(category: '餐飲')).account, '餐費');
      expect(entry(_row(category: '飲料零食')).account, '額外食物');
      expect(entry(_row(category: '打工', income: true)).account, kVaultName);
      expect(entry(_row(category: '購物')).account, isNull);
      expect(entry(_row(category: '3C 電子')).account, isNull);
      expect(entry(_row(category: '訂閱服務')).account, isNull);
      expect(entry(_row()).account, isNull);
    });

    test('entry carries the fields', () {
      final e = entry(_row(amount: 80, income: true, category: '打工'));
      expect(e.income, true);
      expect(e.amount, 80);
      expect(e.day, const LogicalDay(2026, 11, 20));
      expect(e.category, '打工');
    });

    test('empty title falls back', () {
      expect(entry(_row(title: '', category: '餐飲')).title, '餐飲');
      expect(entry(_row(title: '')).title, '支出');
      expect(entry(_row(title: '', income: true)).title, '收入');
      expect(entry(_row(title: '咖啡', category: '餐飲')).title, '咖啡');
    });
  });

  group('defaultCategory', () {
    test('maps income, known and unknown accounts', () {
      expect(defaultCategory(income: true, account: '餐費'), '其他收入');
      expect(defaultCategory(income: false, account: '餐費'), '餐飲');
      expect(defaultCategory(income: false, account: '遊戲'), '娛樂');
      expect(defaultCategory(income: false, account: '不存在'), '其他支出');
    });
  });

  group('ledgerPage', () {
    Map<String, Object?> build({
      String note = '',
      String? budgetPage,
      String title = '午餐',
    }) => ledgerPage(
      appId: 'uid-1',
      income: false,
      amount: 120,
      day: const LogicalDay(2026, 11, 20),
      title: title,
      category: '餐飲',
      account: '餐費',
      note: note,
      budgetPage: budgetPage,
    );

    test('exact JSON without note or budget', () {
      expect(build(), {
        '品項': {
          'title': [
            {
              'text': {'content': '午餐'},
            },
          ],
        },
        '金額': {'number': 120},
        '收支': {
          'select': {'name': '支出'},
        },
        '分類': {
          'select': {'name': '餐飲'},
        },
        '帳戶': {
          'select': {'name': '餐費'},
        },
        '來源': {
          'select': {'name': kSourceApp},
        },
        '日期': {
          'date': {'start': '2026-11-20'},
        },
        'App ID': {
          'rich_text': [
            {
              'text': {'content': 'uid-1'},
            },
          ],
        },
      });
    });

    test('income select', () {
      final p = ledgerPage(
        appId: 'a',
        income: true,
        amount: 1,
        day: const LogicalDay(2026, 11, 20),
        title: 't',
        category: null,
        account: kVaultName,
      );
      expect(p['收支'], {
        'select': {'name': '收入'},
      });
      expect(p['分類'], {'select': null});
    });

    test('note only when not empty', () {
      expect(build().containsKey('備註'), false);
      expect(build(note: '好吃')['備註'], {
        'rich_text': [
          {
            'text': {'content': '好吃'},
          },
        ],
      });
    });

    test('budget relation only when given', () {
      expect(build().containsKey('預算項目'), false);
      expect(build(budgetPage: 'b-1')['預算項目'], {
        'relation': [
          {'id': 'b-1'},
        ],
      });
    });

    test('long title is clipped to 2000', () {
      final p = build(title: 'a' * 2500);
      final content =
          ((p['品項'] as Map)['title'] as List).first['text']['content']
              as String;
      expect(content.length, 2000);
    });
  });

  test('ledgerAccount', () {
    expect(ledgerAccount('遊戲'), {
      '帳戶': {
        'select': {'name': '遊戲'},
      },
    });
  });

  group('pageTitle', () {
    test('finds the title property by type', () {
      expect(
        pageTitle({
          'properties': {
            '分類': _title(' 餐飲 '),
            '金額': {'type': 'number', 'number': 1},
          },
        }),
        '餐飲',
      );
    });

    test('empty when none', () {
      expect(
        pageTitle({
          'properties': {
            '金額': {'type': 'number'},
          },
        }),
        '',
      );
      expect(pageTitle({}), '');
    });
  });
}
