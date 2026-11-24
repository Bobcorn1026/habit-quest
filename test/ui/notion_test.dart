import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/ai_providers.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/notion_sync.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/notion/ledger.dart';
import 'package:habit_quest/ui/screens/bank/bank_forms.dart';
import 'package:habit_quest/ui/screens/bank/bank_screen.dart';
import 'package:habit_quest/ui/screens/settings/settings_screen.dart';

import '../support/app_harness.dart';
import '../support/fake_notion.dart';

void main() {
  late AppHarness h;
  late FakeNotion notion;
  late MemorySecretStore secrets;

  void later([int minutes = 10]) =>
      h.clock.value = h.clock.value.add(Duration(minutes: minutes));

  /// The bank opened and, when [linked], the ledger linked an hour ago.
  Future<void> start(
    WidgetTester tester, {
    required Widget home,
    bool linked = true,
    void Function()? before,
  }) async {
    h = AppHarness();
    notion = FakeNotion(now: () => h.clock.value);
    secrets = MemorySecretStore();
    h
      ..secrets = secrets
      ..extraOverrides = [httpClientProvider.overrideWithValue(notion.client)];
    await tester.runAsync(() async {
      await h.seed();
      final container = ProviderContainer(overrides: h.overrides);
      await container.read(bankServiceProvider).open(balance: 20000);
      if (linked) {
        await secrets.write(SecretKeys.notion, notion.token);
        await SettingsRepository(
          h.db,
        ).write(SettingKeys.notion, NotionLink(since: h.clock.value).toJson());
      }
      if (before != null) {
        h.clock.value = h.clock.value.add(const Duration(minutes: 5));
        before();
        // Drift locks up when the screen already listens, so the sync
        // that brings rows in runs before the first pump.
        await container.read(notionSyncProvider).sync();
      }
      container.dispose();
    });
    later();
    await h.pump(tester, home: home);
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(HabitQuestApp)));

  /// Lets a sync started by the UI finish.
  Future<void> drain(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await h.settle(tester);
    }
  }

  Future<List<BankTxnRow>> txns(WidgetTester tester) async => (await tester
      .runAsync(() => container(tester).read(bankRepoProvider).txns()))!;

  testWidgets('settings: save the token, link, sync', (tester) async {
    await start(tester, home: const SettingsScreen(), linked: false);
    await tester.ensureVisible(find.text('Notion 記帳本'));
    expect(find.text('開始連動'), findsOneWidget);
    expect(find.text('Notion 金鑰：尚未設定'), findsOneWidget);

    await tester.enterText(
      find.ancestor(of: find.text('ntn_…'), matching: find.byType(TextField)),
      notion.token,
    );
    await tester.ensureVisible(find.text('儲存金鑰'));
    await tester.tap(find.text('儲存金鑰'));
    await h.settle(tester);
    expect(await secrets.read(SecretKeys.notion), notion.token);

    await tester.ensureVisible(find.text('開始連動'));
    await tester.tap(find.text('開始連動'));
    await drain(tester);
    expect(find.text('記帳本連上了'), findsOneWidget);
    expect(find.textContaining('起新記的帳'), findsOneWidget);
    expect(find.textContaining('上次同步：'), findsOneWidget);

    later();
    notion.addRow(title: '襪子', category: '購物');
    await tester.ensureVisible(find.text('立即同步'));
    await tester.tap(find.text('立即同步'));
    await drain(tester);
    expect(find.text('同步好了'), findsOneWidget);
    expect((await txns(tester)).where((t) => t.title == '襪子'), hasLength(1));
    await h.dispose(tester);
  });

  testWidgets('settings: a token Notion turns down says why', (tester) async {
    await start(tester, home: const SettingsScreen(), linked: false);
    await tester.runAsync(() => secrets.write(SecretKeys.notion, 'wrong'));
    await tester.ensureVisible(find.text('開始連動'));
    await tester.tap(find.text('開始連動'));
    await drain(tester);
    expect(find.text('金鑰不對，請重新貼一次'), findsOneWidget);
    expect(find.text('開始連動'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('bank: rows waiting for an account are filed from the list', (
    tester,
  ) async {
    late String id;
    await start(
      tester,
      home: const BankScreen(),
      before: () =>
          id = notion.addRow(title: '耳機', amount: 1200, category: '3C 電子'),
    );
    expect(find.text('待分類'), findsOneWidget);
    expect(find.text('耳機'), findsOneWidget);

    await tester.tap(find.text('耳機'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('這筆要算哪個帳戶？'), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(FileSheet), matching: find.text('專案')),
    );
    await tester.pump();
    await tester.tap(find.text('確定'));
    await drain(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('待分類'), findsNothing);
    expect(notion.selectOf(id, LedgerProps.account), '專案');
    await h.dispose(tester);
  });

  testWidgets('bank: once linked, money recorded here takes a category', (
    tester,
  ) async {
    await start(tester, home: const BankScreen());
    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('分類（寫進 Notion）'), findsOneWidget);
    await tester.enterText(
      find.ancestor(of: find.text('例如 120'), matching: find.byType(TextField)),
      '65',
    );
    await tester.tap(find.text('飲料零食'));
    await tester.pump();
    await tester.ensureVisible(find.text('記下'));
    await tester.tap(find.text('記下'));
    await drain(tester);

    final row = (await txns(tester)).firstWhere((t) => t.amount == 65);
    expect(row.category, '飲料零食');
    final page = notion.fromApp.single;
    expect(notion.selectOf(page, LedgerProps.category), '飲料零食');
    expect(notion.selectOf(page, LedgerProps.account), '餐費');
    await h.dispose(tester);
  });

  testWidgets('bank: not linked, no category', (tester) async {
    await start(tester, home: const BankScreen(), linked: false);
    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('分類（寫進 Notion）'), findsNothing);
    await h.dispose(tester);
  });
}
