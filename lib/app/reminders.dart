import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/logical_day.dart';
import '../data/settings_repository.dart';
import '../game/stacking.dart';
import 'board.dart';
import 'providers.dart';

/// The daily "have you reported today?" reminder.
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.hour = 21,
    this.minute = 0,
  });

  factory ReminderSettings.fromJson(Object? json) {
    if (json is! Map) return const ReminderSettings();
    int read(String key, int fallback, int max) =>
        ((json[key] as num?)?.toInt() ?? fallback).clamp(0, max);
    return ReminderSettings(
      enabled: json['enabled'] == true,
      hour: read('hour', 21, 23),
      minute: read('minute', 0, 59),
    );
  }

  final bool enabled;
  final int hour;
  final int minute;

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
  };

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.enabled == enabled &&
      other.hour == hour &&
      other.minute == minute;

  @override
  int get hashCode => Object.hash(enabled, hour, minute);
}

@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
  });

  final int id;

  /// Local time.
  final DateTime when;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.when == when &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, when, title, body);
}

const _lines = [
  '勇者，今天的冒險還沒回報喔。',
  '公會櫃檯提醒：今日委託尚未結案。',
  '封印還穩固嗎？睡前來回報一下吧。',
  '別讓今天的經驗值溜走。',
  '吟遊詩人正等著寫下你今天的事蹟。',
];

/// What the reminder [daysAway] days after planning says. The app re-plans
/// every time it is opened, so a reminder that fires on day N means the
/// player has been away for about N days.
String reminderLine(int daysAway, LogicalDay day) => switch (daysAway) {
  <= 1 =>
    _lines[day.differenceInDays(const LogicalDay(2026, 1, 1)) % _lines.length],
  2 => '勇者，昨天的委託沒有回報喔。今天回來看看吧？',
  < 7 => '已經 $daysAway 天沒見到你了。莉娜把你的委託書收在櫃檯下面，等你回來。',
  _ => '已經 $daysAway 天了。公會的委託板積了一層灰——不過大門永遠為你開著。',
};

/// The daily plan owns notification ids 1 to this; anything else scheduled
/// with [ReminderScheduler.scheduleOnce] must use a higher id.
const kReminderPlanDays = 30;

/// One-off reminders for the next [days] logical days (iOS keeps at most 64
/// pending). Local notifications cannot check the board when they fire, so
/// the app re-plans whenever the board changes or the app comes back:
/// tonight's reminder disappears once everything daily is reported, only
/// tonight's text knows how much is left, and later ones count the days
/// the player has been away.
List<PlannedReminder> planReminders({
  required ReminderSettings settings,
  required DateTime now,
  required int dayStartHour,
  required int pendingToday,
  int days = kReminderPlanDays,
  Set<LogicalDay> restDays = const {},
  StackHint? stack,
}) {
  if (!settings.enabled) return const [];
  final today = LogicalDay.of(now, dayStartHour: dayStartHour);
  final out = <PlannedReminder>[];
  for (var i = 0; i < days; i++) {
    final day = today.addDays(i);
    // Resting at the inn: nothing to remind.
    if (restDays.contains(day)) continue;
    // A time before the day starts (e.g. 01:00) falls on the next date.
    final date = settings.hour < dayStartHour ? day.addDays(1) : day;
    final when = DateTime(
      date.year,
      date.month,
      date.day,
      settings.hour,
      settings.minute,
    );
    if (i == 0 && (pendingToday == 0 || !when.isAfter(now))) continue;
    out.add(
      PlannedReminder(
        id: i + 1,
        when: when,
        title: '勇者日課',
        body: i == 0 && stack != null
            ? '${stack.line}（今天還有 $pendingToday 件沒回報）'
            : i == 0
            ? '今天還有 $pendingToday 件委託沒回報，公會櫃檯等你。'
            : reminderLine(i, day),
      ),
    );
  }
  return out;
}

/// Talks to the system's notification center.
abstract interface class ReminderScheduler {
  /// Asks for permission to notify; true when granted.
  Future<bool> requestPermission();

  /// Replaces the pending daily plan with [reminders]; notifications from
  /// [scheduleOnce] are left alone.
  Future<void> replaceAll(List<PlannedReminder> reminders);

  /// One notification outside the daily plan, at local time [when]. The [id]
  /// must be above [kReminderPlanDays]; scheduling it again replaces the
  /// pending one.
  Future<void> scheduleOnce(
    int id,
    DateTime when, {
    required String title,
    required String body,
  });

