import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/ui/screens/settings/settings_screen.dart';

import '../support/app_harness.dart';

void main() {
  Future<int> savedDays(WidgetTester tester, AppHarness h) async =>
      (await tester.runAsync(() => SettingsRepository(h.db).storyConfig()))!
          .periodDays;

  testWidgets('a chapter can span any number of days', (tester) async {
    final h = AppHarness();
    await h.pump(tester, home: const SettingsScreen());
    expect(find.text('每章 7 天'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('＋'));
      await h.settle(tester);
    }
    expect(find.text('每章 10 天'), findsOneWidget);
    expect(await savedDays(tester, h), 10);

    await tester.tap(find.text('－'));
    await h.settle(tester);
    expect(find.text('每章 9 天'), findsOneWidget);
    expect(await savedDays(tester, h), 9);
    await h.dispose(tester);
  });

  testWidgets('the usual 3, 7 and 14 days stay one tap away', (tester) async {
    final h = AppHarness();
    await h.pump(tester, home: const SettingsScreen());
    await tester.tap(find.text('14 天'));
    await h.settle(tester);
    expect(find.text('每章 14 天'), findsOneWidget);
    expect(await savedDays(tester, h), 14);
    await tester.tap(find.text('3 天'));
    await h.settle(tester);
    expect(await savedDays(tester, h), 3);
    await h.dispose(tester);
  });

  testWidgets('the range runs from 1 to 28 days and stops there', (
    tester,
  ) async {
    final h = AppHarness();
    await h.pump(tester, home: const SettingsScreen());
    for (var i = 0; i < 40; i++) {
      await tester.tap(find.text('＋'));
      await tester.pump();
    }
    await h.settle(tester);
    expect(find.text('每章 28 天'), findsOneWidget);
    expect(await savedDays(tester, h), 28);
    for (var i = 0; i < 40; i++) {
      await tester.tap(find.text('－'));
      await tester.pump();
    }
    await h.settle(tester);
    expect(find.text('每章 1 天'), findsOneWidget);
    expect(await savedDays(tester, h), 1);
    await h.dispose(tester);
  });
}
