import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/reminders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');

  test('the daily plan leaves other pending notifications alone', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    IOSFlutterLocalNotificationsPlugin.registerWith();

    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'initialize' ? true : null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    List<Object?> scheduled() => [
      for (final c in calls)
        if (c.method == 'zonedSchedule') (c.arguments as Map)['id'],
    ];
    List<Object?> cancelled() => [
      for (final c in calls)
        if (c.method == 'cancel') c.arguments,
    ];

    // The plugin refuses times in the past, so this follows the real clock.
    final now = DateTime.now();
    final scheduler = LocalReminderScheduler();
    await scheduler.scheduleOnce(
      200,
      now.add(const Duration(minutes: 10)),
      title: '休息結束',
      body: '回修練場吧。',
    );
    expect(scheduled(), [200]);

    // First plan since launch, tonight already reported: ids 2 to 30.
    final plan = planReminders(
      settings: const ReminderSettings(enabled: true, hour: 21),
      now: now,
      dayStartHour: 4,
      pendingToday: 0,
    );
    await scheduler.replaceAll(plan);
    expect(
      calls.map((c) => c.method),
      isNot(contains(startsWith('cancelAll'))),
    );
    expect(cancelled(), [1]);
    expect(scheduled(), [200, for (var id = 2; id <= 30; id++) id]);

    calls.clear();
    await scheduler.scheduleOnce(
      200,
      now.subtract(const Duration(minutes: 1)),
      title: '休息結束',
      body: '已經過了。',
    );
    expect(scheduled(), isEmpty, reason: 'a past time is skipped, not thrown');

    await scheduler.cancel(200);
    expect(cancelled(), [200]);
  });
}
