import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/bank.dart';
import 'package:habit_quest/ui/screens/bank/bank_format.dart';
import 'package:habit_quest/ui/screens/bank/bank_screen.dart';

import '../support/app_harness.dart';

void main() {
  test('formatNtd groups thousands; parseNtd reads them back', () {
    expect(formatNtd(0), '0');
    expect(formatNtd(999), '999');
    expect(formatNtd(1276), '1,276');
    expect(formatNtd(-1234567), '-1,234,567');
    expect(parseNtd('1,276'), 1276);
    expect(parseNtd(' -30 '), -30);
    expect(parseNtd('12a'), isNull);
  });

  Future<(AppHarness, ProviderContainer)> start(WidgetTester tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const BankScreen());
    return (
      h,
      ProviderScope.containerOf(tester.element(find.byType(HabitQuestApp))),
    );
  }

  Future<BankView> view(WidgetTester tester, ProviderContainer c) async =>
      (await tester.runAsync(() => c.read(bankServiceProvider).view()))!;

  /// Fills the text field showing [hint].
  Future<void> type(WidgetTester tester, String hint, String value) =>
      tester.enterText(
        find.ancestor(of: find.text(hint), matching: find.byType(TextField)),
        value,
      );

  testWidgets('opening the bank, then claiming the day\'s meal money', (
    tester,
  ) async {
    final (h, c) = await start(tester);
    // Monday 11/9: 22 of 30 days left.
    expect(find.text('開戶'), findsOneWidget);
    expect(find.textContaining('剩 22 天'), findsOneWidget);
    expect(find.textContaining('餐費 3,670、獎池 2,860'), findsOneWidget);

    await type(tester, '例如 20000', '20000');
    await h.settle(tester);
    await tester.tap(find.text('開戶'));
    await h.settle(tester);
    expect(find.text('20,000'), findsOneWidget, reason: 'the total');
    expect(find.text(formatNtd(20000 - 2860)), findsOneWidget, reason: 'vault');
    expect(find.textContaining('其中預留：本月餐費 3,670'), findsOneWidget);
    expect(find.text('領今日餐費'), findsOneWidget);
    for (final name in ['通用', '額外食物', '投資']) {
      expect(find.text(name), findsOneWidget);
    }

    final meal = (await view(tester, c)).todayMeal!;
    await tester.tap(find.text('領今日餐費'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('今日餐費'), findsOneWidget);
    expect(find.text('已放進餐費帳戶：${formatNtd(meal)} 元'), findsOneWidget);
    await tester.tap(find.text('收下'));
    await h.settle(tester);
    expect(find.text('今天的餐費：${formatNtd(meal)}'), findsOneWidget);
    expect(find.text('已領'), findsOneWidget);
    final v = await view(tester, c);
    expect(v.balanceOf(v.byRole(AccountRole.meal)), meal);

    // Covering the vault hides the total too.
    await tester.tap(find.text('遮住'));
    await h.settle(tester);
    expect(find.text('＊＊＊＊'), findsNWidgets(2));
    expect(find.text(formatNtd(20000 - 2860 - meal)), findsNothing);
    await tester.tap(find.text('顯示'));
    await h.settle(tester);
    expect(find.text(formatNtd(20000 - 2860 - meal)), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('an expense can be dated any day, not just the last three', (
    tester,
  ) async {
    final (h, c) = await start(tester);
    await tester.runAsync(
      () => c.read(bankServiceProvider).open(balance: 5000),
    );
    await h.settle(tester);

    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await tester.tap(find.text('其他日期'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(picker.maximumDate, DateTime(2026, 11, 9), reason: 'no future days');
    picker.onDateTimeChanged(DateTime(2026, 10, 20));
    await tester.pump();
    await tester.tap(find.text('確定'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('10/20'), findsOneWidget);

    await type(tester, '例如 120', '350');
    await type(tester, '例如 午餐', '補記的帳');
    await h.settle(tester);
    await tester.tap(find.text('記下'));
    await h.settle(tester);
    final txns = await tester.runAsync(() => c.read(bankRepoProvider).txns());
    final row = txns!.firstWhere((t) => t.title == '補記的帳');
    expect(row.day, const LogicalDay(2026, 10, 20));
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('the quick day buttons still work and replace a picked day', (
    tester,
  ) async {
    final (h, c) = await start(tester);
    await tester.runAsync(
      () => c.read(bankServiceProvider).open(balance: 5000),
    );
    await h.settle(tester);
    await tester.tap(find.text('記支出'));
    await h.settle(tester);

    await tester.tap(find.text('其他日期'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2026, 10, 1));
    await tester.pump();
    await tester.tap(find.text('確定'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('10/1'), findsOneWidget);

    await tester.tap(find.text('昨天'));
    await tester.pump();
    expect(find.text('10/1'), findsNothing);
    expect(find.text('其他日期'), findsOneWidget);
    await type(tester, '例如 120', '60');
    await type(tester, '例如 午餐', '昨天的飲料');
    await h.settle(tester);
    await tester.tap(find.text('記下'));
    await h.settle(tester);
    final txns = await tester.runAsync(() => c.read(bankRepoProvider).txns());
    final row = txns!.firstWhere((t) => t.title == '昨天的飲料');
    expect(row.day, const LogicalDay(2026, 11, 8));
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('recording a meal, moving money and undoing it', (tester) async {
    final (h, c) = await start(tester);
    await tester.runAsync(() async {
      final bank = c.read(bankServiceProvider);
      await bank.open(balance: 5000);
      final v = await bank.view();
      final game = v.envelopes.firstWhere((a) => a.name == '遊戲');
      await bank.earn(accountId: game.id, amount: 300, title: '測試');
    });
    await h.settle(tester);

    // Lunch from the meal envelope (the default) puts it in the red.
    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await type(tester, '例如 120', '120');
    await type(tester, '例如 午餐', '午餐');
    await h.settle(tester);
    await tester.tap(find.text('記下'));
    await h.settle(tester);
    var v = await view(tester, c);
    expect(v.balanceOf(v.byRole(AccountRole.meal)), -120);

    // 100 from games to social: 10 to the pool.
    final pool = v.pool;
    await tester.tap(find.text('轉帳'));
    await h.settle(tester);
    // The page's list, the sheet's "from", the sheet's "to".
    await tester.tap(find.text('遊戲').at(1));
    await h.settle(tester);
    await tester.tap(find.text('社交').last);
    await type(tester, '例如 100', '100');
    await h.settle(tester);
    expect(find.text('手續費 10 元，到帳 90 元'), findsOneWidget);
    await tester.tap(find.text('轉帳').last);
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    v = await view(tester, c);
    final social = v.envelopes.firstWhere((a) => a.name == '社交');
    expect(v.balanceOf(social), 90);
    expect(v.pool, pool + 10);

    // Social's history: tapping the transfer undoes it with its fee.
    await tester.tap(find.text('社交'));
    await h.settle(tester);
    expect(find.text('社交的明細'), findsOneWidget);
    expect(find.text('遊戲 → 社交'), findsOneWidget);
    expect(find.text('+90'), findsOneWidget);
    await tester.tap(find.text('遊戲 → 社交'));
    await h.settle(tester);
    await tester.tap(find.text('作廢'));
    await h.settle(tester);
    expect(find.text('轉帳（已作廢）'), findsOneWidget);
    v = await view(tester, c);
    expect(v.balanceOf(social), 0);
    expect(v.pool, pool);
    await h.dispose(tester);
  });

  testWidgets('reconciling and the monthly settings', (tester) async {
    final (h, c) = await start(tester);
    await tester.runAsync(
      () => c.read(bankServiceProvider).open(balance: 5000),
    );
    await h.settle(tester);

    await tester.tap(find.text('對帳'));
    await h.settle(tester);
    await tester.enterText(find.byType(EditableText), '4800');
    await h.settle(tester);
    expect(find.text('中央銀行會扣掉 200 元'), findsOneWidget);
    await tester.tap(find.text('對帳').last);
    await h.settle(tester);
    expect((await view(tester, c)).total, 4800);

    await tester.tap(find.text('每月設定'));
    await h.settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('每月進賭場獎池：3,900 元'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, '9000');
    await h.settle(tester);
    expect(find.text('每月進賭場獎池：2,900 元'), findsOneWidget);
    await tester.tap(find.text('儲存'));
    await h.settle(tester);
    final config = await tester.runAsync(
      () => c.read(bankServiceProvider).config(),
    );
    expect(config!.income, 9000);
    await h.dispose(tester);
  });
}