  /// Drops the pending notification [id], if there is one.
  Future<void> cancel(int id);

  /// Debug aid: one reminder [delay] from now, leaving the plan alone.
  Future<void> test(Duration delay);
}

/// What must change to turn plan [old] into [next]: ids to cancel and the
/// entries to (re)schedule. Scheduling an id again replaces the pending one.
/// A null [old] means whatever an earlier launch left pending is unknown:
/// every id of the plan that [next] does not use is cancelled, and nothing
/// outside the plan's ids is touched.
({List<int> cancel, List<PlannedReminder> schedule}) diffReminders(
  List<PlannedReminder>? old,
  List<PlannedReminder> next,
) {
  final ids = {for (final r in next) r.id};
  if (old == null) {
    return (
      cancel: [
        for (var id = 1; id <= kReminderPlanDays; id++)
          if (!ids.contains(id)) id,
      ],
      schedule: next,
    );
  }
  final before = {for (final r in old) r.id: r};
  return (
    cancel: [
      for (final r in old)
        if (!ids.contains(r.id)) r.id,
    ],
    schedule: [
      for (final r in next)
        if (before[r.id] != r) r,
    ],
  );
}

class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool?>? _ready;
  List<PlannedReminder>? _last;

  // Permission is asked for only when the player turns reminders on.
  Future<bool?> _init() => _ready ??= _plugin.initialize(
    settings: const InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );

  @override
  Future<bool> requestPermission() async {
    try {
      await _init();
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
      return granted ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static const _details = NotificationDetails(iOS: DarwinNotificationDetails());

  @override
  Future<void> test(Duration delay) async {
    await _init();
    await _plugin.zonedSchedule(
      id: 99,
      scheduledDate: tz.TZDateTime.now(tz.UTC).add(delay),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: '勇者日課',
      body: _lines.first,
    );
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    if (listEquals(_last, reminders)) return;
    final old = _last;
    _last = reminders;
    try {
      await _init();
      final diff = diffReminders(old, reminders);
      for (final id in diff.cancel) {
        await _plugin.cancel(id: id);
      }
      for (final r in diff.schedule) {
        await _schedule(r);
      }
    } on PlatformException catch (e) {
      debugPrint('reminders: $e');
      _last = null;
    } on MissingPluginException {
      _last = null;
    }
  }

  // An absolute instant: the plan is redone on every launch, so
  // daylight-saving or travel never leaves a stale local time.
  Future<void> _schedule(PlannedReminder r) => _plugin.zonedSchedule(
    id: r.id,
    scheduledDate: tz.TZDateTime.from(r.when, tz.UTC),
    notificationDetails: _details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    title: r.title,
    body: r.body,
  );

  @override
  Future<void> scheduleOnce(
    int id,
    DateTime when, {
    required String title,
    required String body,
  }) async {
    assert(id > kReminderPlanDays);
    try {
      await _init();
      // The plugin throws on a time that has already passed.
      if (!when.isAfter(DateTime.now())) return;
      await _schedule(
        PlannedReminder(id: id, when: when, title: title, body: body),
      );
    } on PlatformException catch (e) {
      debugPrint('reminders: $e');
    } on MissingPluginException {
      // No notification center (tests, unsupported platform).
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _init();
      await _plugin.cancel(id: id);
    } on PlatformException catch (e) {
      debugPrint('reminders: $e');
    } on MissingPluginException {
      // Nothing to cancel.
    }
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalReminderScheduler(),
);

final reminderSettingsProvider = StreamProvider<ReminderSettings>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.reminders)
      .map(ReminderSettings.fromJson),
);

/// Keeps the scheduled reminders in step with the board; watched by
/// `AppEffects`.
final reminderSyncProvider = Provider<void>((ref) {
  final settings = ref.watch(reminderSettingsProvider).value;
  final board = ref.watch(boardProvider).value;
  if (settings == null || board == null) return;
  final plan = planReminders(
    settings: settings,
    now: ref.read(clockProvider).now(),
    dayStartHour: ref.read(gameRulesProvider).dayStartHour,
    pendingToday: board.unreportedDaily,
    stack: board.pendingStack,
    restDays: ref.watch(restDaysProvider).value ?? const {},
  );
  ref.read(reminderSchedulerProvider).replaceAll(plan);
});
