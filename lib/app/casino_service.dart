import 'dart:math' as math;

import 'package:drift/drift.dart' show TableUpdateQuery, Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/bank_repository.dart';
import '../data/casino_repository.dart';
import '../data/check_in_repository.dart';
import '../data/database.dart';
import '../data/economy_repository.dart';
import '../data/focus_repository.dart';
import '../data/habit_repository.dart';
import '../domain/bank.dart';
import '../domain/casino.dart';
import '../game/casino_rules.dart';
import '../game/focus.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import '../game/streak.dart';
import 'bank_service.dart';
import 'price_service.dart';
import 'providers.dart';

/// Gold event source of a draw; the ref is [ticketGoldRef].
const kCasinoGoldSource = 'casino';

String ticketGoldRef(int ticketId) => 't:$ticketId';
String ticketTxnRef(int ticketId) => 'ticket:$ticketId';
String casinoSweepRef(LogicalDay week) => 'invest:${week.toKey()}';

/// Why there is nothing to draw this week.
enum CasinoClosed {
  /// The bank isn't open: there is no pool to pay from.
  noBank,

  /// The week hasn't opened yet (it opens with the town's next turn).
  notOpen,

  /// The pool had nothing for this week.
  emptyPool,
}

/// How a draw ended.
enum DrawStop {
  /// Drew all that was asked for.
  done,

  /// The gold ran out first.
  notEnoughGold,

  /// The deck ran out first.
  deckEmpty,

  /// The casino is closed this week.
  closed,
}

@immutable
class DrawOutcome {
  const DrawOutcome(this.drawn, this.stop);

  /// The tickets drawn, in order, as they are now (the envelope a prize
  /// went to may differ from the deck's when that one was archived).
  final List<CasinoTicketRow> drawn;
  final DrawStop stop;

  int get won => drawn.fold(0, (sum, t) => sum + t.amount);
}

/// The casino this week, as the lobby shows it.
@immutable
class CasinoView {
  const CasinoView({
    required this.today,
    this.week,
    this.tickets = const [],
    this.accounts = const {},
    this.closed,
  });

  final LogicalDay today;
  final CasinoWeekRow? week;
  final List<CasinoTicketRow> tickets;

  /// The bank's accounts by id, for the names and icons of prizes.
  final Map<int, BankAccountRow> accounts;
  final CasinoClosed? closed;

  bool get open => closed == null && week != null;
  int get price => week?.price ?? 0;

  List<CasinoTicketRow> get left => [
    for (final t in tickets)
      if (t.drawnAt == null) t,
  ];

  /// Prize tickets of [tier] still in the deck, and how many there were.
  (int left, int all) count(PrizeTier tier) {
    var left = 0, all = 0;
    for (final t in tickets) {
      if (t.tier != tier) continue;
      all++;
      if (t.drawnAt == null) left++;
    }
    return (left, all);
  }

  (int left, int all) get refunds {
    var left = 0, all = 0;
    for (final t in tickets) {
      if (t.kind != TicketKind.refund) continue;
      all++;
      if (t.drawnAt == null) left++;
    }
    return (left, all);
  }

  /// Prize money still in the deck.
  int get moneyLeft => [
    for (final t in tickets)
      if (t.drawnAt == null) t.amount,
  ].fold(0, (a, b) => a + b);

  /// What the week has paid out so far.
  int get won => [
    for (final t in tickets)
      if (t.drawnAt != null) t.amount,
  ].fold(0, (a, b) => a + b);
}

/// Opens and settles the casino's weeks and draws from their decks. All
/// money comes out of the bank's pool; all gold goes to [economy].
class CasinoService {
  CasinoService({
    required this.clock,
    required this.rules,
    required this.db,
    required this.casino,
    required this.bank,
    required this.bankService,
    required this.economy,
    required this.habits,
    required this.checkIns,
    required this.focus,
    required this.prices,
    required this.random,
  });

  final Clock clock;
  final GameRules rules;
  final AppDatabase db;
  final CasinoRepository casino;
  final BankRepository bank;
  final BankService bankService;
  final EconomyRepository economy;
  final HabitRepository habits;
  final CheckInRepository checkIns;
  final FocusRepository focus;
  final PriceService prices;
  final math.Random random;

  LogicalDay _today() =>
      LogicalDay.of(clock.now(), dayStartHour: rules.dayStartHour);

