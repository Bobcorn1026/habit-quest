import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/app/ai_providers.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/notion_sync.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/domain/bank.dart';
import 'package:habit_quest/notion/ledger.dart';

import '../support/fake_notion.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late FakeNotion notion;
  late MemorySecretStore secrets;
  late ProviderContainer container;
  const nov20 = LogicalDay(2026, 11, 20);

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 20, 9));
    notion = FakeNotion(now: () => clock.value);
    secrets = MemorySecretStore();
    await secrets.write(SecretKeys.notion, notion.token);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        randomProvider.overrideWithValue(math.Random(7)),
        secretStoreProvider.overrideWithValue(secrets),
        httpClientProvider.overrideWithValue(notion.client),
      ],
    );
    await container.read(bankServiceProvider).open(balance: 20000);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  BankService bank() => container.read(bankServiceProvider);
  NotionSync sync() => container.read(notionSyncProvider);
  void later([int minutes = 10]) =>
      clock.value = clock.value.add(Duration(minutes: minutes));

  /// Links at 10:00, after the rows added at 9:00.
  Future<void> link() async {
    clock.value = DateTime(2026, 11, 20, 10);
    expect(await sync().start(), isNull);
  }

  Future<List<BankTxnRow>> synced() async => [
    for (final t in await container.read(bankRepoProvider).txns())
      if (t.notionPageId != null) t,
  ];
  Future<BankTxnRow> byPage(String id) async =>
      (await container.read(bankRepoProvider).txnByPage(id))!;
  Future<BankView> view() => bank().view();
  Future<int> idOf(String name) async =>
      (await view()).accounts.singleWhere((a) => a.name == name).id;
  Future<int> vault() async => (await view()).byRole(AccountRole.central)!.id;
  Future<int> balanceOf(String name) async {
    final v = await view();
    return v.balances[await idOf(name)] ?? 0;
  }

  group('linking', () {
    test('needs a token that can read the ledger', () async {
      await secrets.write(SecretKeys.notion, 'wrong');
      expect((await sync().start())?.badToken, isTrue);
      expect((await sync().link()).linked, isFalse);

      await secrets.write(SecretKeys.notion, notion.token);
      notion.ledgerShared = false;
      expect((await sync().start())?.notShared, isTrue);
      expect((await sync().link()).linked, isFalse);
    });

    test('finds the ledger by its title and the budget through it', () async {
      await link();
      final state = await sync().link();
      expect(state.ledger, kFakeLedger, reason: 'not the look-alike');
      expect(state.budget, kFakeBudget);
      expect(notion.log, contains('POST search'));
    });

    test(
      'a link from before the search finds the ledger on its next sync',
      () async {
        await link();
        final old = (await sync().link()).toJson()
          ..remove('ledger')
          ..remove('budget');
        await container
            .read(settingsRepoProvider)
            .write(SettingKeys.notion, old);
        later();
        final id = notion.addRow(title: '晚餐', amount: 150);
        await sync().sync();
        final state = await sync().link();
        expect(state.error, isNull);
        expect(state.ledger, kFakeLedger);
        expect(state.budget, kFakeBudget);
        expect((await synced()).single.notionPageId, id);
      },
    );

    test('only rows created after the link come in', () async {
      notion.addRow(title: '早上的午餐');
      await link();
      expect(await synced(), isEmpty);

      later();
      final id = notion.addRow(title: '晚餐', amount: 150);
      await sync().sync();
      final rows = await synced();
      expect(rows.single.notionPageId, id);
      expect(rows.single.title, '晚餐');
      expect(rows.single.day, nov20);
      expect(rows.single.kind, TxnKind.expense);
      final state = await sync().link();
      expect(state.error, isNull);
      expect(state.lastSync, clock.value);
    });

    test('stopping keeps what came in', () async {
      await link();
      later();
      notion.addRow();
      await sync().sync();
      await sync().stop();
      expect((await sync().link()).linked, isFalse);
      later();
      notion.addRow(title: '不會進來');
      await sync().sync();
      expect(await synced(), hasLength(1));
    });
  });

  group('from Notion', () {
    setUp(link);

    test('rows go to their 帳戶, or to the account their category '
        'suggests, or wait in the inbox', () async {
      later();
      final meal = notion.addRow(category: '餐飲');
      final game = notion.addRow(category: '飲料零食', account: '遊戲');
      final shop = notion.addRow(title: '襪子', category: '購物');
      final odd = notion.addRow(account: '不存在的帳戶');
      final pay = notion.addRow(
        title: '家教',
        amount: 800,
        income: true,
        category: '家教收入',
      );
      await sync().sync();

      expect((await byPage(meal)).fromId, await idOf('餐費'));
      expect((await byPage(game)).fromId, await idOf('遊戲'));
      for (final id in [shop, odd]) {
        final row = await byPage(id);
        expect(row.fromId, await vault());
        expect(row.inbox, isTrue);
      }
      final income = await byPage(pay);
      expect(income.kind, TxnKind.income);
      expect(income.toId, await vault());
      expect(income.inbox, isFalse);
      expect((await view()).inbox.map((t) => t.notionPageId), [odd, shop]);
    });

    test(
      'rows the bank counts itself, and unfinished rows, stay out',
      () async {
        later();
        notion
          ..addRow(title: '健身房會員', source: '週期扣款', category: '健身保健')
          ..addRow(title: '生活費', income: true, category: '生活費')
          ..addRow(amount: null)
          ..addRow(income: null)
          ..addRow(date: null);
        await sync().sync();
        expect(await synced(), isEmpty);
      },
    );

    test('a second sync changes nothing', () async {
      later();
      notion
        ..addRow()
        ..addRow(category: '購物');
      await sync().sync();
      final first = await synced();
      later();
      await sync().sync();
      expect(await synced(), first);
    });

    test('edits follow, an account set later files the row', () async {
      later();
      final id = notion.addRow(category: '購物');
      await sync().sync();
      expect((await byPage(id)).inbox, isTrue);

      later();
      notion.edit(id, amount: 300, account: '外表', date: '2026-11-19');
      await sync().sync();
      final row = await byPage(id);
      expect(row.amount, 300);
      expect(row.fromId, await idOf('外表'));
      expect(row.inbox, isFalse);
      expect(row.day, const LogicalDay(2026, 11, 19));
      expect(await balanceOf('外表'), -300);
    });

    test(
      'an edit within the same minute as the last read still comes in',
      () async {
        later();
        final id = notion.addRow();
        await sync().sync();
        notion.edit(id, amount: 99); // same clock minute
        await sync().sync();
        expect((await byPage(id)).amount, 99);
      },
    );

    test('trashed rows leave the bank and come back when restored', () async {
      later();
      final id = notion.addRow();
      await sync().sync();
      expect(await balanceOf('餐費'), lessThan(0));

      later();
      notion.trash(id);
      await sync().sync();
      final gone = await byPage(id);
      expect(gone.voidedAt, isNotNull);
      expect(gone.syncState, SyncState.trashed);
      expect(await balanceOf('餐費'), 0);
      // Voided because of Notion: nothing to send back.
      expect(notion.log.where((r) => r.startsWith('PATCH')), isEmpty);

      later();
      notion.trash(id, value: false);
      await sync().sync();
      expect((await byPage(id)).voidedAt, isNull);
      expect(await balanceOf('餐費'), -120);
    });

    test('rows deleted for good leave the bank', () async {
      later();
      final id = notion.addRow();
      await sync().sync();
      notion.deleteForever(id);
      later();
      await sync().sync();
      expect((await byPage(id)).voidedAt, isNotNull);
    });

    test('a row turned into one the bank skips leaves it', () async {
      later();
      final id = notion.addRow();
      await sync().sync();
      later();
      notion.edit(id, category: '生活費');
      await sync().sync();
      expect((await byPage(id)).voidedAt, isNotNull);
    });

    test('a page copied with its App ID becomes a row of its own', () async {
      later();
      await bank().spend(
        accountId: await idOf('遊戲'),
        amount: 500,
        title: '遊戲片',
      );
      await sync().sync();
      final mine = notion.fromApp.single;
      notion.addRow(
        title: '遊戲片',
        amount: 500,
        account: '遊戲',
        source: kSourceApp,
        appId: notion.textOf(mine, LedgerProps.appId),
      );
      later();
      await sync().sync();
      expect(await synced(), hasLength(2));
      expect(await balanceOf('遊戲'), -1000);
    });
  });

  group('from the app', () {
    setUp(link);

    test('money recorded by hand goes to Notion once', () async {
      later();
      await bank().spend(
        accountId: await idOf('餐費'),
        amount: 95,
        title: '拉麵',
        day: nov20,
      );
      await bank().earn(
        accountId: await vault(),
        amount: 600,
        title: '家教',
        category: '家教收入',
      );
      await sync().sync();

      expect(notion.fromApp, hasLength(2));
      final rows = await synced();
      final ramen = rows.singleWhere((t) => t.title == '拉麵');
      final page = ramen.notionPageId!;
      expect(notion.textOf(page, LedgerProps.appId), ramen.uid);
      expect(notion.numberOf(page), 95);
      expect(notion.selectOf(page, LedgerProps.flow), kFlowExpense);
      expect(notion.selectOf(page, LedgerProps.account), '餐費');
      expect(notion.selectOf(page, LedgerProps.category), '餐飲');
      expect(notion.relationOf(page), [
        {'id': 'budget-meal'},
      ]);
      expect(ramen.category, '餐飲');
      final pay = rows.singleWhere((t) => t.title == '家教').notionPageId!;
      expect(notion.selectOf(pay, LedgerProps.account), kVaultName);
      expect(notion.selectOf(pay, LedgerProps.category), '家教收入');
      expect(notion.relationOf(pay), isEmpty);

      later();
      await sync().sync();
      expect(notion.fromApp, hasLength(2));
      expect(await synced(), rows);
    });

    test(
      'the bank\'s own moves and money from before the link stay here',
      () async {
        clock.value = DateTime(2026, 11, 20, 9);
        await bank().spend(accountId: await vault(), amount: 50, title: '早上');
        clock.value = DateTime(2026, 11, 20, 11);
        expect(await bank().claimMeal(nov20), isNotNull);
        expect(await bank().reconcile(30000), isNot(0));
        await sync().sync();
        expect(notion.fromApp, isEmpty);
      },
    );

    test('voiding here trashes the page', () async {
      later();
      await bank().spend(accountId: await idOf('社交'), amount: 300, title: '聚餐');
      await sync().sync();
      final row = (await synced()).single;

      await bank().voidTxn(row.id);
      await sync().sync();
      expect(notion.pages[row.notionPageId]!['in_trash'], isTrue);
      expect((await byPage(row.notionPageId!)).syncState, SyncState.trashed);
      later();
      await sync().sync();
      expect(notion.log.where((r) => r.startsWith('PATCH')), hasLength(1));
    });

    test('voiding a row from Notion trashes its page too', () async {
      later();
      final id = notion.addRow();
      await sync().sync();
      await bank().voidTxn((await byPage(id)).id);
      await sync().sync();
      expect(notion.pages[id]!['in_trash'], isTrue);
    });

    test('filing an inbox row writes its account back', () async {
      later();
      final id = notion.addRow(title: '耳機', category: '3C 電子');
      await sync().sync();
      final row = await byPage(id);
      expect(await bank().file(row.id, await idOf('專案')), isTrue);
      expect(await bank().file(row.id, await idOf('遊戲')), isFalse);
      expect((await byPage(id)).syncState, SyncState.dirty);

      await sync().sync();
      expect(notion.selectOf(id, LedgerProps.account), '專案');
      final filed = await byPage(id);
      expect(filed.syncState, SyncState.synced);
      expect(filed.fromId, await idOf('專案'));
      expect((await view()).inbox, isEmpty);
      later();
      await sync().sync();
      expect((await byPage(id)).fromId, await idOf('專案'));
    });

    test(
      'a page made but never remembered is claimed, not made again',
      () async {
        later();
        await bank().spend(accountId: await idOf('餐費'), amount: 80, title: '麵');
        final row = (await container.read(bankRepoProvider).txns()).firstWhere(
          (t) => t.title == '麵',
        );
        // As if the app stopped right after Notion made the page.
        final id = notion.addRow(
          title: '麵',
          amount: 80,
          account: '餐費',
          source: kSourceApp,
          appId: row.uid,
        );
        await sync().sync();
        expect((await byPage(id)).id, row.id);
        expect(notion.fromApp, [id]);
      },
    );
  });

  test('a failed sync keeps its reason and the next one catches up', () async {
    await link();
    later();
    notion
      ..addRow()
      ..offline = true;
    await sync().sync();
    expect((await sync().link()).error, contains('連不上'));
    expect(await synced(), isEmpty);

    notion.offline = false;
    later();
    await sync().sync();
    expect((await sync().link()).error, isNull);
    expect(await synced(), hasLength(1));
  });

  test('the budget table not being shared only drops the relation', () async {
    await link();
    notion.budgetShared = false;
    later();
    await bank().spend(accountId: await idOf('餐費'), amount: 70, title: '早餐');
    await sync().sync();
    expect((await sync().link()).error, isNull);
    expect(notion.relationOf(notion.fromApp.single), isEmpty);
  });

  test('follows the cursor through many pages', () async {
    await link();
    notion.pageSize = 2;
    later();
    for (var i = 0; i < 5; i++) {
      notion.addRow(title: '第 $i 餐');
    }
    await sync().sync();
    expect(await synced(), hasLength(5));
  });

  group('after the review', () {
    test('linking waits for the bank to open', () async {
      final empty = AppDatabase(NativeDatabase.memory());
      final c = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(empty),
          clockProvider.overrideWithValue(clock),
          secretStoreProvider.overrideWithValue(secrets),
          httpClientProvider.overrideWithValue(notion.client),
        ],
      );
      addTearDown(() async {
        c.dispose();
        await empty.close();
      });
      final s = c.read(notionSyncProvider);
      expect(await s.start(), NotionSync.bankClosed);
      expect(NotionSync.bankClosed.friendly, contains('開戶'));
      expect((await s.link()).linked, isFalse);
    });

    test('relinking keeps rows from the earlier link', () async {
      await link();
      later();
      final id = notion.addRow();
      await sync().sync();
      await sync().stop();
      later(60);
      expect(await sync().start(), isNull);
      later();
      notion.edit(id, amount: 130);
      await sync().sync();
      final row = await byPage(id);
      expect(row.voidedAt, isNull);
      expect(row.amount, 120);
    });

    test('a page whose answer got lost is found, not made again', () async {
      await link();
      later();
      await bank().spend(accountId: await idOf('餐費'), amount: 60, title: '早餐');
      notion.loseNextCreate = true;
      await sync().sync();
      expect((await sync().link()).error, isNotNull);
      final row = (await container.read(bankRepoProvider).txns()).firstWhere(
        (t) => t.title == '早餐',
      );
      expect(row.syncState, SyncState.creating);
      final page = notion.fromApp.single;
      // Not among the edits the next pull reads.
      notion.pages[page]!['last_edited_time'] = '2026-01-01T00:00:00.000Z';

      later();
      await sync().sync();
      expect(notion.fromApp, [page]);
      expect((await byPage(page)).id, row.id);
      expect((await sync().link()).error, isNull);
    });

    test('unlinking during a sync stops it', () async {
      await link();
      later();
      await bank().spend(accountId: await idOf('餐費'), amount: 60, title: '早餐');
      Future<void>? stopping;
      notion.onRequest = (r) {
        if (r.startsWith('POST data_sources')) {
          notion.onRequest = null;
          stopping = sync().stop();
        }
      };
      await sync().sync();
      await stopping;
      expect((await sync().link()).linked, isFalse);
      expect(notion.fromApp, isEmpty);
    });

    test('a page Notion turns down is let go and the rest still go', () async {
      await link();
      later();
      notion.rejectCreates = true;
      await bank().spend(accountId: await idOf('餐費'), amount: 60, title: '早餐');
      await sync().sync();
      expect((await sync().link()).error, contains('400'));

      notion.rejectCreates = false;
      later();
      await bank().spend(accountId: await idOf('餐費'), amount: 90, title: '午餐');
      await sync().sync();
      expect((await sync().link()).error, isNull);
      expect(notion.fromApp.map((id) => notion.textOf(id, LedgerProps.title)), [
        '午餐',
      ]);
      final first = (await container.read(bankRepoProvider).txns()).firstWhere(
        (t) => t.title == '早餐',
      );
      expect(first.syncState, SyncState.failed);
    });

    test('voided here and trashed there does not get stuck', () async {
      await link();
      later();
      final id = notion.addRow();
      await sync().sync();
      await bank().voidTxn((await byPage(id)).id);
      notion.trash(id);
      later();
      await sync().sync();
      expect((await sync().link()).error, isNull);
      expect((await byPage(id)).syncState, SyncState.trashed);
    });

    test('a page restored without a new edit time comes back', () async {
      await link();
      later();
      final id = notion.addRow();
      await sync().sync();
      later();
      notion.trash(id);
      await sync().sync();
      expect((await byPage(id)).voidedAt, isNotNull);
      notion.trash(id, value: false, bump: false);
      later();
      await sync().sync();
      expect((await byPage(id)).voidedAt, isNull);
    });

    test('a sync asked for while one runs ends after the next run', () async {
      await link();
      later();
      notion.addRow();
      notion.log.clear();
      final first = sync().sync();
      final second = sync().sync();
      await second;
      await first;
      expect(
        notion.log.where(
          (r) => r.endsWith('/query') && r.contains(kFakeLedger),
        ),
        hasLength(4),
        reason: 'two runs, two ledger queries each',
      );
      expect(await synced(), hasLength(1));
    });

    test('an answer that makes no sense is kept as the error', () async {
      await link();
      notion.garbage = true;
      later();
      await sync().sync();
      expect((await sync().link()).error, startsWith('同步出錯了'));
    });
  });
}
