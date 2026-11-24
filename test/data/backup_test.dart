import 'dart:convert';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/demo_seed.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/backup.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/game_rules.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final now = DateTime(2026, 11, 9, 10);
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
    await seedDemo(
      adventurers: AdventurerRepository(source),
      habits: HabitRepository(source),
      checkIns: CheckInRepository(source),
      story: StoryRepository(source),
      settings: SettingsRepository(source),
      rules: const GameRules(),
      today: const LogicalDay(2026, 11, 9),
    );
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('covers every table', () {
    expect(
      BackupService.tableOrder.toSet(),
      source.allTables.map((t) => t.actualTableName).toSet(),
    );
  });

  test('a backup restores to an identical database', () async {
    final text = await BackupService(source).export(now);
    final backup = BackupService(target).inspect(text);
    expect(backup.exportedAt, now);
    expect(backup.counts['habits'], 4);
    expect(backup.counts['check_ins'], greaterThan(50));

    await BackupService(target).restore(backup);

    final again = jsonDecode(await BackupService(target).export(now)) as Map;
    final original = jsonDecode(text) as Map;
    expect(again['tables'], original['tables']);
  });

  test('wiping empties every table', () async {
    await BackupService(source).wipe();
    final left = BackupService(source)
        .inspect(await BackupService(source).export(now));
    for (final t in BackupService.tableOrder) {
      expect(left.counts[t] ?? 0, 0, reason: t);
    }
  });

  test('restoring replaces what was there', () async {
    final empty = await BackupService(target).export(now);
    await BackupService(source).restore(BackupService(source).inspect(empty));
    expect(await HabitRepository(source).active(), isEmpty);
  });

  test(
    'a backup from before schema 5 restores without the anchor columns',
    () async {
      final b = jsonDecode(
        await BackupService(source).export(now),
      ) as Map<String, Object?>;
      for (final row in (b['tables']! as Map)['habits'] as List) {
        (row as Map)
          ..remove('anchor_habit_id')
          ..remove('anchor_text');
      }
      b['schemaVersion'] = 4;
      final backup = BackupService(target).inspect(jsonEncode(b));
      await BackupService(target).restore(backup);

      final restored = await HabitRepository(target).active();
      expect(restored, hasLength(4));
      expect(restored.every((a) => a.habit.anchorHabitId == null), isTrue);
      expect(restored.every((a) => a.habit.anchorText == null), isTrue);
    },
  );

  Future<void> seedTown(AppDatabase db) async {
    const week = LogicalDay(2026, 11, 9);
    await db
        .into(db.priceWeeks)
        .insert(
          PriceWeeksCompanion.insert(
            weekStart: week,
            rank: QuestRank.e,
            percent: 120,
          ),
        );
    await db
        .into(db.focusWeeks)
        .insert(
          FocusWeeksCompanion.insert(
            weekStart: week,
            fromDay: week,
            dailyMinutes: 50,
            capMinutes: 600,
            earnCapMinutes: 250,
            goldPerHour: 24,
          ),
        );
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            day: week,
            startedAt: now,
            lastSeenAt: now.add(const Duration(minutes: 25)),
            seconds: const Value(1500),
          ),
        );
  }

  test('the town tables travel with a backup', () async {
    await seedTown(source);
    final text = await BackupService(source).export(now);
    final backup = BackupService(target).inspect(text);
    expect(
      (
        backup.counts['price_weeks'],
        backup.counts['focus_weeks'],
        backup.counts['focus_sessions'],
      ),
      (1, 1, 1),
    );
    await BackupService(target).restore(backup);
    expect((await target.select(target.priceWeeks).getSingle()).percent, 120);
    expect(
      (await target.select(target.focusWeeks).getSingle()).goldPerHour,
      24,
    );
    expect(
      (await target.select(target.focusSessions).getSingle()).seconds,
      1500,
    );
  });

  test('a backup from before schema 6 leaves the town tables empty', () async {
    final b = jsonDecode(
      await BackupService(source).export(now),
    ) as Map<String, Object?>;
    (b['tables']! as Map)
      ..remove('price_weeks')
      ..remove('focus_weeks')
      ..remove('focus_sessions');
    b['schemaVersion'] = 5;

    await seedTown(target);
    await BackupService(target)
        .restore(BackupService(target).inspect(jsonEncode(b)));
    expect(await HabitRepository(target).active(), hasLength(4));
    expect(await target.select(target.priceWeeks).get(), isEmpty);
    expect(await target.select(target.focusWeeks).get(), isEmpty);
    expect(await target.select(target.focusSessions).get(), isEmpty);
  });

  test('a backup from before schema 7 leaves the bank empty', () async {
    final b = jsonDecode(
      await BackupService(source).export(now),
    ) as Map<String, Object?>;
    (b['tables']! as Map)
      ..remove('bank_accounts')
      ..remove('bank_txns')
      ..remove('bank_months');
    b['schemaVersion'] = 6;

    await target
        .into(target.bankAccounts)
        .insert(
          BankAccountsCompanion.insert(
            name: '通用',
            icon: 'general',
            createdAt: now,
          ),
        );
    await BackupService(target)
        .restore(BackupService(target).inspect(jsonEncode(b)));
    expect(await HabitRepository(target).active(), hasLength(4));
    expect(await target.select(target.bankAccounts).get(), isEmpty);
  });

  test('a backup from before schema 8 leaves the casino empty', () async {
    final b = jsonDecode(
      await BackupService(source).export(now),
    ) as Map<String, Object?>;
    (b['tables']! as Map)
      ..remove('casino_weeks')
      ..remove('casino_tickets');
    b['schemaVersion'] = 7;

    await target
        .into(target.casinoWeeks)
        .insert(
          CasinoWeeksCompanion.insert(
            weekStart: const LogicalDay(2026, 11, 16),
            fromDay: const LogicalDay(2026, 11, 18),
            poolBefore: 0,
            released: 0,
            price: 0,
            targetGold: 0,
            priceLevel: 100,
            openedAt: now,
          ),
        );
    await BackupService(target)
        .restore(BackupService(target).inspect(jsonEncode(b)));
    expect(await HabitRepository(target).active(), hasLength(4));
    expect(await target.select(target.casinoWeeks).get(), isEmpty);
  });

  group('rejects', () {
    Future<Map<String, Object?>> good() async =>
        jsonDecode(await BackupService(source).export(now))
            as Map<String, Object?>;

    void expectRejected(String text, String message) {
      expect(
        () => BackupService(target).inspect(text),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            contains(message),
          ),
        ),
      );
    }

    test('text that is not JSON', () {
      expectRejected('hello', '不是勇者日課的備份檔');
    });

    test('JSON from somewhere else', () {
      expectRejected('{"tables": {}}', '不是勇者日課的備份檔');
    });

    test('a backup from a newer app version', () async {
      final b = await good();
      b['schemaVersion'] = 99;
      expectRejected(jsonEncode(b), '較新版本');
    });

    test('unknown tables or columns', () async {
      final b = await good();
      (b['tables']! as Map)['dragons'] = [];
      expectRejected(jsonEncode(b), 'dragons');

      final c = await good();
      ((c['tables']! as Map)['habits'] as List).first['wings'] = 2;
      expectRejected(jsonEncode(c), 'wings');
    });
  });
}
