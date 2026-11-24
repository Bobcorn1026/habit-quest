import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/board.dart';
import 'package:habit_quest/app/game_service.dart';
import 'package:habit_quest/app/price_service.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/price_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/game_rules.dart';
import "package:habit_quest/game/progression.dart";

void main() {
  // Monday 2026-11-09, 10:00.
  late AppDatabase db;
  late FixedClock clock;
  late EconomyRepository economy;
  late HabitRepository habits;
  late GameService game;
  const rules = GameRules();
  const today = LogicalDay(2026, 11, 9);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 9, 10));
    economy = EconomyRepository(db);
    habits = HabitRepository(db);
    game = GameService(
      clock: clock,
      rules: rules,
      habits: habits,
      checkIns: CheckInRepository(db),
      story: StoryRepository(db),
      adventurers: AdventurerRepository(db),
      settings: SettingsRepository(db),
      economy: economy,
      prices: PriceService(
        rules: rules,
        prices: PriceRepository(db),
        adventurers: AdventurerRepository(db),
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> fund(int gold) => economy.reward(
    amount: gold,
    source: 'test',
    ref: 'gold$gold',
    at: clock.now(),
  );

  group('booking', () {
    test('today and the past are rejected', () async {
      await fund(500);
      expect(await game.bookInn(today), InnResult.notFuture);
      expect(await game.bookInn(today.addDays(-1)), InnResult.notFuture);
      expect(await economy.balance(), 500);
    });

    test('more than 7 days ahead is rejected', () async {
      await fund(500);
      expect(await game.bookInn(today.addDays(8)), InnResult.tooFar);
      expect(await game.bookInn(today.addDays(7)), InnResult.booked);
    });

    test('a third booking in one week is rejected', () async {
      await fund(500);
      expect(await game.bookInn(today.addDays(1)), InnResult.booked);
      expect(await game.bookInn(today.addDays(2)), InnResult.booked);
      expect(await game.bookInn(today.addDays(3)), InnResult.weekFull);
      // Sunday 11-15 is the same week; next Monday starts a new one.
      expect(await game.bookInn(today.addDays(6)), InnResult.weekFull);
      expect(await game.bookInn(today.addDays(7)), InnResult.booked);
      expect(await economy.balance(), 350);
    });

    test('not enough gold, and no double booking', () async {
      await fund(60);
      expect(await game.bookInn(today.addDays(1)), InnResult.booked);
      expect(await game.bookInn(today.addDays(1)), InnResult.alreadyBooked);
      expect(await game.bookInn(today.addDays(2)), InnResult.notEnoughGold);
      expect(await economy.balance(), 10);
    });

    test('cancelling a future day refunds the price', () async {
      await fund(100);
      final day = today.addDays(2);
      await game.bookInn(day);
      expect(await economy.balance(), 50);
      expect(await economy.bookedDays(), {day});
      expect(await game.cancelInn(day), 50, reason: 'the refund');
      expect(await economy.balance(), 100);
      expect(await economy.bookedDays(), isEmpty);
    });

    test('bookings are not shop items', () async {
      await fund(100);
      await game.bookInn(today.addDays(1));
      await economy.buy('frame_bronze', 10, clock.now());
      expect(await economy.watchOwned().first, {'frame_bronze'});
    });
  });

  group('curses', () {
    Future<List<CurseNews>> settleAfter({required bool rest}) async {
      await fund(100);
      final created = await habits.create(
        const HabitDraft(kind: HabitKind.build, name: '讀英文'),
        const QuestDraft(rank: QuestRank.f, title: '破譯卷軸'),
        now: clock.now(),
        today: today,
      );
      final cursedDay = today.addDays(1);
      if (rest) await game.bookInn(cursedDay);
      clock.value = DateTime(2026, 11, 10, 10);
      await game.editHabit(
        created.habit.id,
        const HabitDraft(kind: HabitKind.build, name: '讀英文2'),
      );
      clock.value = DateTime(2026, 11, 11, 10);
      final active = (await habits.active()).first;
      final entry = buildEntry(
        active: active,
        checkIns: const [],
        today: cursedDay.addDays(1),
        rules: rules,
      );
      return game.settleCurses([entry]);
    }

    test('a curse on a rest day is lifted without penalty', () async {
      final news = await settleAfter(rest: true);
      expect(news.single.lifted, isTrue);
      expect(news.single.penalty, 0);
    });

    test('control: the same curse on a normal day fails', () async {
      final news = await settleAfter(rest: false);
      expect(news.single.lifted, isFalse);
    });
  });

  group('stacking', () {
    Future<ActiveQuest> add(String name) => habits.create(
      HabitDraft(kind: HabitKind.build, name: name),
      QuestDraft(rank: QuestRank.f, title: '任務$name'),
      now: clock.now(),
      today: today,
    );

    test(
      'anchor can be set, changed and cleared; cycles are rejected',
      () async {
        final a = await add('A');
        final b = await add('B');
        expect(
          await habits.setAnchor(a.habit.id, anchorHabitId: a.habit.id),
          isFalse,
        );
        expect(
          await habits.setAnchor(a.habit.id, anchorHabitId: b.habit.id),
          isTrue,
        );
        expect((await habits.habit(a.habit.id)).anchorHabitId, b.habit.id);
        expect(
          await habits.setAnchor(b.habit.id, anchorHabitId: a.habit.id),
          isFalse,
        );
        expect((await habits.habit(b.habit.id)).anchorHabitId, isNull);

        expect(await habits.setAnchor(a.habit.id, anchorText: ' 刷完牙 '), isTrue);
        final h = await habits.habit(a.habit.id);
        expect(h.anchorText, '刷完牙');
        expect(h.anchorHabitId, isNull);

        expect(await habits.setAnchor(a.habit.id), isTrue);
        final cleared = await habits.habit(a.habit.id);
        expect(cleared.anchorText, isNull);
        expect(cleared.anchorHabitId, isNull);
      },
    );

    test('changing only the anchor does not curse the day', () async {
      final a = await add('A');
      final b = await add('B');
      final cursed = await game.editHabit(
        a.habit.id,
        HabitDraft(kind: HabitKind.build, name: 'A', anchorHabitId: b.habit.id),
      );
      expect(cursed, HabitEditResult.anchorOnly);
      final h = await habits.habit(a.habit.id);
      expect(h.cursedOn, isNull);
      expect(h.anchorHabitId, b.habit.id);

      final cleared = await game.editHabit(
        a.habit.id,
        const HabitDraft(kind: HabitKind.build, name: 'A'),
      );
      expect(cleared, HabitEditResult.anchorOnly);
      expect((await habits.habit(a.habit.id)).anchorHabitId, isNull);
    });

    test('saving with nothing changed does not curse the day', () async {
      final a = await add('A');
      final result = await game.editHabit(
        a.habit.id,
        const HabitDraft(kind: HabitKind.build, name: 'A'),
      );
      expect(result, HabitEditResult.unchanged);
      expect((await habits.habit(a.habit.id)).cursedOn, isNull);
    });

    test('a real edit still curses, and saves the anchor with it', () async {
      final a = await add('A');
      final cursed = await game.editHabit(
        a.habit.id,
        const HabitDraft(kind: HabitKind.build, name: 'A2', anchorText: '吃完午餐'),
      );
      expect(cursed, HabitEditResult.cursed);
      final h = await habits.habit(a.habit.id);
      expect(h.cursedOn, today);
      expect(h.anchorText, '吃完午餐');
    });
  });
}
