import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/database.dart';
import '../data/economy_repository.dart';
import '../data/focus_repository.dart';
import '../data/settings_repository.dart';
import '../domain/focus_settings.dart';
import '../game/focus.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import 'bank_service.dart';
import 'casino_service.dart';
import 'price_service.dart';
import 'providers.dart';

/// Gold event source of a day's focus gold; the ref is the day's key.
const kFocusGoldSource = 'focus';

/// Gold event source of a week's fine; the ref is the key of its first day.
const kFocusPenaltySource = 'focus_penalty';

/// Turns the town's weeks and months over: the training ground's weeks and
/// the bank's months and the casino's weeks.
class TownService {
  TownService({
    required this.clock,
    required this.rules,
    required this.db,
    required this.adventurers,
    required this.focus,
    required this.economy,
    required this.settings,
    required this.prices,
    required this.bank,
    required this.casino,
  });

  final Clock clock;
  final GameRules rules;
  final AppDatabase db;
  final AdventurerRepository adventurers;
  final FocusRepository focus;
  final EconomyRepository economy;
  final SettingsRepository settings;
  final PriceService prices;
  final BankService bank;
  final CasinoService casino;

  Future<void>? _running;
  bool _again = false;

  /// Settles the training-ground week that ended and opens this one. Safe
  /// to call at any time and as often as wanted: a call during a pass makes
  /// that pass run once more, and both callers wait for it.
  Future<void> rollover() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    return _running = _passes().whenComplete(() => _running = null);
  }

  Future<void> _passes() async {
    do {
      _again = false;
      await _rollover();
    } while (_again);
  }

  LogicalDay _weekOf(LogicalDay day) =>
      PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn)
          .periodOf(day)
          .start;

  Future<void> _rollover() async {
    // The bank keeps real money and doesn't wait for an adventurer.
    await bank.rollover();
    // Focus and the casino start with the adventurer; the casino's price
    // reads the focus week, so focus goes first.
    if (await adventurers.get() == null) return;
    await _focusRollover();
    await casino.rollover();
  }

  Future<void> _focusRollover() async {
    final now = clock.now();
    final today = LogicalDay.of(now, dayStartHour: rules.dayStartHour);
    final week = _weekOf(today);
    final first = await focus.firstDay();
    if (first == null) {
      // The town opens today: no debt for the days before.
      await _open(week, fromDay: today);
      return;
    }
    // The clock was turned back past the start; wait for it to catch up.
    if (today.isBefore(first)) return;

    final last = week.addDays(-7);
    // The week that just ended is settled even if the app was never opened
    // in it, as long as focus was on by then.
    if (!last.addDays(6).isBefore(first)) {
      await _open(last, fromDay: first.isAfter(last) ? first : last);
    }
    for (final row in await focus.unsettledBefore(week)) {
      // A session still open in the week (running over Monday 04:00, or one
      // the app died in until the timer ends it) has seconds yet to save:
      // the week waits, and the timer calls again once it ends.
      if (await focus.hasOpenSession(row.weekStart, row.weekStart.addDays(6))) {
        continue;
      }
      // Only the week that just ended is fined; weeks before it, when the
      // player was away, are let go.
      await _settle(row, fine: row.weekStart == last, now: now);
    }
    await _open(week, fromDay: first.isAfter(week) ? first : week);
  }

  /// Opens a week on the terms of its price level and the player's
  /// settings as they are now.
  Future<void> _open(LogicalDay week, {required LogicalDay fromDay}) async {
    if (await focus.week(week) != null) return;
    final chosen = FocusSettings.fromJson(
      await settings.read(SettingKeys.focus),
    );
    await focus.openWeek(
      week,
      fromDay: fromDay,
      terms: FocusTerms.of(
        rules: rules.focus,
        priceLevelPercent: await prices.percentFor(week),
        dailyMinutes: chosen.dailyMinutes,
        goalMinutes: chosen.goalMinutes,
      ),
    );
  }

  Future<void> _settle(
    FocusWeekRow row, {
    required bool fine,
    required DateTime now,
  }) async {
    final end = row.weekStart.addDays(6);
    final ledger = computeFocusLedger(
      week: row.weekStart,
      fromDay: row.fromDay,
      today: end,
      terms: row.terms,
      secondsByDay: await focus.secondsByDay(row.weekStart, end),
      restDays: await economy.bookedDays(),
    );
    await db.transaction(() async {
      // Another pass closed it meanwhile, or a restored backup has no such
      // week any more.
      final current = await focus.week(row.weekStart);
      if (current == null || current.settledAt != null) return;
      // The ledger has the last word on each day's gold, in case the timer
      // never got to write it (the app was killed mid-session).
      for (final day in ledger.days) {
        await economy.setEvent(
          amount: day.gold,
          source: kFocusGoldSource,
          ref: day.day.toKey(),
          at: now,
        );
      }
      var penalty = 0;
      if (fine) {
        final due = focusPenalty(
          debtSeconds: ledger.debtSeconds,
          terms: row.terms,
          rules: rules.focus,
          balance: await economy.balance(),
        );
        if (due > 0 &&
            await economy.spend(
                  amount: due,
                  source: kFocusPenaltySource,
                  ref: row.weekStart.toKey(),
                  at: now,
                ) ==
                SpendResult.spent) {
          penalty = due;
        }
      }
      await focus.settle(
        row.weekStart,
        at: now,
        unpaidSeconds: ledger.debtSeconds,
        penalty: penalty,
      );
    });
  }
}

final townServiceProvider = Provider<TownService>(
  (ref) => TownService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    db: ref.watch(databaseProvider),
    adventurers: ref.watch(adventurerRepoProvider),
    focus: ref.watch(focusRepoProvider),
    economy: ref.watch(economyRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    prices: ref.watch(priceServiceProvider),
    bank: ref.watch(bankServiceProvider),
    casino: ref.watch(casinoServiceProvider),
  ),
);

/// Changes whenever the town may have a week to turn over: a new day, and
/// the adventurer signing up.
final townRolloverTriggerProvider = Provider<(LogicalDay, bool)>(
  (ref) => (
    ref.watch(todayProvider),
    ref.watch(adventurerProvider.select((hero) => hero.value != null)),
  ),
);
