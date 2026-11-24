import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/secret_store.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/ai_providers.dart';
import 'package:habit_quest/app/app_effects.dart';
import 'package:habit_quest/app/backup_files.dart';
import 'package:habit_quest/app/demo_seed.dart';
import 'package:habit_quest/app/player_look.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/reminders.dart';
import 'package:habit_quest/app/screen_control.dart';
import 'package:habit_quest/app/sfx.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/ui/widgets/mentor_tips.dart';

/// Monday 2026-11-09, 10:00.
final testNow = DateTime(2026, 11, 9, 10);

/// The app on an in-memory database with a pinned clock, sized like an
/// iPhone but tall enough to show the whole board.
class AppHarness {
  AppHarness() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  final db = AppDatabase(NativeDatabase.memory());
  final clock = FixedClock(testNow);
  final reminders = FakeReminderScheduler();
  final files = FakeBackupFiles();
  final screen = FakeScreenControl();
  final sfx = FakeSfx();

  /// Stands in for the Keychain, which tests can't reach.
  SecretStore secrets = MemorySecretStore();

  LogicalDay get today => LogicalDay.of(clock.now());

  /// More overrides for one test, on top of the harness's own.
  List<Override> extraOverrides = [];

  List<Override> get overrides => [
    ...extraOverrides,
    databaseProvider.overrideWithValue(db),
    clockProvider.overrideWithValue(clock),
    reminderSchedulerProvider.overrideWithValue(reminders),
    backupFilesProvider.overrideWithValue(files),
    screenControlProvider.overrideWithValue(screen),
    sfxProvider.overrideWithValue(sfx),
    secretStoreProvider.overrideWithValue(secrets),
    randomProvider.overrideWithValue(math.Random(7)),
  ];

  Future<void> seed() => seedDemo(
    adventurers: AdventurerRepository(db),
    habits: HabitRepository(db),
    checkIns: CheckInRepository(db),
    story: StoryRepository(db),
    settings: SettingsRepository(db),
    rules: const GameRules(),
    today: today,
  );

  /// Leave false to mark every mentor tip as seen, so they don't cover the
  /// screens under test.
  bool showTips = false;

  Future<void> pump(WidgetTester tester, {Widget? home}) async {
    if (!showTips) {
      await tester.runAsync(
        () => SettingsRepository(db).write(SettingKeys.tipsSeen, [
          for (final t in MentorTip.values) t.name,
        ]),
      );
    }
    tester.view.physicalSize = const Size(1206, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: AppEffects(
          child: PlayerLook(child: HabitQuestApp(home: home)),
        ),
      ),
    );
    await settle(tester);
  }

  /// Lets drift's streams deliver before pumping frames.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    // Closing inside runAsync deadlocks; drift needs fake-time pumps here.
    final closing = db.close();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await closing;
  }
}

/// Records reminders instead of talking to the notification center.
class FakeReminderScheduler implements ReminderScheduler {
  bool grant = true;
  int permissionRequests = 0;
  List<PlannedReminder> scheduled = const [];

  /// Pending [scheduleOnce] notifications by id.
  final once = <int, PlannedReminder>{};

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    scheduled = reminders;
  }

  @override
  Future<void> scheduleOnce(
    int id,
    DateTime when, {
    required String title,
    required String body,
  }) async {
    once[id] = PlannedReminder(id: id, when: when, title: title, body: body);
  }

  @override
  Future<void> cancel(int id) async {
    once.remove(id);
  }

  @override
  Future<void> test(Duration delay) async {}
}

/// Keeps "saved" backups in memory and hands out [toOpen] when picking.
class FakeBackupFiles implements BackupFiles {
  String? savedName;
  String? savedContent;
  String? toOpen;

  @override
  Future<bool> save(String name, String content, {Rect? origin}) async {
    savedName = name;
    savedContent = content;
    return true;
  }

  @override
  Future<String?> open() async => toOpen;
}

/// Remembers what the focus timer did to the screen.
class FakeScreenControl implements ScreenControl {
  bool awake = false;
  double system = 0.8;

  /// The brightness set while the app is in front; null when it follows the
  /// system.
  double? brightness;
  double? restored;

  @override
  Future<void> keepAwake(bool on) async => awake = on;

  @override
  Future<double> systemBrightness() async => system;

  @override
  Future<void> setBrightness(double level) async => brightness = level;

  @override
  Future<void> resetBrightness() async => brightness = null;

  @override
  Future<void> restoreSystemBrightness(double level) async {
    restored = level;
    system = level;
  }
}

/// Records the sounds instead of playing them.
class FakeSfx implements Sfx {
  final played = <SfxCue>[];

  @override
  Future<void> play(SfxCue cue) async => played.add(cue);
}
