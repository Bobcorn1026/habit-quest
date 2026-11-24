import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/board.dart';
import 'package:habit_quest/app/game_service.dart';
import 'package:habit_quest/app/price_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late ProviderContainer container;
  late AdventurerRepository adventurers;
  late int heroId;
  // Monday 2026-11-09.
  const monday = LogicalDay(2026, 11, 9);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 9, 10));
    adventurers = AdventurerRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> hero(QuestRank rank) async {
    heroId = await adventurers.create(name: '亞倫', now: clock.now());
    if (rank != QuestRank.f) await adventurers.promote(heroId, rank, monday);
  }

  PriceService prices() => container.read(priceServiceProvider);
  Future<List<PriceWeekRow>> weeks() => db.select(db.priceWeeks).get();

  test('nothing is fixed before there is an adventurer', () async {
    expect(await prices().percentFor(monday), 100);
    expect(await weeks(), isEmpty);
  });

  test('a week keeps the level it started with', () async {
    await hero(QuestRank.d);
    expect(await prices().percentFor(monday), 150);

    // Promoted on Wednesday: the rest of the week is unchanged …
    await adventurers.promote(heroId, QuestRank.c, monday.addDays(2));
    expect(await prices().percentFor(monday.addDays(2)), 150);
    expect(await prices().percentFor(monday.addDays(6)), 150);
    // … and the Monday after, prices follow.
    expect(await prices().percentFor(monday.addDays(7)), 180);

    final rows = await weeks();
    expect(rows.map((r) => (r.weekStart, r.rank, r.percent)), [
      (monday, QuestRank.d, 150),
      (monday.addDays(7), QuestRank.c, 180),
    ]);
  });

  test('the level of this week is watched from the first look', () async {
    await hero(QuestRank.e);
    final seen = <int>[];
    final sub = container.listen(
      priceLevelProvider,
      (_, next) => seen.addAll([?next.value]),
      fireImmediately: true,
    );
    await container.read(priceLevelProvider.future);
    expect(seen.last, 120);
    expect((await weeks()).single.weekStart, monday);
    sub.close();
  });

  test('the week is fixed once an adventurer signs up', () async {
    final sub = container.listen(priceLevelProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await container.read(priceLevelProvider.future), 100);
    // Let the watch on the (empty) week settle, as it has in a running app.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(await weeks(), isEmpty);

    // Onboarding finishes while the app is open.
    await hero(QuestRank.f);
    for (var i = 0; i < 200 && (await weeks()).isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    final row = (await weeks()).single;
    expect((row.weekStart, row.rank, row.percent), (monday, QuestRank.f, 100));
  });

  group('what the game pays and charges', () {
    /// The board once it has loaded and holds [count] entries.
    Future<BoardState> board(int count) async {
      for (var i = 0; i < 200; i++) {
        final state = container.read(boardProvider).value;
        if (state != null && state.entries.length == count) return state;
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      fail('the board never loaded');
    }

    Future<CheckInResult> reportToday() async {
      container.read(todayProvider.notifier).refresh();
      final entry = (await board(1)).entries.single;
      return container
          .read(gameServiceProvider)
          .report(entry, outcome: CheckInOutcome.done);
    }

    setUp(() async {
      await hero(QuestRank.d);
      await HabitRepository(db).create(
        const HabitDraft(kind: HabitKind.build, name: '讀英文'),
        const QuestDraft(rank: QuestRank.c, title: '破譯古代卷軸'),
        now: clock.now(),
        today: monday,
      );
      final sub = container.listen(boardProvider, (_, _) {});
      addTearDown(sub.close);
    });

    test('commissions and perfect days follow the week', () async {
      final economy = EconomyRepository(db);
      // Rank C pays 2, a perfect day 10; at D that is ×1.5.
      final first = await reportToday();
      expect((first.gold, first.perfectBonus), (3, 15));
      expect(await economy.balance(), 18);

      // A promotion on Tuesday waits for the next Monday.
      await adventurers.promote(heroId, QuestRank.b, monday.addDays(1));
      clock.advance(const Duration(days: 1));
      final second = await reportToday();
      expect((second.gold, second.perfectBonus), (3, 15));

      clock.advance(const Duration(days: 6));
      final third = await reportToday();
      // ×2.2: 2 → 4.4 → 4, 10 → 22.
      expect((third.gold, third.perfectBonus), (4, 22));
      expect(await economy.balance(), 18 + 18 + 26);
    });

    test(
      'a night at the inn costs this week\'s price and refunds it',
      () async {
        final economy = EconomyRepository(db);
        final game = container.read(gameServiceProvider);
        await economy.reward(
          amount: 300,
          source: 'test',
          ref: 'purse',
          at: clock.now(),
        );
        expect(await game.bookInn(monday.addDays(1)), InnResult.booked);
        expect(await economy.balance(), 300 - 75);

        await adventurers.promote(heroId, QuestRank.b, monday);
        expect(await game.bookInn(monday.addDays(2)), InnResult.booked);
        expect(await economy.balance(), 300 - 150, reason: 'same week');

        // Next week a night is 110, but the old booking refunds what it cost.
        clock.advance(const Duration(days: 7));
        expect(await game.bookInn(monday.addDays(8)), InnResult.booked);
        expect(await economy.balance(), 300 - 150 - 110);
        expect(await game.cancelInn(monday.addDays(8)), 110);
        expect(await game.cancelInn(monday.addDays(8)), isNull);
        expect(await economy.balance(), 300 - 150);
      },
    );
  });
}
