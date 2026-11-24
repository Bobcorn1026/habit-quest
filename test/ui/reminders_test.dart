import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/ui/screens/settings/settings_screen.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('turning reminders on asks for permission and saves', (
    tester,
  ) async {
    final h = AppHarness();
    await h.pump(tester, home: const SettingsScreen());
    expect(find.text('提醒時間（當天都回報完就不響）'), findsNothing);

    await tester.tap(find.text('開啟'));
    await h.settle(tester);

    expect(h.reminders.permissionRequests, 1);
    final saved = await tester.runAsync(
      () => SettingsRepository(h.db).read(SettingKeys.reminders),
    );
    expect(ReminderSettings.fromJson(saved).enabled, isTrue);
    expect(find.text('21:00'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('the reminder can be set to any hour and minute', (tester) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.reminders,
        const ReminderSettings(enabled: true).toJson(),
      );
    });
    await h.pump(tester, home: const SettingsScreen());
    expect(find.text('21:00'), findsOneWidget);

    await tester.tap(find.text('21:00'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );
    expect(picker.use24hFormat, isTrue);
    expect(picker.initialDateTime.hour, 21);
    picker.onDateTimeChanged(DateTime(2026, 1, 1, 22, 45));
    await tester.pump();
    await tester.tap(find.text('確定'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));

    final saved = ReminderSettings.fromJson(
      await tester.runAsync<Object?>(
        () => SettingsRepository(h.db).read(SettingKeys.reminders),
      ),
    );
    expect((saved.hour, saved.minute), (22, 45));
    expect(find.text('22:45'), findsOneWidget);
    expect(h.reminders.scheduled.first.when, DateTime(2026, 11, 9, 22, 45));
    await h.dispose(tester);
  });

  testWidgets('closing the time sheet without confirming changes nothing', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await SettingsRepository(h.db).write(
        SettingKeys.reminders,
        const ReminderSettings(enabled: true).toJson(),
      );
    });
    await h.pump(tester, home: const SettingsScreen());
    await tester.tap(find.text('21:00'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2026, 1, 1, 5, 5));
    await tester.pump();
    await tester.tap(find.text('取消'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('21:00'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a refused permission keeps reminders off', (tester) async {
    final h = AppHarness()..reminders.grant = false;
    await h.pump(tester, home: const SettingsScreen());

    await tester.tap(find.text('開啟'));
    await h.settle(tester);

    expect(find.textContaining('沒有通知權限'), findsOneWidget);
    final saved = await tester.runAsync(
      () => SettingsRepository(h.db).read(SettingKeys.reminders),
    );
    expect(ReminderSettings.fromJson(saved).enabled, isFalse);
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('reminders are scheduled while settings is still open', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    expect(h.reminders.scheduled, isEmpty);

    await tester.tap(find.text('角色'));
    await h.settle(tester);
    await tester.tap(find.text('設定'));
    await h.settle(tester);
    // Let the page transition finish so the board's route is covered.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('開啟'));
    await h.settle(tester);

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(h.reminders.scheduled, hasLength(30));
    await h.dispose(tester);
  });

  testWidgets('the board keeps the evening reminder up to date', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.reminders,
        const ReminderSettings(enabled: true).toJson(),
      );
    });
    await h.pump(tester);

    final tonight = h.reminders.scheduled.first;
    expect(tonight.when, DateTime(2026, 11, 9, 21));
    expect(tonight.body, contains('件委託沒回報'));
    expect(h.reminders.scheduled, hasLength(30));
    await h.dispose(tester);
  });

  testWidgets('coming back to the app re-plans from the new day', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.reminders,
        const ReminderSettings(enabled: true).toJson(),
      );
    });
    await h.pump(tester);
    expect(h.reminders.scheduled.first.when, DateTime(2026, 11, 9, 21));

    void go(List<AppLifecycleState> states) {
      for (final s in states) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
    }

    go(const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    h.clock.advance(const Duration(days: 3));
    go(const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    await h.settle(tester);
    expect(h.reminders.scheduled.first.when, DateTime(2026, 11, 12, 21));
    expect(h.reminders.scheduled[2].body, contains('昨天'));
    await h.dispose(tester);
  });
}
