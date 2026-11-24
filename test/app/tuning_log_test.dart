import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/casino_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/app/tuning_log.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/game/game_rules.dart';

void main() {
  test('sums a week of the town up without names or notes', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    final clock = FixedClock(DateTime(2026, 11, 17, 10));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        randomProvider.overrideWithValue(math.Random(3)),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final economy = EconomyRepository(db);
    await AdventurerRepository(db).create(name: '亞倫', now: clock.now());
    await economy.reward(
      amount: 500,
      source: 'perfect',
      ref: '2026-11-17',
      at: clock.now(),
    );
    await container.read(bankServiceProvider).open(balance: 20000);
    await container.read(townServiceProvider).rollover();
    final outcome = await container
        .read(casinoServiceProvider)
        .draw(game: CasinoGame.slots, times: 2);

    final text = await exportTuningLog(
      db,
      rules: const GameRules(),
      now: clock.now(),
    );
    expect(text, isNot(contains('亞倫')));
    final log = jsonDecode(text) as Map<String, Object?>;
    expect(log['format'], kTuningLogFormat);
    final week = (log['weeks']! as List).single as Map<String, Object?>;
    expect(week['week'], '2026-11-16');
    final gold = week['gold']! as Map<String, Object?>;
    expect((gold['earned']! as Map)['perfect'], 500);
    final paid = outcome.drawn.fold(0, (a, t) => a + (t.paid ?? 0));
    if (paid > 0) expect((gold['spent']! as Map)['casino'], paid);
    final casino = week['casino']! as Map<String, Object?>;
    expect(casino['from'], '2026-11-17');
    expect(casino['drawn'], outcome.drawn.where((t) => t.amount > 0).length);
    expect(casino['won'], outcome.won);
    expect(casino['goldAtOpen'], 500);
    expect(casino['settled'], isFalse);
    expect((week['focus']! as Map)['minutes'], 0);
  });

  test('an empty town logs no weeks', () {
    final log = buildTuningLog(
      now: DateTime(2026, 11, 17),
      rules: const GameRules(),
      casinoWeeks: const [],
      tickets: const [],
      focusWeeks: const [],
      focusSecondsByDay: const {},
      gold: [(day: const LogicalDay(2026, 11, 17), source: 'x', amount: 3)],
    );
    expect(log['weeks'], isEmpty);
  });
}
