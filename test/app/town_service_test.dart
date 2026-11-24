import 'package:drift/drift.dart' show OrderingTerm, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/domain/quest_rank.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late ProviderContainer container;
  late AdventurerRepository adventurers;
  late EconomyRepository economy;
  late int heroId;
  // Monday 2026-11-09; the town opens on Wednesday.
  const monday = LogicalDay(2026, 11, 9);
  const wednesday = LogicalDay(2026, 11, 11);
  const nextMonday = LogicalDay(2026, 11, 16);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 11, 10));
    adventurers = AdventurerRepository(db);
    economy = EconomyRepository(db);
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

  TownService town() => container.read(townServiceProvider);
  Future<List<FocusWeekRow>> weeks() => (db.select(
    db.focusWeeks,
  )..orderBy([(t) => OrderingTerm.asc(t.weekStart)])).get();

  /// A rank-D adventurer (prices ×1.5, 30 gold an hour) with [gold].
  Future<void> hero({int gold = 100}) async {
    heroId = await adventurers.create(name: '亞倫', now: clock.now());
    await adventurers.promote(heroId, QuestRank.d, monday);
    if (gold > 0) {
      await economy.reward(
        amount: gold,
        source: 'test',
        ref: 'purse',
        at: clock.now(),
      );
    }
  }

  Future<void> focus(LogicalDay day, int minutes) async {
    final start = DateTime(day.year, day.month, day.day, 12);
    await db
        .into(db.focusSessions)
        .insert(
          FocusSessionsCompanion.insert(
            day: day,
            startedAt: start,
            lastSeenAt: start.add(Duration(minutes: minutes)),
            endedAt: Value(start.add(Duration(minutes: minutes))),
            seconds: Value(minutes * 60),
          ),
        );
  }

  void goTo(LogicalDay day) =>
      clock.value = DateTime(day.year, day.month, day.day, 10);

  test('nothing opens before there is an adventurer', () async {
    await town().rollover();
    expect(await weeks(), isEmpty);
  });

  test('focus counts from the day the town first opens', () async {
    await hero();
    // Two passes at once (start-up and a new day) open the week once.
    await Future.wait([town().rollover(), town().rollover()]);
    await town().rollover();

    final row = (await weeks()).single;
    expect(
      (
        row.weekStart,
        row.fromDay,
        row.dailyMinutes,
        row.capMinutes,
        row.earnCapMinutes,
        row.goldPerHour,
        row.settledAt,
      ),
      (monday, wednesday, 50, 600, 250, 30, null),
    );
  });

  test('a week that ends in debt is fined at its own rate', () async {
    await hero();
    await town().rollover();
    // Wednesday pays its 50 minutes and earns on 30 more (15 gold at D);
    // Thursday leaves 30 owed, and Friday to Sunday add 50 each.
    await focus(wednesday, 80);
    await focus(wednesday.addDays(1), 20);
    // A promotion on Thursday only shows next week.
    await adventurers.promote(heroId, QuestRank.b, wednesday.addDays(1));

    goTo(nextMonday);
    await town().rollover();
    await town().rollover();

    final rows = await weeks();
    expect(rows, hasLength(2));
    final last = rows.first;
    expect(last.settledAt, clock.now());
    // 180 minutes × 30 gold an hour × 30%.
    expect((last.unpaidSeconds, last.penalty), (180 * 60, 27));
    // The gold of Wednesday, which no timer wrote here, is paid as well.
    expect(
      await economy
          .watchEvent(source: kFocusGoldSource, ref: wednesday.toKey())
          .first,
      15,
    );
    expect(await economy.balance(), 100 + 15 - 27);

    final current = rows.last;
    expect((current.weekStart, current.fromDay), (nextMonday, nextMonday));
    expect((current.goldPerHour, current.settledAt), (44, null));
  });

  test('the fine never takes more gold than there is', () async {
    await hero(gold: 10);
    await town().rollover();
    goTo(nextMonday);
    await town().rollover();

    final last = (await weeks()).first;
    // Five days of 50 minutes would be 37.
    expect((last.unpaidSeconds, last.penalty), (250 * 60, 10));
    expect(await economy.balance(), 0);
  });

  test('rest days add no debt', () async {
    await hero();
    await town().rollover();
    await focus(wednesday, 50);
    for (var i = 1; i <= 4; i++) {
      await economy.bookInn(wednesday.addDays(i), 0, clock.now());
    }
    goTo(nextMonday);
    await town().rollover();

    final last = (await weeks()).first;
    expect((last.unpaidSeconds, last.penalty), (0, 0));
    expect(await economy.balance(), 100);
  });

  test('after weeks away only the week that just ended is fined', () async {
    await hero();
    await town().rollover();
    // Back on Wednesday three weeks later.
    goTo(wednesday.addDays(21));
    await town().rollover();

    final rows = await weeks();
    expect(rows.map((r) => r.weekStart), [
      monday,
      monday.addDays(14),
      monday.addDays(21),
    ]);
    // The first week is closed without a fine …
    expect(rows[0].settledAt, isNotNull);
    expect((rows[0].unpaidSeconds, rows[0].penalty), (250 * 60, 0));
    // … the week just ended owes all seven days: 350 minutes, 52 gold …
    expect(rows[1].fromDay, monday.addDays(14));
    expect((rows[1].unpaidSeconds, rows[1].penalty), (350 * 60, 52));
    // … and this week is open.
    expect(rows[2].settledAt, isNull);
    expect(await economy.balance(), 100 - 52);
  });

  test('changed settings fix the terms of the next week', () async {
    await hero();
    await town().rollover();
    await SettingsRepository(db)
        .write(SettingKeys.focus, {'dailyMinutes': 30, 'goalMinutes': 420});
    // Coming back to the app in the same week changes nothing.
    await town().rollover();
    expect((await weeks()).single.dailyMinutes, 50);

    goTo(nextMonday);
    await town().rollover();
    final rows = await weeks();
    // The week that ended was settled on its own terms: five days of 50.
    expect(
      (
        rows.first.dailyMinutes,
        rows.first.capMinutes,
        rows.first.unpaidSeconds,
      ),
      (50, 600, 250 * 60),
    );
    final current = rows.last;
    expect(
      (current.dailyMinutes, current.capMinutes, current.earnCapMinutes),
      (30, 420, 210),
    );
  });

  test('a call during a pass runs it once more', () async {
    // The first pass looks for an adventurer before one signs up …
    final first = town().rollover();
    final signedUp = hero();
    // … and the sign-up's own call must not be lost.
    final second = town().rollover();
    await Future.wait([first, signedUp, second]);
    expect((await weeks()).single.fromDay, wednesday);
  });
}
