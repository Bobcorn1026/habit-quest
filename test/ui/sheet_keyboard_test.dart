import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_config.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/data/settings_repository.dart';

import '../support/app_harness.dart';

/// iPhone 12 Pro: 390×844 pt, notch 47 pt, home bar 34 pt.
const _height = 844.0;
const _top = 47.0;
const _keyboard = 336.0;

void main() {
  Future<AppHarness> start(WidgetTester tester) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.aiConfig,
        const AiConfig(mode: AiMode.offline).toJson(),
      );
    });
    await h.pump(tester);
    return h;
  }

  /// Shrinks the screen to a phone and raises the keyboard under an open
  /// sheet, then checks nothing overflows and [button] can be scrolled to
  /// above the keyboard.
  Future<void> raiseKeyboard(
    WidgetTester tester,
    AppHarness h, {
    required String title,
    required String button,
  }) async {
    tester.view.physicalSize = const Size(1170, _height * 3);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: _top * 3, bottom: 34 * 3);
    tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard * 3);
    await h.settle(tester);
    expect(tester.takeException(), isNull, reason: 'the sheet overflowed');

    expect(
      tester.getTopLeft(find.textContaining(title)).dy,
      greaterThanOrEqualTo(_top),
      reason: 'the sheet runs under the status bar',
    );

    await tester.ensureVisible(find.text(button));
    await tester.pump();
    expect(
      tester.getBottomLeft(find.text(button)).dy,
      lessThanOrEqualTo(_height - _keyboard),
      reason: '「$button」 stays hidden behind the keyboard',
    );
  }

  testWidgets('the habit form fits a phone with the keyboard up', (
    tester,
  ) async {
    final h = await start(tester);
    await tester.tap(find.text('角色').last);
    await h.settle(tester);
    await tester.tap(find.text('修改').first);
    await h.settle(tester);
    await raiseKeyboard(tester, h, title: '想養成的習慣', button: '付出代價並修改');
    await h.dispose(tester);
  });

  testWidgets('the check-in sheet fits a phone with the keyboard up', (
    tester,
  ) async {
    final h = await start(tester);
    await tester.tap(find.text('完成').first);
    await h.settle(tester);
    await raiseKeyboard(tester, h, title: '回報：', button: '回報冒險成果');
    await h.dispose(tester);
  });

  testWidgets('the bank\'s expense sheet fits a phone with the keyboard up', (
    tester,
  ) async {
    final h = await start(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HabitQuestApp)),
    );
    await tester.runAsync(
      () => container.read(bankServiceProvider).open(balance: 1000),
    );
    await tester.tap(find.text('城鎮').last);
    await h.settle(tester);
    await tester.tap(find.text('銀行'));
    await h.settle(tester);
    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await raiseKeyboard(tester, h, title: '金額（元）', button: '記下');
    await h.dispose(tester);
  });

  testWidgets('the start-over sheet fits a phone with the keyboard up', (
    tester,
  ) async {
    final h = await start(tester);
    await tester.tap(find.text('角色').last);
    await h.settle(tester);
    await tester.tap(find.text('設定'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(
      find.text('從頭開始'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('從頭開始'));
    await h.settle(tester);
    await raiseKeyboard(tester, h, title: '要從頭開始嗎？', button: '全部清除');
    await h.dispose(tester);
  });
}
