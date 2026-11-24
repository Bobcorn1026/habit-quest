import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/logical_day.dart';
import '../domain/bank.dart';
import '../domain/casino.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';
import '../domain/upgrade_offer.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Adventurers,
    Habits,
    Quests,
    CheckIns,
    XpEvents,
    GoldEvents,
    Purchases,
    PriceWeeks,
    FocusWeeks,
    FocusSessions,
    BankAccounts,
    BankTxns,
    BankMonths,
    CasinoWeeks,
    CasinoTickets,
    Chapters,
    UpgradeOffers,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Tests pass an in-memory executor.
  AppDatabase(super.e);

  AppDatabase.defaults() : super(driftDatabase(name: 'habit_quest'));

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        for (final c in [
          adventurers.classStats,
          adventurers.classSince,
          adventurers.classFlavor,
          adventurers.portraitId,
          adventurers.guildRank,
          adventurers.rankSince,
          adventurers.trialStart,
        ]) {
          await m.addColumn(adventurers, c);
        }
        await m.addColumn(habits, habits.cursedOn);
        await m.addColumn(quests, quests.attribute);
      }
      if (from < 3) {
        await m.addColumn(checkIns, checkIns.gold);
        await m.createTable(goldEvents);
        await m.createTable(purchases);
        // Past commissions pay their base gold, so nobody starts broke.
        await customStatement('''
          UPDATE check_ins SET gold = (
            SELECT CASE quests.rank
              WHEN 'f' THEN 1 WHEN 'e' THEN 1 WHEN 'd' THEN 2 WHEN 'c' THEN 2
              WHEN 'b' THEN 3 WHEN 'a' THEN 4 WHEN 's' THEN 5 WHEN 'ss' THEN 6
              ELSE 8 END
            FROM quests WHERE quests.id = check_ins.quest_id)
          WHERE outcome IN ('done', 'resisted')
        ''');
      }
      if (from < 4) {
        for (final index in [checkInsDay, checkInsQuest, questsHabitActive]) {
          // Drop first so a half-finished earlier attempt can't block it.
          await m.drop(index);
          await m.create(index);
        }
      }
      if (from < 5) {
        await m.addColumn(habits, habits.anchorHabitId);
        await m.addColumn(habits, habits.anchorText);
      }
      if (from < 6) {
        // The town: new tables only, nothing existing is touched.
        await m.createTable(priceWeeks);
        await m.createTable(focusWeeks);
        await m.createTable(focusSessions);
        await m.drop(focusSessionsDay);
        await m.create(focusSessionsDay);
      }
      if (from < 7) {
        // The bank: new tables only.
        await m.createTable(bankAccounts);
        await m.createTable(bankTxns);
        await m.createTable(bankMonths);
        for (final index in [bankTxnsDay, bankTxnsFrom, bankTxnsTo]) {
          await m.drop(index);
          await m.create(index);
        }
      }
      if (from < 8) {
        // The casino: new tables only.
        await m.createTable(casinoWeeks);
        await m.createTable(casinoTickets);
        await m.drop(casinoTicketsWeek);
        await m.create(casinoTicketsWeek);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