  LogicalDay _weekOf(LogicalDay day) =>
      PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn)
          .periodOf(day)
          .start;

  /// Settles the weeks that ended and opens this one. The town calls it
  /// once the bank's months are turned over and there is an adventurer.
  Future<void> rollover() async {
    if (!await bankService.isOpen()) return;
    final today = _today();
    final week = _weekOf(today);
    final first = await casino.firstWeek();
    // The clock was turned back past the casino's start; wait for it.
    if (first != null && today.isBefore(first.fromDay)) return;
    for (final row in await casino.unsettledBefore(week)) {
      await _settle(row);
    }
    if (await casino.week(week) != null) return;
    // The casino opens today; later weeks open whole.
    await _open(week, fromDay: first == null ? today : week);
  }

  Future<void> _settle(CasinoWeekRow row) => db.transaction(() async {
    final current = await casino.week(row.weekStart);
    if (current == null || current.settledAt != null) return;
    final undrawn = [
      for (final t in await casino.tickets(row.weekStart))
        if (t.kind == TicketKind.prize && t.drawnAt == null) t.amount,
    ].fold(0, (a, b) => a + b);
    final swept = sweepOf(undrawn, rules.casino);
    if (swept > 0) {
      await bank.addTxn(
        kind: TxnKind.invest,
        fromId: (await bank.byRole(AccountRole.pool))!.id,
        toId: (await bank.byRole(AccountRole.invest))!.id,
        amount: swept,
        day: row.lastDay,
        at: clock.now(),
        title: '賭場結餘',
        ref: casinoSweepRef(row.weekStart),
      );
    }
    await casino.settle(row.weekStart, at: clock.now(), swept: swept);
  });

  Future<void> _open(
    LogicalDay week, {
    required LogicalDay fromDay,
  }) => db.transaction(() async {
    if (await casino.week(week) != null) return;
    final now = clock.now();
    final poolFree = await bankService.poolFree();

    // The month's plan: drawn by its first week, followed by the rest.
    final mondays = mondaysLeftInMonth(week);
    var plan = (await casino.earlierInMonth(week))?.terms.plan ?? {};
    if (mondays.any((m) => plan[m.toKey()] == null)) {
      final drawn = releasePlan(
        weeks: mondays.length,
        rng: random,
        rules: rules.casino,
      );
      plan = {
        for (var i = 0; i < mondays.length; i++) mondays[i].toKey(): drawn[i],
      };
    }
    final openDays = 7 - fromDay.differenceInDays(week);
    final release = weeklyRelease(
      poolFree: poolFree,
      weeks: [
        for (final m in mondays)
          (percent: plan[m.toKey()]!, days: m == week ? openDays : 7),
      ],
      rules: rules.casino,
    );

    final percent = await prices.percentFor(week);
    final rest = await economy.bookedDays();
    final days = [
      for (var d = fromDay; !d.isAfter(week.addDays(6)); d = d.addDays(1))
        if (!rest.contains(d)) d,
    ].length;
    final active = await habits.active();
    final quests = <QuestOutlook>[];
    for (final aq in active) {
      final streak = computeStreak(
        habit: aq.habit,
        checkIns: await checkIns.forHabit(aq.habit.id),
        firstDay: aq.habit.firstDay,
        today: fromDay.addDays(-1),
        weekStartsOn: rules.weekStartsOn,
        restDays: rest,
      );
      quests.add((
        rank: aq.quest.rank,
        timesPerWeek: aq.habit.isDaily ? 7 : aq.habit.timesPerWeek,
        // The first check-in of the week adds a day to a daily streak.
        streakDays: streak.days + (aq.habit.isDaily ? 1 : 0),
      ));
    }
    final focusGold =
        (await focus.week(week))?.terms.maxGold ??
        FocusTerms.of(rules: rules.focus, priceLevelPercent: percent).maxGold;
    final target = expectedWeeklyGold(
      quests: quests,
      days: days,
      pricePercent: percent,
      focusGold: focusGold,
      rules: rules.progression,
    );
    final pc = priceAndCount(
      targetGold: target,
      release: release,
      rules: rules.casino,
    );

    final accounts = await bank.accounts();
    final general = accounts.firstWhere((a) => a.role == AccountRole.general);
    final deck = buildDeck(
      prizes: splitPrizes(
        total: release,
        count: pc.count,
        rng: random,
        rules: rules.casino,
      ),
      weights: {
        for (final a in accounts)
          if (a.archivedAt == null && !kSystemRoles.contains(a.role))
            a.id: a.weight,
      },
      fallbackAccount: general.id,
      rng: random,
    );
    await casino.openWeek(
      CasinoWeeksCompanion.insert(
        weekStart: week,
        fromDay: fromDay,
        poolBefore: poolFree,
        released: release,
        price: pc.price,
        targetGold: target,
        priceLevel: percent,
        termsJson: Value(
          CasinoTerms(
            plan: {for (final m in mondays) m.toKey(): plan[m.toKey()]!},
            days: days,
            questCount: quests.length,
            focusGold: focusGold,
            goldAtOpen: await economy.balance(),
          ).toJson(),
        ),
        openedAt: now,
      ),
      [
        for (final p in deck)
          (
            kind: TicketKind.prize,
            tier: p.tier,
            amount: p.amount,
            accountId: p.accountId,
          ),
        if (deck.isNotEmpty)
          for (var i = 0; i < rules.casino.refundTickets; i++)
            (kind: TicketKind.refund, tier: null, amount: 0, accountId: null),
      ],
    );
  });

  /// Up to three tickets still in this week's deck, for the chests; nothing
  /// is drawn until one is picked with [draw].
  Future<List<CasinoTicketRow>> chests() async {
    final row = await casino.week(_weekOf(_today()));
    if (row == null || row.settledAt != null) return const [];
    final left = [
      for (final t in await casino.tickets(row.weekStart))
        if (t.drawnAt == null) t,
    ]..shuffle(random);
    return left.take(3).toList();
  }

  /// Draws [times] tickets from this week's deck, or just [ticketId] (a
  /// chest that was picked). Every draw costs the week's price, except that
  /// a refund ticket gives it back; the money of a prize moves from the pool
  /// to its envelope. All of it is written before anything is shown, so an
  /// app killed mid-animation loses nothing.
  Future<DrawOutcome> draw({
    required CasinoGame game,
    int times = 1,
    int? ticketId,
  }) => db.transaction(() async {
    final row = await casino.week(_weekOf(_today()));
    if (row == null || row.settledAt != null || row.released <= 0) {
      return const DrawOutcome([], DrawStop.closed);
    }
    final now = clock.now();
    final drawn = <CasinoTicketRow>[];
    final left = [
      for (final t in await casino.tickets(row.weekStart))
        if (t.drawnAt == null) t,
    ];
    final accounts = {for (final a in await bank.accounts()) a.id: a};
    final pool = (await bank.byRole(AccountRole.pool))!.id;
    final general = (await bank.byRole(AccountRole.general))!.id;
    final wanted = ticketId == null ? times : 1;
    while (drawn.length < wanted) {
      if (left.isEmpty) return DrawOutcome(drawn, DrawStop.deckEmpty);
      // A refund is only known once drawn: every draw needs the price.
      if (await economy.balance() < row.price) {
        return DrawOutcome(drawn, DrawStop.notEnoughGold);
      }
      final CasinoTicketRow ticket;
      if (ticketId != null) {
        final picked = left.where((t) => t.id == ticketId).firstOrNull;
        if (picked == null) return DrawOutcome(drawn, DrawStop.deckEmpty);
        ticket = picked;
      } else {
        ticket = left[random.nextInt(left.length)];
      }
      left.remove(ticket);
      var paid = 0;
      var to = ticket.accountId;
      if (ticket.kind == TicketKind.prize) {
        final spent = await economy.spend(
          amount: row.price,
          source: kCasinoGoldSource,
          ref: ticketGoldRef(ticket.id),
          at: now,
        );
        if (spent == SpendResult.notEnoughGold) {
          return DrawOutcome(drawn, DrawStop.notEnoughGold);
        }
        paid = row.price;
        final account = accounts[to];
        if (account == null || account.archivedAt != null) to = general;
        if (ticket.amount > 0) {
          await bank.addTxn(
            kind: TxnKind.prize,
            fromId: pool,
            toId: to,
            amount: ticket.amount,
            day: _today(),
            at: now,
            title: '賭場獎金',
            ref: ticketTxnRef(ticket.id),
          );
        }
      }
      await casino.markDrawn(ticket.id, at: now, game: game, paid: paid);
      drawn.add(
        ticket.copyWith(
          drawnAt: Value(now),
          game: Value(game),
          paid: Value(paid),
          accountId: Value(to),
        ),
      );
    }
    return DrawOutcome(drawn, DrawStop.done);
  });

  Future<CasinoView> view() async {
    final today = _today();
    final week = _weekOf(today);
    final accounts = {for (final a in await bank.accounts()) a.id: a};
    if (!await bankService.isOpen()) {
      return CasinoView(today: today, closed: CasinoClosed.noBank);
    }
    final row = await casino.week(week);
    if (row == null) {
      return CasinoView(
        today: today,
        accounts: accounts,
        closed: CasinoClosed.notOpen,
      );
    }
    return CasinoView(
      today: today,
      week: row,
      tickets: await casino.tickets(week),
      accounts: accounts,
      closed: row.released <= 0 ? CasinoClosed.emptyPool : null,
    );
  }

  /// [view] again after every change to the casino or the bank.
  Stream<CasinoView> watchView() async* {
    yield await view();
    await for (final _ in db.tableUpdates(
      TableUpdateQuery.onAllTables({...casino.tables, ...bank.tables}),
    )) {
      yield await view();
    }
  }
}

final casinoServiceProvider = Provider<CasinoService>(
  (ref) => CasinoService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    db: ref.watch(databaseProvider),
    casino: ref.watch(casinoRepoProvider),
    bank: ref.watch(bankRepoProvider),
    bankService: ref.watch(bankServiceProvider),
    economy: ref.watch(economyRepoProvider),
    habits: ref.watch(habitRepoProvider),
    checkIns: ref.watch(checkInRepoProvider),
    focus: ref.watch(focusRepoProvider),
    prices: ref.watch(priceServiceProvider),
    random: ref.watch(randomProvider),
  ),
);

/// The casino this week; follows every change.
final casinoViewProvider = StreamProvider<CasinoView>((ref) {
  ref.watch(todayProvider);
  return ref.watch(casinoServiceProvider).watchView();
});
