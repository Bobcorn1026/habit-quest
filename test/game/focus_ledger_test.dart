import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/focus.dart';
import 'package:habit_quest/game/price_level.dart';

void main() {
  const rules = FocusRules();
  const prices = PriceRules();
  const monday = LogicalDay(2026, 11, 9);
  FocusTerms termsAt(QuestRank rank) =>
      FocusTerms.of(rules: rules, priceLevelPercent: prices.percentOf(rank));
  final terms = termsAt(QuestRank.f);
  int min(int minutes) => minutes * 60;

  /// The week's ledger from minutes of focus by weekday (0 = Monday).
  FocusLedger ledger(
    Map<int, int> minutes, {
    int today = 6,
    int from = 0,
    Set<int> rest = const {},
    FocusTerms? on,
  }) => computeFocusLedger(
    week: monday,
    fromDay: monday.addDays(from),
    today: monday.addDays(today),
    terms: on ?? terms,
    secondsByDay: {
      for (final e in minutes.entries) monday.addDays(e.key): min(e.value),
    },
    restDays: {for (final d in rest) monday.addDays(d)},
  );
  int fine(FocusLedger l, {FocusTerms? on, int balance = 9999}) => focusPenalty(
    debtSeconds: l.debtSeconds,
    terms: on ?? terms,
    rules: rules,
    balance: balance,
  );

  test('the terms of a week follow its price level', () {
    expect(
      (terms.dailyMinutes, terms.capMinutes, terms.earnCapMinutes),
      (50, 600, 250),
    );
    expect(
      [for (final rank in QuestRank.values) termsAt(rank).goldPerHour],
      [20, 24, 30, 36, 44, 52, 60, 70, 80],
    );
    expect(terms.maxGold, 83);
    expect(termsAt(QuestRank.sss).maxGold, 333);
  });

  test('ten hours spread over the week earn the full week', () {
    final l = ledger({for (var d = 0; d < 7; d++) d: 86});
    expect(l.days.map((d) => d.startSeconds), everyElement(-min(50)));
    expect(l.days.first.endSeconds, min(36));
    expect(l.days.map((d) => d.gold), [12, 12, 12, 12, 12, 12, 11]);
    expect((l.earnedSeconds, l.gold), (min(250), 83));
    expect((l.debtSeconds, fine(l)), (0, 0));
  });

  test('ten hours on Monday earn the same and prepay the rest', () {
    final l = ledger({0: 600});
    expect(l.days.first.endSeconds, min(550));
    expect(l.days.first.gold, 83);
    // Tuesday to Sunday open at zero instead of fifty minutes down.
    expect(l.days.skip(1).map((d) => d.startSeconds), everyElement(0));
    expect((l.gold, l.debtSeconds, l.prepaidSeconds), (83, 0, 0));
    expect(fine(l), 0);

    // Halfway through the week some of the prepayment is still unused.
    expect(ledger({0: 600}, today: 2).prepaidSeconds, min(200));
  });

  test('ten hours on Sunday earn the same after a week of debt', () {
    final l = ledger({6: 600});
    expect(l.days.last.startSeconds, -min(350));
    expect((l.gold, l.debtSeconds, l.prepaidSeconds), (83, 0, 0));
  });

  test('time above zero that earned gold is not carried over', () {
    // Half the hours up front: the full gold at once, then six days of debt.
    final l = ledger({0: 300});
    expect((l.gold, l.prepaidSeconds), (83, 0));
    expect(l.days[1].startSeconds, -min(50));
    expect(l.debtSeconds, min(300));
    expect(fine(l), 30);
  });

  test('unpaid debt piles up day after day', () {
    final l = ledger({1: 120}, today: 2);
    expect(l.days.map((d) => d.startSeconds), [
      -min(50),
      -min(100),
      -min(50), //
    ]);
    expect(l.days.map((d) => d.gold), [0, 6, 0]);
    expect((l.earnedSeconds, l.debtSeconds), (min(20), min(50)));
  });

  test('prepayment also covers debt from before it', () {
    final l = ledger({1: 600});
    expect(l.days[1].startSeconds, -min(100));
    expect((l.gold, l.debtSeconds, l.prepaidSeconds), (83, 0, 0));
  });

  test('a rest day adds no debt but keeps the old one', () {
    final l = ledger({}, today: 2, rest: {1});
    expect(l.days.map((d) => d.startSeconds), [
      -min(50),
      -min(50),
      -min(100), //
    ]);

    // Resting does not use up prepayment either.
    final ahead = ledger({0: 350}, today: 2, rest: {1});
    expect(ahead.days.map((d) => d.startSeconds), [-min(50), 0, 0]);
    expect(ahead.prepaidSeconds, 0);
  });

  test('nothing is owed for the days before focus was switched on', () {
    final l = ledger({}, from: 2);
    expect(l.days.first.day, monday.addDays(2));
    expect(l.days, hasLength(5));
    expect(l.debtSeconds, min(250));
  });

  test('a week that is over is counted to its last day only', () {
    final l = ledger({0: 50}, today: 9);
    expect(l.days, hasLength(7));
    expect(l.days.last.day, monday.addDays(6));
    expect(l.debtSeconds, min(300));
  });

  test('past the weekly goal nothing is earned, whatever the cap', () {
    const short = FocusTerms(
      dailyMinutes: 50,
      capMinutes: 100,
      earnCapMinutes: 80,
      goldPerHour: 60,
    );
    final l = ledger({0: 200}, today: 0, on: short);
    expect((l.earnedSeconds, l.gold), (min(50), 50));
    expect(l.prepaidSeconds, min(100));

    // A goal below a week of debt leaves nothing to earn.
    final tiny = FocusTerms.of(
      rules: rules,
      priceLevelPercent: 100,
      goalMinutes: 300,
    );
    expect((tiny.earnCapMinutes, tiny.maxGold), (0, 0));
    expect(ledger({0: 120}, today: 0, on: tiny).gold, 0);
  });

  test('the fine grows with the rank and stops at an empty purse', () {
    final l = ledger({});
    expect(l.debtSeconds, min(350));
    expect(fine(l), 35);
    expect(fine(l, on: termsAt(QuestRank.sss)), 140);
    expect(fine(l, balance: 12), 12);
    expect(fine(l, balance: 0), 0);
    expect(fine(ledger({0: 20}, today: 0)), 3, reason: '30 minutes owed');
  });

  test('a session counts its time minus the time away', () {
    final start = DateTime(2026, 11, 9, 10);
    DateTime after(int seconds) => start.add(Duration(seconds: seconds));
    expect(sessionSeconds(startedAt: start, end: after(600)), 600);
    expect(
      sessionSeconds(startedAt: start, end: after(600), awaySeconds: 25),
      575,
    );
    // The clock was set back in the middle.
    expect(sessionSeconds(startedAt: start, end: after(-90)), 0);
  });
}
