import 'dart:math' as math;

import 'package:drift/drift.dart' show OrderingTerm, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/focus_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/app/screen_control.dart';
import 'package:habit_quest/app/sfx.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/focus_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/domain/quest_rank.dart';

import '../support/app_harness.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late ProviderContainer container;
  late FakeReminderScheduler reminders;
  late FakeScreenControl screen;
  late FakeSfx sfx;
  // Wednesday 2026-11-11; the week started on Monday the 9th.
  const wednesday = LogicalDay(2026, 11, 11);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 11, 10));
    reminders = FakeReminderScheduler();
    screen = FakeScreenControl();
    sfx = FakeSfx();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        reminderSchedulerProvider.overrideWithValue(reminders),
        screenControlProvider.overrideWithValue(screen),
        sfxProvider.overrideWithValue(sfx),
        focusTickProvider.overrideWithValue(null),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// A rank-D adventurer: focus pays 30 gold an hour above zero.
  Future<void> hero() async {
    final adventurers = AdventurerRepository(db);
    final id = await adventurers.create(name: '亞倫', now: clock.now());
    await adventurers.promote(id, QuestRank.d, wednesday.addDays(-2));
  }

  Future<void> eventually(Future<bool> Function() check) async {
    for (var i = 0; i < 400; i++) {
      if (await check()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('never happened');
  }

  /// The timer, once it has dealt with what an earlier launch left.
  Future<FocusController> timer() async {
    final sub = container.listen(focusProvider, (_, _) {});
    addTearDown(sub.close);
    await eventually(() async => container.read(focusProvider).ready);
    return container.read(focusProvider.notifier);
  }

  FocusState state() => container.read(focusProvider);

  /// Moves the clock on by [seconds], looking every 10 like the app does.
  Future<void> run(FocusController focus, int seconds) async {
    for (var left = seconds; left > 0; left -= 10) {
      clock.advance(Duration(seconds: math.min(10, left)));
      await focus.tick();
    }
  }

  Future<List<FocusSessionRow>> sessions() => (db.select(
    db.focusSessions,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<int?> gold(LogicalDay day) =>
      EconomyRepository(db)
          .watchEvent(source: kFocusGoldSource, ref: day.toKey())
          .first;

  test('focus pays off the day first and earns above zero', () async {
    await hero();
    final focus = await timer();
    expect(await focus.start(), isTrue);
    expect((state().phase, state().day), (FocusPhase.running, wednesday));
    expect(screen.awake, isTrue);
    expect(sfx.played, [SfxCue.start]);
    expect(reminders.permissionRequests, 1);

    // 62 minutes: 50 pay the day, 12 above zero earn 6 gold on the way.
    await run(focus, 62 * 60);
    expect(state().sessionSeconds, 62 * 60);
    await eventually(() async => await gold(wednesday) == 6);

    await run(focus, 18 * 60);
    final stoppedAt = clock.now();
    await focus.stop();
    expect(state().phase, FocusPhase.resting);
    final breakEnds = stoppedAt.add(const Duration(minutes: 10));
    expect(state().breakEndsAt, breakEnds);
    expect(reminders.once[kBreakNotificationId]?.when, breakEnds);
    expect(screen.awake, isFalse);
    expect(sfx.played, [SfxCue.start, SfxCue.stop]);

    final session = (await sessions()).single;
    expect(
      (session.seconds, session.endedAt, session.endReason),
      (80 * 60, stoppedAt, FocusEnd.stopped),
    );
    expect(await gold(wednesday), 15);
    await eventually(
      () async => container.read(focusLedgerProvider)?.focusedSeconds == 4800,
    );
    final today = container.read(focusLedgerProvider)!.days.last;
    expect(
      (today.startSeconds, today.endSeconds, today.gold),
      (-50 * 60, 30 * 60, 15),
    );
  });

  test('leaving for 20 seconds goes on; for 40 it ends there', () async {
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 60);
    await focus.hidden();
    expect((await sessions()).single.hiddenAt, clock.now());
    expect(screen.awake, isFalse);

    clock.advance(const Duration(seconds: 20));
    await focus.returned();
    expect((state().phase, screen.awake), (FocusPhase.running, true));
    expect((await sessions()).single.hiddenAt, isNull);
    await run(focus, 60);
    await focus.stop();
    final first = (await sessions()).single;
    expect((first.seconds, first.awaySeconds), (120, 20));

    await focus.skipBreak();
    expect(reminders.once, isEmpty);
    await focus.start();
    await run(focus, 60);
    final leftAt = clock.now();
    await focus.hidden();
    clock.advance(const Duration(seconds: 40));
    await focus.returned();
    expect((state().phase, state().endedAway), (FocusPhase.idle, true));
    final second = (await sessions()).last;
    expect(
      (second.seconds, second.endedAt, second.endReason),
      (60, leftAt, FocusEnd.away),
    );
    expect(reminders.once, isEmpty, reason: 'no break after leaving');
  });

  test('sessions an earlier launch died in end where last seen', () async {
    await hero();
    await container.read(townServiceProvider).rollover();
    final repo = FocusRepository(db);
    // Hidden at 11:20 and killed in the background; 80 minutes counted.
    final hiddenAt = DateTime(2026, 11, 11, 11, 20);
    final id = await repo.startSession(wednesday, DateTime(2026, 11, 11, 10));
    await repo.saveSession(
      id,
      seconds: 80 * 60,
      at: hiddenAt,
      hiddenAt: hiddenAt,
    );
    final settings = SettingsRepository(db);
    await settings.write(SettingKeys.focusRestoreBrightness, 0.6);
    final breakEnds = clock.now().add(const Duration(minutes: 3));
    await settings.write(SettingKeys.focusBreak, breakEnds.toIso8601String());

    await timer();
    final session = (await sessions()).single;
    expect(
      (session.endedAt, session.seconds, session.endReason),
      (hiddenAt, 80 * 60, FocusEnd.lost),
    );
    expect(await gold(wednesday), 15);
    expect(screen.restored, 0.6);
    expect(await settings.read(SettingKeys.focusRestoreBrightness), isNull);
    expect(
      (state().phase, state().breakEndsAt),
      (FocusPhase.resting, breakEnds),
    );
  });

  test('a session over the day start is split between the days', () async {
    // 03:58 on Thursday still counts for Wednesday.
    clock.value = DateTime(2026, 11, 12, 3, 58);
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 80);
    // 20 seconds away before 04:00 belong to the first session only.
    await focus.hidden();
    clock.advance(const Duration(seconds: 20));
    await focus.returned();
    await run(focus, 80);

    final rows = await sessions();
    expect(rows, hasLength(2));
    expect(
      (rows[0].day, rows[0].seconds, rows[0].endedAt, rows[0].endReason),
      (wednesday, 100, DateTime(2026, 11, 12, 4), FocusEnd.dayEnd),
    );
    expect(rows[0].awaySeconds, 20);
    expect(
      (rows[1].day, rows[1].startedAt, rows[1].endedAt, rows[1].awaySeconds),
      (wednesday.addDays(1), DateTime(2026, 11, 12, 4), null, 0),
    );
    expect((state().day, state().sessionSeconds), (wednesday.addDays(1), 60));
    await focus.stop();
    expect((await sessions()).last.seconds, 60);
  });

  test('the week that ends under a running session waits for it', () async {
    // Sunday night: 03:59 on Monday the 16th is still Sunday the 15th.
    clock.value = DateTime(2026, 11, 16, 3, 59);
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 50);
    // 04:00: the day's minute timer turns the week over before the
    // focus timer has looked …
    clock.value = DateTime(2026, 11, 16, 4);
    final town = container.read(townServiceProvider);
    await town.rollover();
    final week = FocusRepository(db).week(const LogicalDay(2026, 11, 9));
    expect((await week)?.settledAt, isNull);
    // … and once the session is split, the week closes on all 60 seconds.
    await focus.tick();
    final settled = await FocusRepository(db)
        .week(const LogicalDay(2026, 11, 9));
    expect(settled?.settledAt, isNotNull);
    expect(settled?.unpaidSeconds, 50 * 60 - 60);
  });

  test('turning the clock back takes no focus away', () async {
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 100);
    clock.advance(const Duration(hours: -1));
    await focus.tick();
    expect(state().sessionSeconds, 100);
    await run(focus, 50);
    // Saving goes on from the new time, so a crash loses nothing counted.
    expect((await sessions()).single.seconds, 150);
    await focus.stop();
    expect((await sessions()).single.seconds, 150);
  });

  test('turning the clock back over the day start keeps the day', () async {
    // 04:00 on Thursday: a session for Thursday.
    clock.value = DateTime(2026, 11, 12, 4);
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 30);
    clock.value = DateTime(2026, 11, 12, 3, 59, 50);
    await focus.tick();
    await run(focus, 20);

    final session = (await sessions()).single;
    expect((session.day, session.endedAt), (wednesday.addDays(1), null));
    expect(state().sessionSeconds, 50);
    await focus.stop();
    expect((await sessions()).single.seconds, 50);
  });

  test('a clock that jumps ahead ends the session where it was', () async {
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 60);
    final lastSeen = clock.now();
    clock.advance(const Duration(days: 1));
    await focus.tick();

    expect((state().phase, state().endedAway), (FocusPhase.idle, true));
    final session = (await sessions()).single;
    expect((session.seconds, session.endedAt), (60, lastSeen));
  });

  test('a break ends with a sound, or early without its notice', () async {
    await hero();
    final focus = await timer();
    await focus.start();
    await run(focus, 10);
    await focus.stop();
    clock.advance(const Duration(minutes: 10));
    await focus.tick();
    expect(state().phase, FocusPhase.idle);
    expect(sfx.played.last, SfxCue.breakOver);
    final settings = SettingsRepository(db);
    expect(await settings.read(SettingKeys.focusBreak), isNull);

    await focus.start();
    await run(focus, 10);
    await focus.stop();
    expect(reminders.once.keys, [kBreakNotificationId]);
    // Starting again during the break drops it.
    await focus.start();
    expect(state().phase, FocusPhase.running);
    expect(reminders.once, isEmpty);
  });

  test('the player sets the break and can turn the sounds off', () async {
    await hero();
    await SettingsRepository(db)
        .write(SettingKeys.focus, {'breakMinutes': 5, 'sound': false});
    final focus = await timer();
    await focus.start();
    await run(focus, 10);
    await focus.stop();
    expect(state().breakEndsAt, clock.now().add(const Duration(minutes: 5)));
    expect(sfx.played, isEmpty);
  });

  test('nothing starts before there is an adventurer', () async {
    final focus = await timer();
    expect(await focus.start(), isFalse);
    expect(state().phase, FocusPhase.idle);
    expect(await sessions(), isEmpty);
  });

  test('the power-saving view dims and gives the brightness back', () async {
    await hero();
    final focus = await timer();
    await focus.start();
    await focus.setPowerSave(true);
    expect((state().powerSave, screen.brightness), (true, 0.05));
    final settings = SettingsRepository(db);
    expect(await settings.read(SettingKeys.focusRestoreBrightness), 0.8);

    // Leaving the app gives the system its brightness back by itself, so
    // nothing is left to restore if the app dies in the background …
    await focus.hidden();
    expect(await settings.read(SettingKeys.focusRestoreBrightness), isNull);
    // … and coming back dims again, from what the system is set to now.
    screen.system = 0.3;
    clock.advance(const Duration(seconds: 5));
    await focus.returned();
    expect((state().powerSave, screen.brightness), (true, 0.05));
    expect(await settings.read(SettingKeys.focusRestoreBrightness), 0.3);

    await run(focus, 10);
    await focus.stop();
    expect((state().powerSave, screen.brightness), (false, null));
    expect(await settings.read(SettingKeys.focusRestoreBrightness), isNull);
  });
}
