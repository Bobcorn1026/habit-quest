import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/game/stacking.dart';

void main() {
  const on = ReminderSettings(enabled: true, hour: 21);
  final morning = DateTime(2026, 11, 9, 10); // Monday

  List<PlannedReminder> plan(
    ReminderSettings s, {
    DateTime? now,
    int pending = 2,
    StackHint? stack,
  }) => planReminders(
    stack: stack,
    settings: s,
    now: now ?? morning,
    dayStartHour: 4,
    pendingToday: pending,
  );

  test('nothing is planned while reminders are off', () {
    expect(plan(const ReminderSettings()), isEmpty);
  });

  test('one reminder a day for the next month, starting tonight', () {
    final r = plan(on);
    expect(r, hasLength(30));
    expect(r.first.when, DateTime(2026, 11, 9, 21));
    expect(r.last.when, DateTime(2026, 12, 8, 21));
    expect(r.map((e) => e.id).toSet(), hasLength(30));
    expect(r.first.body, contains('2'), reason: 'tonight knows what is left');
  });

  test('tonight mentions a pending stack; later days do not', () {
    final r = plan(
      on,
      stack: const StackHint(
        cue: '刷完牙',
        habitName: '讀英文',
        anchorIsHabit: false,
      ),
    );
    expect(r.first.body, startsWith('刷完牙了嗎？接著讀英文吧（今天還有'));
    expect(r[1].body, isNot(contains('接著')));

    final byHabit = plan(
      on,
      stack: const StackHint(
        cue: '破譯古代卷軸',
        habitName: '讀英文',
        anchorIsHabit: true,
      ),
    );
    expect(byHabit.first.body, startsWith('破譯古代卷軸完成了嗎？接著讀英文吧（'));
  });

  test('without a stack tonight keeps its usual line', () {
    expect(plan(on).first.body, contains('今天還有 2 件'));
  });

  test('later reminders count the days the player has been away', () {
    final r = plan(on);
    expect(r[2].body, contains('昨天'));
    expect(r[4].body, contains('已經 4 天'));
    expect(r[10].body, contains('已經 10 天'));
  });

  test('tonight is skipped once everything is reported', () {
    final r = plan(on, pending: 0);
    expect(r.first.when, DateTime(2026, 11, 10, 21));
    expect(r, hasLength(29));
  });

  test('tonight is skipped when its time has passed', () {
    final r = plan(on, now: DateTime(2026, 11, 9, 22));
    expect(r.first.when, DateTime(2026, 11, 10, 21));
  });

  test('times after midnight belong to the logical day before', () {
    const late = ReminderSettings(enabled: true, hour: 1);
    final r = plan(late);
    expect(r.first.when, DateTime(2026, 11, 10, 1));
  });

  test('settings round-trip through JSON', () {
    const s = ReminderSettings(enabled: true, hour: 22, minute: 30);
    expect(ReminderSettings.fromJson(s.toJson()), s);
    expect(ReminderSettings.fromJson(null), const ReminderSettings());
    expect(
      ReminderSettings.fromJson({'enabled': true, 'hour': 99}).hour,
      23,
      reason: 'clamped',
    );
  });

  test('only changed reminders are rescheduled', () {
    final old = plan(on);
    final same = diffReminders(old, plan(on));
    expect(same.cancel, isEmpty);
    expect(same.schedule, isEmpty);

    // Tonight reported: id 1 is cancelled, nothing else moves.
    final done = diffReminders(old, plan(on, pending: 0));
    expect(done.cancel, [1]);
    expect(done.schedule, isEmpty);

    // Tonight's text changes: only id 1 is rescheduled.
    final fewer = diffReminders(old, plan(on, pending: 1));
    expect(fewer.cancel, isEmpty);
    expect(fewer.schedule.map((r) => r.id), [1]);
  });

  test('a fresh launch clears only the plan ids it will not reuse', () {
    // Tonight is reported, so id 1 may still be pending from last time.
    final next = plan(on, pending: 0);
    final diff = diffReminders(null, next);
    expect(diff.cancel, [1]);
    expect(diff.schedule, next);

    final off = diffReminders(null, const []);
    expect(off.cancel, [for (var id = 1; id <= kReminderPlanDays; id++) id]);
    expect(off.schedule, isEmpty);
  });
}
