import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/progression.dart';

void main() {
  const rules = ProgressionRules();
  final at = DateTime(2026, 11, 9, 10);

  test('gold follows quest rank and the streak, capped', () {
    int gold(QuestRank r, CheckInOutcome o, int streak) =>
        checkInGold(rules: rules, rank: r, outcome: o, streakDays: streak);
    expect(gold(QuestRank.f, CheckInOutcome.done, 0), 1);
    expect(gold(QuestRank.c, CheckInOutcome.done, 14), 4);
    expect(gold(QuestRank.sss, CheckInOutcome.resisted, 400), 13);
    expect(gold(QuestRank.b, CheckInOutcome.partial, 30), 1);
    expect(gold(QuestRank.b, CheckInOutcome.relapsed, 30), 0);
  });

  test('rewards pay once, revokes take back, purchases spend', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EconomyRepository(db);
    expect(
      await repo.reward(amount: 10, source: 'perfect', ref: 'd1', at: at),
      isTrue,
    );
    expect(
      await repo.reward(amount: 10, source: 'perfect', ref: 'd1', at: at),
      isFalse,
    );
    await repo.reward(amount: 30, source: 'side', ref: 'q1', at: at);
    expect(await repo.balance(), 40);

    expect(await repo.buy('wood_oak', 50, at), isFalse, reason: 'too poor');
    expect(await repo.buy('frame_bronze', 25, at), isTrue);
    expect(await repo.balance(), 15);
    expect(await repo.watchOwned().first, {'frame_bronze'});

    await repo.revoke(source: 'perfect', ref: 'd1');
    expect(await repo.balance(), 5);
    await db.close();
  });

  test('spending takes gold once per ref and never overdraws', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EconomyRepository(db);
    await repo.reward(amount: 20, source: 'side', ref: 'q1', at: at);

    Future<SpendResult> draw(String ref, int amount) =>
        repo.spend(amount: amount, source: 'casino', ref: ref, at: at);
    expect(await draw('t:1', 6), SpendResult.spent);
    expect(await draw('t:1', 6), SpendResult.alreadySpent);
    expect(await repo.balance(), 14);
    expect(await draw('t:2', 15), SpendResult.notEnoughGold);
    expect(await repo.balance(), 14);
    expect(await draw('t:2', 14), SpendResult.spent);
    expect(await repo.balance(), 0);

    // The same ref under another source is a different thing.
    expect(
      await repo.spend(amount: 1, source: 'other', ref: 't:1', at: at),
      SpendResult.notEnoughGold,
    );
    await db.close();
  });

  test('a set event holds one running total per ref', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EconomyRepository(db);
    final later = at.add(const Duration(hours: 1));

    Future<bool> focus(String day, int amount, [DateTime? when]) => repo
        .setEvent(amount: amount, source: 'focus', ref: day, at: when ?? at);
    Future<List<GoldEventRow>> rows() => db.select(db.goldEvents).get();

    expect(await focus('2026-11-09', 0), isFalse, reason: 'nothing to remove');
    expect(await rows(), isEmpty);

    expect(await focus('2026-11-09', 3), isTrue);
    expect(await focus('2026-11-09', 3, later), isFalse, reason: 'unchanged');
    expect((await rows()).single.at, at);

    expect(await focus('2026-11-09', 7, later), isTrue);
    expect(await focus('2026-11-10', 2), isTrue);
    expect(await repo.balance(), 9);
    final day1 = (await rows()).firstWhere((r) => r.ref == '2026-11-09');
    expect((day1.amount, day1.at), (7, later));

    expect(await focus('2026-11-09', 0), isTrue);
    expect(await repo.balance(), 2);
    expect((await rows()).single.ref, '2026-11-10');
    await db.close();
  });

  test('a set event folds duplicate rows from old data into one', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = EconomyRepository(db);
    for (final amount in [4, 4, 5]) {
      await db
          .into(db.goldEvents)
          .insert(
            GoldEventsCompanion.insert(
              amount: amount,
              source: 'focus',
              ref: const Value('2026-11-09'),
              at: at,
            ),
          );
    }
    // Looks unchanged against the first row, but the total is not.
    expect(
      await repo.setEvent(
        amount: 4,
        source: 'focus',
        ref: '2026-11-09',
        at: at,
      ),
      isTrue,
    );
    expect(await repo.balance(), 4);
    expect(await db.select(db.goldEvents).get(), hasLength(1));
    await db.close();
  });
}
