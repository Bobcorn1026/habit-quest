import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/domain/bank.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/domain/stat.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a schema 1 database upgrades in place', () async {
    final dir = await Directory.systemTemp.createTemp('hq_migration');
    final file = File('${dir.path}/db.sqlite');
    const day = LogicalDay(2026, 11, 2);

    var db = AppDatabase(NativeDatabase(file));
    final id = await AdventurerRepository(db)
        .create(name: '亞倫', now: DateTime(2026, 11, 2));
    await HabitRepository(db).create(
      const HabitDraft(kind: HabitKind.build, name: '讀英文'),
      const QuestDraft(rank: QuestRank.c, title: '破譯古代卷軸'),
      now: DateTime(2026, 11, 2),
      today: day,
    );
    final quest = (await HabitRepository(db).active()).single;
    await CheckInRepository(db).upsert(
      CheckIn(
        habitId: quest.habit.id,
        questId: quest.quest.id,
        day: day,
        outcome: CheckInOutcome.done,
        createdAt: DateTime(2026, 11, 2, 21),
      ),
    );
    await db.close();

    // Turn the file back into schema 1: drop what version 2 added.
    db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          for (final c in [
            'class_stats',
            'class_since',
            'class_flavor',
            'portrait_id',
            'guild_rank',
            'rank_since',
            'trial_start',
          ]) {
            raw.execute('ALTER TABLE adventurers DROP COLUMN $c');
          }
          raw.execute('ALTER TABLE habits DROP COLUMN cursed_on');
          raw.execute('ALTER TABLE habits DROP COLUMN anchor_habit_id');
          raw.execute('ALTER TABLE habits DROP COLUMN anchor_text');
          raw.execute('ALTER TABLE quests DROP COLUMN attribute');
          raw.execute('ALTER TABLE check_ins DROP COLUMN gold');
          raw.execute('DROP TABLE gold_events');
          raw.execute('DROP TABLE purchases');
          // Schema 6; the index goes with its table.
          raw.execute('DROP TABLE price_weeks');
          raw.execute('DROP TABLE focus_weeks');
          raw.execute('DROP TABLE focus_sessions');
          // Schema 7.
          raw.execute('DROP TABLE bank_txns');
          raw.execute('DROP TABLE bank_accounts');
          raw.execute('DROP TABLE bank_months');
          raw.execute('DROP TABLE casino_tickets');
          raw.execute('DROP TABLE casino_weeks');
          for (final i in [
            'check_ins_day',
            'check_ins_quest',
            'quests_habit_active',
          ]) {
            raw.execute('DROP INDEX $i');
          }
          raw.userVersion = 1;
        },
      ),
    );
    final hero = await AdventurerRepository(db).get();
    expect(hero!.id, id);
    expect(hero.guildRank, QuestRank.f);
    expect(hero.hasClass, isFalse);
    final upgraded = (await HabitRepository(db).active()).single;
    expect(upgraded.quest.attribute, isNull);
    expect(upgraded.attribute, Stat.intel, reason: 'guessed from the name');
    expect(
      await EconomyRepository(db).balance(),
      2,
      reason: 'past commissions pay their base gold (rank C)',
    );
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      indexes,
      containsAll(['check_ins_day', 'check_ins_quest', 'quests_habit_active']),
      reason: 'schema 4 adds the lookup indexes',
    );
    expect(indexes, contains('focus_sessions_day'));
    expect(
      indexes,
      containsAll(['bank_txns_day', 'bank_txns_from', 'bank_txns_to']),
    );
    expect(indexes, contains('casino_tickets_week'));
    expect(await db.select(db.focusWeeks).get(), isEmpty);
    expect(await db.select(db.bankTxns).get(), isEmpty);
    await db.close();
    await dir.delete(recursive: true);
  });

  test('schema 5 gains the town tables and keeps its data', () async {
    final dir = await Directory.systemTemp.createTemp('hq_migration');
    final file = File('${dir.path}/db.sqlite');
    const day = LogicalDay(2026, 11, 9);
    final at = DateTime(2026, 11, 9, 21);

    var db = AppDatabase(NativeDatabase(file));
    await AdventurerRepository(db)
        .create(name: '亞倫', now: DateTime(2026, 11, 9));
    await HabitRepository(db).create(
      const HabitDraft(kind: HabitKind.build, name: '讀英文'),
      const QuestDraft(rank: QuestRank.c, title: '破譯古代卷軸'),
      now: DateTime(2026, 11, 9),
      today: day,
    );
    final quest = (await HabitRepository(db).active()).single;
    await CheckInRepository(db).upsert(
      CheckIn(
        habitId: quest.habit.id,
        questId: quest.quest.id,
        day: day,
        outcome: CheckInOutcome.done,
        gold: 2,
        createdAt: at,
      ),
    );
    final economy = EconomyRepository(db);
    await economy.reward(
      amount: 10,
      source: 'perfect',
      ref: '2026-11-09',
      at: at,
    );
    // Real data can hold the same reward twice; the upgrade must not mind.
    await db
        .into(db.goldEvents)
        .insert(
          GoldEventsCompanion.insert(
            amount: 10,
            source: 'perfect',
            ref: const Value('2026-11-09'),
            at: at,
          ),
        );
    expect(await economy.bookInn(day.addDays(1), 5, at), InnBookResult.booked);
    await db.close();

    db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          raw.execute('DROP TABLE price_weeks');
          raw.execute('DROP TABLE focus_weeks');
          raw.execute('DROP TABLE focus_sessions');
          raw.execute('DROP TABLE bank_txns');
          raw.execute('DROP TABLE bank_accounts');
          raw.execute('DROP TABLE bank_months');
          raw.execute('DROP TABLE casino_tickets');
          raw.execute('DROP TABLE casino_weeks');
          raw.userVersion = 5;
        },
      ),
    );
    expect(await EconomyRepository(db).balance(), 2 + 10 + 10 - 5);
    expect((await HabitRepository(db).active()).single.quest.title, '破譯古代卷軸');
    expect(await EconomyRepository(db).bookedDays(), {day.addDays(1)});

    // The new tables are there and take rows.
    await db
        .into(db.priceWeeks)
        .insert(
          PriceWeeksCompanion.insert(
            weekStart: day,
            rank: QuestRank.f,
            percent: 100,
          ),
        );
    await db
        .into(db.focusWeeks)
        .insert(
          FocusWeeksCompanion.insert(
            weekStart: day,
            fromDay: day,
            dailyMinutes: 50,
            capMinutes: 600,
            earnCapMinutes: 250,
            goldPerHour: 20,
          ),
        );
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            day: day,
            startedAt: at,
            lastSeenAt: at,
          ),
        );
    final session = await db.select(db.focusSessions).getSingle();
    expect(
      (session.seconds, session.awaySeconds, session.endedAt),
      (0, 0, null),
    );
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(indexes, contains('focus_sessions_day'));
    await db.close();
    await dir.delete(recursive: true);
  });

  test('schema 6 gains the bank tables and keeps the town', () async {
    final dir = await Directory.systemTemp.createTemp('hq_migration');
    final file = File('${dir.path}/db.sqlite');
    const day = LogicalDay(2026, 11, 17);
    final at = DateTime(2026, 11, 17, 21);

    var db = AppDatabase(NativeDatabase(file));
    await AdventurerRepository(db)
        .create(name: '亞倫', now: DateTime(2026, 11, 9));
    await db
        .into(db.focusWeeks)
        .insert(
          FocusWeeksCompanion.insert(
            weekStart: const LogicalDay(2026, 11, 16),
            fromDay: day,
            dailyMinutes: 50,
            capMinutes: 600,
            earnCapMinutes: 250,
            goldPerHour: 20,
          ),
        );
    await EconomyRepository(db)
        .setEvent(amount: 7, source: 'focus', ref: day.toKey(), at: at);
    await db.close();

    db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          raw.execute('DROP TABLE bank_txns');
          raw.execute('DROP TABLE bank_accounts');
          raw.execute('DROP TABLE bank_months');
          raw.execute('DROP TABLE casino_tickets');
          raw.execute('DROP TABLE casino_weeks');
          raw.userVersion = 6;
        },
      ),
    );
    expect(await EconomyRepository(db).balance(), 7);
    expect((await db.select(db.focusWeeks).getSingle()).fromDay, day);

    // The new tables are there and take rows.
    final vault = await db
        .into(db.bankAccounts)
        .insert(
          BankAccountsCompanion.insert(
            name: '中央',
            role: const Value(AccountRole.central),
            icon: 'vault',
            createdAt: at,
          ),
        );
    await db
        .into(db.bankTxns)
        .insert(
          BankTxnsCompanion.insert(
            uid: 'a',
            kind: TxnKind.opening,
            toId: Value(vault),
            amount: 1000,
            day: day,
            at: at,
          ),
        );
    await db
        .into(db.bankMonths)
        .insert(
          BankMonthsCompanion.insert(
            month: '2026-11',
            firstDay: day,
            configJson: '{}',
            mealPlanJson: '[]',
            refill: 595,
            openedAt: at,
          ),
        );
    final txn = await db.select(db.bankTxns).getSingle();
    expect((txn.voidedAt, txn.inbox, txn.ref), (null, false, null));
    expect(
      () => db
          .into(db.bankTxns)
          .insert(
            BankTxnsCompanion.insert(
              uid: 'b',
              kind: TxnKind.expense,
              fromId: Value(vault),
              amount: 0,
              day: day,
              at: at,
            ),
          ),
      throwsA(anything),
      reason: 'amounts are positive',
    );
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      indexes,
      containsAll(['bank_txns_day', 'bank_txns_from', 'bank_txns_to']),
    );
    await db.close();
    await dir.delete(recursive: true);
  });
  test('schema 7 gains the casino tables and keeps the bank', () async {
    final dir = await Directory.systemTemp.createTemp('hq_migration');
    final file = File('${dir.path}/db.sqlite');
    const day = LogicalDay(2026, 11, 18);
    const week = LogicalDay(2026, 11, 16);
    final at = DateTime(2026, 11, 18, 21);

    var db = AppDatabase(NativeDatabase(file));
    final pool = await db
        .into(db.bankAccounts)
        .insert(
          BankAccountsCompanion.insert(
            name: '獎池',
            role: const Value(AccountRole.pool),
            icon: 'pool',
            createdAt: at,
          ),
        );
    await db
        .into(db.bankTxns)
        .insert(
          BankTxnsCompanion.insert(
            uid: 'a',
            kind: TxnKind.refill,
            toId: Value(pool),
            amount: 595,
            day: day,
            at: at,
            ref: const Value('refill:2026-11'),
          ),
        );
    await db.close();

    db = AppDatabase(
      NativeDatabase(
        file,
        setup: (raw) {
          raw.execute('DROP TABLE casino_tickets');
          raw.execute('DROP TABLE casino_weeks');
          raw.userVersion = 7;
        },
      ),
    );
    final txn = await db.select(db.bankTxns).getSingle();
    expect(
      (txn.kind, txn.amount, txn.ref),
      (TxnKind.refill, 595, 'refill:2026-11'),
    );

    // The new tables are there and take rows.
    await db
        .into(db.casinoWeeks)
        .insert(
          CasinoWeeksCompanion.insert(
            weekStart: week,
            fromDay: day,
            poolBefore: 595,
            released: 300,
            price: 6,
            targetGold: 167,
            priceLevel: 100,
            openedAt: at,
          ),
        );
    await db
        .into(db.casinoTickets)
        .insert(
          CasinoTicketsCompanion.insert(
            weekStart: week,
            kind: TicketKind.prize,
            tier: const Value(PrizeTier.top),
            amount: const Value(60),
            accountId: Value(pool),
          ),
        );
    final row = await db.select(db.casinoWeeks).getSingle();
    expect((row.termsJson, row.settledAt, row.swept), ('{}', null, null));
    final ticket = await db.select(db.casinoTickets).getSingle();
    expect((ticket.drawnAt, ticket.game, ticket.paid), (null, null, null));
    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((r) => r.read<String>('name'))
        .get();
    expect(indexes, contains('casino_tickets_week'));
    await db.close();
    await dir.delete(recursive: true);
  });
}
