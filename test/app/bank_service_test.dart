import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/bank_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/domain/bank.dart';

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late ProviderContainer container;
  // Tuesday 2026-11-17, 10:00: 14 days left in November.
  const nov17 = LogicalDay(2026, 11, 17);

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime(2026, 11, 17, 10));
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

  BankService bank() => container.read(bankServiceProvider);
  BankRepository repo() => container.read(bankRepoProvider);
  void at(LogicalDay day, [int hour = 10]) =>
      clock.value = DateTime(day.year, day.month, day.day, hour);
  int sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);
  Future<BankView> view() => bank().view();
  Future<int> balance(AccountRole role) async {
    final v = await view();
    return v.balanceOf(v.byRole(role));
  }

  Future<BankAccountRow> named(String name) async =>
      (await view()).accounts.singleWhere((a) => a.name == name);

  group('opening the bank', () {
    test('creates the envelopes, the vault and a prorated month', () async {
      expect(await bank().isOpen(), isFalse);
      await bank().open(balance: 20000);
      expect(await bank().isOpen(), isTrue);

      final v = await view();
      expect(v.opened, isTrue);
      expect(v.envelopes.map((a) => a.name), [
        '通用',
        '餐費',
        '額外食物',
        '社交',
        '遊戲',
        '其他娛樂',
        '外表',
        '專案',
        '投資',
      ]);
      expect(v.byRole(AccountRole.central), isNotNull);
      expect(v.byRole(AccountRole.pool), isNotNull);
      expect(v.envelopes.any((a) => kSystemRoles.contains(a.role)), isFalse);

      // 14 of 30 days: 2,330 of meals, 1,820 to the pool, 140 set aside.
      expect(v.total, 20000);
      expect(v.pool, 1820);
      expect(v.vault, 20000 - 1820);
      expect(v.month!.firstDay, nov17);
      expect(v.month!.mealPlan, hasLength(14));
      expect(v.mealAhead, 2330);
      expect(v.reserves.single.name, '年費訂閱');
      expect(v.reserved, 140);
      expect(v.todayMeal, isNotNull);
      expect(v.missedDays, isEmpty);
    });

    test('happens once', () async {
      await bank().open(balance: 20000);
      await bank().open(balance: 5);
      final v = await view();
      expect(v.total, 20000);
      expect(v.envelopes, hasLength(9));
    });

    test('the demo opens it with a few envelopes filled', () async {
      await bank().openDemo();
      await bank().openDemo();
      final v = await view();
      expect(v.total, 20000 - 250);
      expect(v.balanceOf(await named('遊戲')), 120);
      expect(v.balanceOf(await named('外表')), -250);
    });

    test('an overdrawn account opens in the red', () async {
      await bank().open(balance: -300);
      expect((await view()).total, -300);
    });
  });

  group('meal money', () {
    setUp(() => bank().open(balance: 20000));

    test('is handed out once a day, from the vault', () async {
      final v = await view();
      final amount = await bank().claimMeal(nov17);
      expect(amount, v.todayMeal);
      expect(await bank().claimMeal(nov17), isNull, reason: 'once');
      expect(await balance(AccountRole.meal), amount);
      expect(await balance(AccountRole.central), v.vault - amount!);
      expect((await view()).claimedToday, isTrue);
    });

    test('missed days can be claimed later; days to come cannot', () async {
      expect(await bank().claimMeal(nov17.addDays(1)), isNull);
      at(nov17.addDays(3));
      final v = await view();
      expect(v.missedDays, [nov17, nov17.addDays(1), nov17.addDays(2)]);
      for (final day in v.missedDays) {
        expect(await bank().claimMeal(day), v.month!.mealOn(day));
      }
      expect((await view()).missedDays, isEmpty);
      expect(await bank().claimMeal(nov17.addDays(-1)), isNull);
    });

    test('a month ends with every meal handed out and none left', () async {
      // Spend a little less than the meals of the first three days.
      final v = await view();
      final plan = v.month!.mealPlan;
      await bank().claimMeal(nov17);
      final meal = v.byRole(AccountRole.meal)!.id;
      await bank().spend(accountId: meal, amount: 100, title: '午餐');

      at(const LogicalDay(2026, 12, 2));
      await bank().rollover();
      final after = await view();
      expect(after.balanceOf(after.byRole(AccountRole.meal)), 0);
      // November's meals were all handed out; what was not eaten went to
      // the pool, with December's refill.
      expect(await repo().mealDays(nov17, const LogicalDay(2026, 11, 30)), {
        for (var i = 0; i < 14; i++) nov17.addDays(i),
      });
      expect(after.pool, 1820 + sum(plan) - 100 + 3900);
      expect(after.month!.month, '2026-12');
      expect(after.month!.mealPlan, hasLength(31));
      expect(sum(after.month!.mealPlan), 5000);
      expect(after.missedDays, [const LogicalDay(2026, 12, 1)]);
      expect(after.reserved, 140 + 300);
      // December: income in, the gym out, the pool topped up; the total
      // only moved by what came in and went out.
      expect(after.total, 20000 - 100 + 10000 - 800);
    });

    test('an overdraft is covered by the pool, then the vault', () async {
      final meal = (await view()).byRole(AccountRole.meal)!.id;
      // 2,330 of meals; 3,000 spent: 670 over, the pool (1,820) pays.
      await bank().spend(accountId: meal, amount: 3000, title: '吃大餐');
      at(const LogicalDay(2026, 12, 1));
      await bank().rollover();
      var v = await view();
      expect(v.balanceOf(v.byRole(AccountRole.meal)), 0);
      expect(v.pool, 1820 - 670 + 3900);

      // December: 5,000 of meals, 11,000 spent: the pool (5,050) is not
      // enough, the vault pays the rest.
      await bank().spend(accountId: meal, amount: 11000, title: '吃更大的餐');
      final vaultBefore = v.vault;
      at(const LogicalDay(2027, 1, 1));
      await bank().rollover();
      v = await view();
      expect(v.balanceOf(v.byRole(AccountRole.meal)), 0);
      expect(v.pool, 3900, reason: 'emptied, then January refill');
      expect(v.vault, vaultBefore - 5000 - (6000 - 5050) + 10000 - 800 - 3900);
    });

    test('months the app missed are run through one by one', () async {
      at(const LogicalDay(2027, 2, 3));
      await bank().rollover();
      final months = await repo().months();
      expect(months.map((m) => m.month), [
        '2026-11',
        '2026-12',
        '2027-01',
        '2027-02',
      ]);
      expect(months.take(3).every((m) => m.closedAt != null), isTrue);
      expect(months.last.closedAt, isNull);
      final v = await view();
      expect(v.balanceOf(v.byRole(AccountRole.meal)), 0);
      expect(v.total, 20000 + 3 * (10000 - 800));
      // Meals nobody spent went to the pool.
      expect(v.pool, 1820 + 2330 + 3 * 3900 + 5000 * 2);
      // A second pass does nothing.
      await bank().rollover();
      expect((await view()).total, v.total);
    });

    test('a clock turned back waits', () async {
      at(const LogicalDay(2026, 10, 30));
      await bank().rollover();
      expect(await repo().months(), hasLength(1));
      expect(await bank().claimMeal(nov17), isNull);
    });

    test('the town turns the bank over too, without an adventurer', () async {
      at(const LogicalDay(2026, 12, 1));
      await container.read(townServiceProvider).rollover();
      expect((await repo().latestMonth())!.month, '2026-12');
    });

    test('a changed config counts from the next month', () async {
      await bank().saveConfig(
        const BankConfig().copyWith(income: 11000, meal: 5600),
      );
      expect((await view()).mealAhead, 2330);
      at(const LogicalDay(2026, 12, 1));
      await bank().rollover();
      final v = await view();
      expect(sum(v.month!.mealPlan), 5600);
      expect(v.month!.refill, 11000 - 5600 - 800 - 300);
      expect(v.month!.config.income, 11000);
    });
  });

  group('moving money', () {
    setUp(() => bank().open(balance: 20000));

    /// Gives [name] money the way the casino will: from the pool.
    Future<void> fill(String name, int amount) async {
      final v = await view();
      await repo().addTxn(
        kind: TxnKind.transfer,
        fromId: v.byRole(AccountRole.pool)!.id,
        toId: (await named(name)).id,
        amount: amount,
        day: nov17,
        at: clock.now(),
      );
    }

    test('a transfer pays 10% to the pool, rounded up', () async {
      await fill('遊戲', 500);
      final game = await named('遊戲');
      final social = await named('社交');
      final pool = (await view()).pool;
      expect(
        await bank().transfer(fromId: game.id, toId: social.id, amount: 101),
        TransferResult.done,
      );
      var v = await view();
      expect(v.balanceOf(game), 399);
      expect(v.balanceOf(social), 90);
      expect(v.pool, pool + 11);

      // Undoing it undoes the fee too.
      final txns = await repo().txns(accountId: game.id);
      expect(await bank().voidTxn(txns.first.id), isTrue);
      v = await view();
      expect(v.balanceOf(game), 500);
      expect(v.balanceOf(social), 0);
      expect(v.pool, pool);
    });

    test('out of the everyday envelope is free', () async {
      await fill('通用', 100);
      final general = await named('通用');
      final social = await named('社交');
      await bank().transfer(fromId: general.id, toId: social.id, amount: 100);
      expect((await view()).balanceOf(social), 100);
    });

    test('meal money, the vault and the pool stay put', () async {
      await bank().claimMeal(nov17);
      final v = await view();
      final meal = v.byRole(AccountRole.meal)!;
      final social = await named('社交');
      final vault = v.byRole(AccountRole.central)!;
      final pool = v.byRole(AccountRole.pool)!;
      for (final (from, to) in [
        (meal.id, social.id),
        (vault.id, social.id),
        (pool.id, social.id),
        (social.id, vault.id),
        (social.id, pool.id),
        (social.id, social.id),
      ]) {
        expect(
          await bank().transfer(fromId: from, toId: to, amount: 10),
          TransferResult.notAllowed,
          reason: '$from → $to',
        );
      }
    });

    test('no more than the envelope has, and more than the fee', () async {
      await fill('遊戲', 50);
      final game = await named('遊戲');
      final social = await named('社交');
      expect(
        await bank().transfer(fromId: game.id, toId: social.id, amount: 60),
        TransferResult.notEnough,
      );
      expect(
        await bank().transfer(fromId: game.id, toId: social.id, amount: 1),
        TransferResult.tooSmall,
      );
    });

    test('spending can take an envelope into the red', () async {
      final looks = await named('外表');
      await bank().spend(accountId: looks.id, amount: 300, title: '剪頭髮');
      expect((await view()).balanceOf(looks), -300);
    });

    test(
      'paying a yearly bill from the vault uses what was set aside',
      () async {
        final vault = (await view()).byRole(AccountRole.central)!;
        await bank().spend(
          accountId: vault.id,
          amount: 100,
          title: '年費',
          fixedId: 'subscription',
        );
        expect((await view()).reserved, 40);
        await bank().spend(
          accountId: vault.id,
          amount: 6300,
          title: '年費',
          fixedId: 'subscription',
        );
        expect((await view()).reserved, 0, reason: 'never below zero');
      },
    );

    test('reconciling corrects the vault to the real balance', () async {
      expect(await bank().reconcile(19500), -500);
      expect((await view()).total, 19500);
      expect(await bank().reconcile(19500), 0);
      expect(await bank().reconcile(19600), 100);
      expect((await view()).total, 19600);
    });

    test('only what was recorded by hand, or monthly, can be undone', () async {
      await bank().claimMeal(nov17);
      final looks = await named('外表');
      await bank().earn(accountId: looks.id, amount: 50, title: '紅包');
      final txns = await repo().txns();
      final meal = txns.firstWhere((t) => t.kind == TxnKind.meal);
      final refill = txns.firstWhere((t) => t.kind == TxnKind.refill);
      final opening = txns.firstWhere((t) => t.kind == TxnKind.opening);
      final income = txns.firstWhere((t) => t.kind == TxnKind.income);
      expect(await bank().voidTxn(meal.id), isFalse);
      expect(await bank().voidTxn(refill.id), isFalse);
      expect(await bank().voidTxn(opening.id), isFalse);
      expect(await bank().voidTxn(income.id), isTrue);
      expect(await bank().voidTxn(income.id), isFalse, reason: 'once');
      expect((await view()).balanceOf(looks), 0);
    });

    test('a voided monthly charge is not charged again', () async {
      at(const LogicalDay(2026, 12, 1));
      await bank().rollover();
      final gym = (await repo().txns()).firstWhere(
        (t) => t.kind == TxnKind.fixed,
      );
      final total = (await view()).total;
      expect(await bank().voidTxn(gym.id), isTrue);
      await bank().rollover();
      expect((await view()).total, total + 800);
    });
  });

  group('envelopes', () {
    setUp(() => bank().open(balance: 0));

    test('can be added, renamed and archived when empty', () async {
      final id = await bank().addEnvelope(name: '旅行', icon: 'fun');
      var v = await view();
      expect(v.envelopes.last.name, '旅行');
      await bank().editEnvelope(id, name: '旅遊');
      await bank().spend(accountId: id, amount: 10, title: '車票');
      expect(await bank().archive(id), ArchiveResult.notEmpty);
      await bank().earn(accountId: id, amount: 10, title: '退票');
      expect(await bank().archive(id), ArchiveResult.done);
      v = await view();
      expect(v.envelopes.map((a) => a.name), isNot(contains('旅遊')));
      expect(v.archived.single.name, '旅遊');
      await bank().unarchive(id);
      expect((await view()).archived, isEmpty);
    });

    test('the ones with a role stay', () async {
      for (final name in ['通用', '餐費', '投資']) {
        expect(
          await bank().archive((await named(name)).id),
          ArchiveResult.kept,
        );
      }
      expect(await bank().archive((await named('遊戲')).id), ArchiveResult.done);
    });
  });

  test('the view follows every change', () async {
    await bank().open(balance: 1000);
    final seen = <int>[];
    final sub = container.listen(
      bankViewProvider,
      (_, next) => next.whenData((v) => seen.add(v.total)),
      fireImmediately: true,
    );
    await container.read(bankViewProvider.future);
    final general = (await view()).envelopes.first;
    await bank().earn(accountId: general.id, amount: 5, title: '撿到');
    await pumpEventQueue();
    expect(seen.last, 1005);
    sub.close();
  });
}
