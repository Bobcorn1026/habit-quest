import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/casino_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/casino_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/bank.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/casino_rules.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late ProviderContainer container;
  late EconomyRepository economy;
  late int heroId;
  // Tuesday 2026-11-17: the bank and the casino open today; the week
  // started on Monday the 16th, and November has two more Mondays.
  const nov16 = LogicalDay(2026, 11, 16);
  const nov17 = LogicalDay(2026, 11, 17);
  const nov23 = LogicalDay(2026, 11, 23);
  const nov30 = LogicalDay(2026, 11, 30);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 17, 10));
    economy = EconomyRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        randomProvider.overrideWithValue(math.Random(7)),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  CasinoService casino() => container.read(casinoServiceProvider);
  BankService bank() => container.read(bankServiceProvider);
  TownService town() => container.read(townServiceProvider);
  CasinoRepository repo() => container.read(casinoRepoProvider);
  int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);
  void goTo(LogicalDay day) =>
      clock.value = DateTime(day.year, day.month, day.day, 10);

  Future<void> hero({int gold = 1000}) async {
    final adventurers = AdventurerRepository(db);
    heroId = await adventurers.create(name: '亞倫', now: clock.now());
    await HabitRepository(db).create(
      const HabitDraft(kind: HabitKind.build, name: '讀英文'),
      const QuestDraft(rank: QuestRank.f, title: '破譯古代卷軸'),
      now: clock.now(),
      today: nov16,
    );
    if (gold > 0) {
      await economy.reward(
        amount: gold,
        source: 'test',
        ref: 'purse',
        at: clock.now(),
      );
    }
  }

  Future<int> balance(AccountRole role) async {
    final v = await bank().view();
    return v.balanceOf(v.byRole(role));
  }

  Future<int> envelopes() async {
    final v = await bank().view();
    return sum([
      for (final a in v.envelopes)
        if (a.role != AccountRole.meal) v.balanceOf(a),
    ]);
  }

  test('nothing opens before the bank does', () async {
    await hero();
    await town().rollover();
    expect(await repo().weeks(), isEmpty);
    expect((await casino().view()).closed, CasinoClosed.noBank);
  });

  group('a week', () {
    setUp(() async {
      await hero();
      await bank().open(balance: 20000);
      await town().rollover();
    });

    test('opens today with a deck worth its release', () async {
      final week = (await repo().week(nov16))!;
      expect(week.fromDay, nov17);
      // 1,820 for the rest of November, three Mondays: this week has 6 of
      // its 7 days.
      expect(week.poolBefore, 1820);
      expect(week.released, inInclusiveRange(300, 800));
      expect(week.released % unitFor(week.released), 0);
      expect(week.terms.plan.keys, ['2026-11-16', '2026-11-23', '2026-11-30']);
      expect(week.terms.days, 6);
      expect(week.terms.goldAtOpen, 1000);

      final tickets = await repo().tickets(nov16);
      final prizes = [
        for (final t in tickets)
          if (t.kind == TicketKind.prize) t,
      ];
      expect(prizes.length, inInclusiveRange(1, 36));
      expect(tickets.length - prizes.length, 4, reason: 'four refunds');
      expect(sum(prizes.map((t) => t.amount)), week.released);
      expect(prizes.where((t) => t.tier == PrizeTier.top), hasLength(1));

      // The price is set on G*: one F-rank daily commission and the
      // training ground's 83 gold over six days.
      expect(week.targetGold, 6 * 1 + 6 * 10 + 83);
      expect(
        week.targetGold * 100 / (week.price * prizes.length),
        closeTo(95, 5),
      );

      // The promised money is no longer free in the pool.
      expect(await bank().poolFree(), 1820 - week.released);
      expect(await balance(AccountRole.pool), 1820);
    });

    test('opens once however often the town turns', () async {
      final before = await repo().tickets(nov16);
      await Future.wait([town().rollover(), town().rollover()]);
      expect(await repo().weeks(), hasLength(1));
      expect(await repo().tickets(nov16), hasLength(before.length));
    });

    test('a draw pays the price and moves a prize into its envelope', () async {
      final week = (await repo().week(nov16))!;
      var gold = await economy.balance();
      final outcome = await casino().draw(game: CasinoGame.slots);
      expect(outcome.stop, DrawStop.done);
      final ticket = outcome.drawn.single;
      expect(ticket.drawnAt, isNotNull);
      expect(ticket.game, CasinoGame.slots);
      if (ticket.kind == TicketKind.prize) {
        expect(ticket.paid, week.price);
        expect(await economy.balance(), gold - week.price);
        expect(await envelopes(), ticket.amount);
        expect(await balance(AccountRole.pool), 1820 - ticket.amount);
      } else {
        expect(ticket.paid, 0);
        expect(await economy.balance(), gold);
      }
      gold = await economy.balance();

      // The whole deck: every prize paid once, the refunds free.
      final rest = await casino().draw(game: CasinoGame.grid, times: 100);
      expect(rest.stop, DrawStop.deckEmpty);
      final all = await repo().tickets(nov16);
      expect(all.every((t) => t.drawnAt != null), isTrue);
      final paidPrizes = rest.drawn.where((t) => t.kind == TicketKind.prize);
      expect(await economy.balance(), gold - paidPrizes.length * week.price);
      expect(await envelopes(), week.released);
      expect(await balance(AccountRole.pool), 1820 - week.released);
      expect(await bank().poolFree(), 1820 - week.released);
      expect(
        (await casino().draw(game: CasinoGame.slots)).stop,
        DrawStop.deckEmpty,
      );
    });

    test('no gold, no draw', () async {
      final price = (await repo().week(nov16))!.price;
      await economy.spend(
        amount: await economy.balance() - price + 1,
        source: 'test',
        ref: 'broke',
        at: clock.now(),
      );
      final outcome = await casino().draw(game: CasinoGame.slots);
      expect(outcome.stop, DrawStop.notEnoughGold);
      expect(outcome.drawn, isEmpty);
      expect(
        (await repo().tickets(nov16)).every((t) => t.drawnAt == null),
        isTrue,
      );
      expect(await envelopes(), 0);
    });

    test('a chest draws the one picked and puts the others back', () async {
      final chests = await casino().chests();
      expect(chests, hasLength(3));
      final picked = chests[1];
      final outcome = await casino().draw(
        game: CasinoGame.chest,
        ticketId: picked.id,
      );
      expect(outcome.drawn.single.id, picked.id);
      final after = {for (final t in await repo().tickets(nov16)) t.id: t};
      expect(after[picked.id]!.drawnAt, isNotNull);
      expect(after[chests[0].id]!.drawnAt, isNull);
      expect(after[chests[2].id]!.drawnAt, isNull);

      // Picking the same chest again draws nothing more.
      final again = await casino().draw(
        game: CasinoGame.chest,
        ticketId: picked.id,
      );
      expect(again.drawn, isEmpty);
    });

    test('a promotion in the week leaves the price alone', () async {
      final price = (await repo().week(nov16))!.price;
      await AdventurerRepository(db).promote(heroId, QuestRank.s, nov17);
      goTo(nov17.addDays(1));
      await town().rollover();
      expect((await repo().week(nov16))!.price, price);
    });

    test('settles once: half of what is left to invest', () async {
      final week = (await repo().week(nov16))!;
      await casino().draw(game: CasinoGame.slots, times: 3);
      final undrawn = sum([
        for (final t in await repo().tickets(nov16))
          if (t.drawnAt == null) t.amount,
      ]);

      goTo(nov23);
      await Future.wait([town().rollover(), town().rollover()]);
      final settled = (await repo().week(nov16))!;
      expect(settled.settledAt, isNotNull);
      expect(settled.swept, undrawn ~/ 2);
      expect(await balance(AccountRole.invest), undrawn ~/ 2);

      // The next week follows the month's plan and gets the rest.
      final next = (await repo().week(nov23))!;
      expect(next.fromDay, nov23);
      expect(next.terms.plan, {
        for (final e in week.terms.plan.entries)
          if (e.key != '2026-11-16') e.key: e.value,
      });
      expect(next.terms.days, 7);
      expect(next.poolBefore, 1820 - week.released + (undrawn - undrawn ~/ 2));

      // November's last week takes all that is left.
      goTo(nov30);
      await town().rollover();
      final last = (await repo().week(nov30))!;
      final free = last.poolBefore;
      expect(last.released, free ~/ unitFor(free) * unitFor(free));
    });

    test('a prize for an archived envelope goes to the everyday one', () async {
      final tickets = await repo().tickets(nov16);
      final prize = tickets.firstWhere(
        (t) => t.kind == TicketKind.prize && t.accountId != null,
      );
      final v = await bank().view();
      final general = v.byRole(AccountRole.general)!.id;
      if (prize.accountId != general) {
        await bank().archive(prize.accountId!);
      }
      final outcome = await casino().draw(
        game: CasinoGame.chest,
        ticketId: prize.id,
      );
      expect(outcome.drawn.single.accountId, general);
      final after = await bank().view();
      expect(after.balanceOf(after.byRole(AccountRole.general)), prize.amount);
    });
  });
}
