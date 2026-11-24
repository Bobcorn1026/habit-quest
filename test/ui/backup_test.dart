import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/app/focus_service.dart';
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/data/backup.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/ui/pixel/pixel.dart';
import 'package:habit_quest/ui/screens/settings/settings_screen.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('exporting hands a dated backup to the system', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const SettingsScreen());

    await tester.tap(find.text('匯出備份'));
    await h.settle(tester);

    expect(h.files.savedName, 'habit_quest-backup-2026-11-09.json');
    final backup = BackupService(h.db).inspect(h.files.savedContent!);
    expect(backup.counts['habits'], 4);
    expect(find.text('備份已匯出'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('restoring asks first, then replaces everything', (tester) async {
    final h = AppHarness();
    final empty = AppDatabase(NativeDatabase.memory());
    h.files.toOpen = await tester.runAsync(() async {
      await h.seed();
      final text = await BackupService(empty).export(testNow);
      await empty.close();
      return text;
    });
    await h.pump(tester);

    await tester.tap(find.text('角色'));
    await h.settle(tester);
    await tester.tap(find.text('設定'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('從備份還原'));
    await h.settle(tester);

    expect(find.text('從備份還原？'), findsOneWidget);
    expect(find.textContaining('習慣 0 個'), findsOneWidget);
    await tester.tap(find.text('還原'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));

    final habits = await tester.runAsync(() => HabitRepository(h.db).active());
    expect(habits, isEmpty);
    expect(find.text('勇者日課'), findsOneWidget, reason: 'back to the start');
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('starting over needs the words, then wipes all but the keys', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await h.secrets.write(SecretKeys.claude, 'sk-test');
    });
    h.reminders.once[kBreakNotificationId] = PlannedReminder(
      id: kBreakNotificationId,
      when: testNow,
      title: '修練場',
      body: '休息結束了',
    );
    await h.pump(tester);

    await tester.tap(find.text('角色'));
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
    expect(find.text('要從頭開始嗎？'), findsOneWidget);

    // A backup first, from inside the dialog.
    await tester.tap(find.text('先匯出備份'));
    await h.settle(tester);
    expect(h.files.savedName, 'habit_quest-backup-2026-11-09.json');
    await tester.pump(const Duration(seconds: 2));

    // Locked until the words are typed.
    final typed = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    final wipe = find.widgetWithText(PixelButton, '全部清除');
    expect(tester.widget<PixelButton>(wipe).onPressed, isNull);
    await tester.enterText(typed, '從頭開');
    await tester.pump();
    expect(tester.widget<PixelButton>(wipe).onPressed, isNull);
    await tester.enterText(typed, '從頭開始');
    await tester.pump();
    await tester.tap(wipe);
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));

    final (habits, accounts, onboarded, key) = (await tester.runAsync(
      () async => (
        await HabitRepository(h.db).active(),
        await h.db.select(h.db.bankAccounts).get(),
        await SettingsRepository(h.db).read(SettingKeys.onboarded),
        await h.secrets.read(SecretKeys.claude),
      ),
    ))!;
    expect(habits, isEmpty);
    expect(accounts, isEmpty);
    expect(onboarded, isNull);
    expect(key, 'sk-test', reason: 'the Keychain is kept');
    expect(h.reminders.once, isEmpty, reason: 'no break left to ring');
    expect(find.text('勇者日課'), findsOneWidget, reason: 'back to the start');
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('a file that is not a backup is refused', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    h.files.toOpen = 'not a backup';
    await h.pump(tester, home: const SettingsScreen());

    await tester.tap(find.text('從備份還原'));
    await h.settle(tester);

    expect(find.textContaining('不是勇者日課的備份檔'), findsOneWidget);
    expect(find.text('從備份還原？'), findsNothing);
    final habits = await tester.runAsync(() => HabitRepository(h.db).active());
    expect(habits, hasLength(4));
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('the adventure record exports as Markdown', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const SettingsScreen());
    await tester.tap(find.textContaining('匯出冒險紀錄'));
    await h.settle(tester);
    expect(h.files.savedName, 'habit_quest-record-2026-11-09.md');
    expect(h.files.savedContent, contains('亞倫 的冒險紀錄'));
    await h.dispose(tester);
  });
}
