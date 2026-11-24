import 'dart:convert';

import '../core/logical_day.dart';
import '../data/casino_repository.dart';
import '../data/database.dart';
import '../domain/casino.dart';
import '../game/game_rules.dart';
import '../game/period.dart';

/// Format tag of the tuning log.
const kTuningLogFormat = 'habit_quest.tuning';

/// A day's gold events and check-in gold, as the log adds them up.
typedef GoldLine = ({LogicalDay day, String source, int amount});

/// The town's numbers week by week, for Claude to judge whether prices
/// and prizes need tuning: what everything-done would have paid (G*) next
/// to the gold really earned, focus, the casino's price, draws and wins.
/// Only totals: no notes, names or money moves of the bank.
Map<String, Object?> buildTuningLog({
  required DateTime now,
  required GameRules rules,
  required List<CasinoWeekRow> casinoWeeks,
  required List<CasinoTicketRow> tickets,
  required List<FocusWeekRow> focusWeeks,
  required Map<LogicalDay, int> focusSecondsByDay,
  required List<GoldLine> gold,
}) {
  final calendar = PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn);
  LogicalDay weekOf(LogicalDay d) => calendar.periodOf(d).start;
  final casino = {for (final w in casinoWeeks) w.weekStart: w};
  final focus = {for (final w in focusWeeks) w.weekStart: w};
  final starts = {...casino.keys, ...focus.keys}.toList()..sort();

  final earned = <LogicalDay, Map<String, int>>{};
  final spent = <LogicalDay, Map<String, int>>{};
  for (final g in gold) {
    if (g.amount == 0) continue;
    final into = g.amount > 0 ? earned : spent;
    final byKind = into.putIfAbsent(weekOf(g.day), () => {});
    byKind[g.source] = (byKind[g.source] ?? 0) + g.amount.abs();
  }
  final focusSeconds = <LogicalDay, int>{};
  for (final MapEntry(:key, :value) in focusSecondsByDay.entries) {
    final w = weekOf(key);
    focusSeconds[w] = (focusSeconds[w] ?? 0) + value;
  }
  final byWeek = <LogicalDay, List<CasinoTicketRow>>{};
  for (final t in tickets) {
    byWeek.putIfAbsent(t.weekStart, () => []).add(t);
  }

  Map<String, Object?> casinoOf(CasinoWeekRow w) {
    final deck = byWeek[w.weekStart] ?? const [];
    final prizes = [
      for (final t in deck)
        if (t.kind == TicketKind.prize) t,
    ];
    final drawn = [
      for (final t in prizes)
        if (t.drawnAt != null) t,
    ];
    final terms = w.terms;
    return {
      'from': w.fromDay.toKey(),
      'days': terms.days,
      'quests': terms.questCount,
      'planPercent': terms.plan[w.weekStart.toKey()],
      'poolBefore': w.poolBefore,
      'released': w.released,
      'targetGold': w.targetGold,
      'focusGold': terms.focusGold,
      'price': w.price,
      'prizeTickets': prizes.length,
      'drawn': drawn.length,
      'refundsDrawn': deck
          .where((t) => t.kind == TicketKind.refund && t.drawnAt != null)
          .length,
      'goldPaid': drawn.fold<int>(0, (a, t) => a + (t.paid ?? 0)),
      'won': drawn.fold<int>(0, (a, t) => a + t.amount),
      'topWon': drawn.any((t) => t.tier == PrizeTier.top),
      'swept': w.swept,
      'settled': w.settledAt != null,
      'goldAtOpen': terms.goldAtOpen,
    };
  }

  return {
    'format': kTuningLogFormat,
    'version': 1,
    'exportedAt': now.toIso8601String(),
    'note':
        'gold 依來源加總：checkIn 委託、perfect 完美的一天、focus 專注、'
        'casino 賭場、focus_penalty 專注罰金、shop/inn 商店與旅店，'
        '其他是 gold_events 的 source。casino.targetGold 是全部達標的週金幣 G*，'
        '價格讓 G* 約買得起 95% 的獎籤。',
    'rules': {
      'releasePercent': [
        rules.casino.releaseMinPercent,
        rules.casino.releaseMaxPercent,
      ],
      'tickets': [rules.casino.minTickets, rules.casino.maxTickets],
      'refundTickets': rules.casino.refundTickets,
      'targetPercent': rules.casino.targetPercent,
      'sweepPercent': rules.casino.sweepPercent,
      'focusDailyMinutes': rules.focus.dailyMinutes,
      'focusGoldPerHour': rules.focus.baseGoldPerHour,
    },
    'weeks': [
      for (final start in starts)
        {
          'week': start.toKey(),
          'priceLevel': casino[start]?.priceLevel,
          'gold': {'earned': earned[start] ?? {}, 'spent': spent[start] ?? {}},
          'focus': {
            'minutes': (focusSeconds[start] ?? 0) ~/ 60,
            if (focus[start] case final f?) ...{
              'goalMinutes': f.capMinutes,
              'earnCapMinutes': f.earnCapMinutes,
              'unpaidMinutes': f.unpaidSeconds == null
                  ? null
                  : (f.unpaidSeconds! + 59) ~/ 60,
              'penalty': f.penalty,
            },
          },
          if (casino[start] case final c?) 'casino': casinoOf(c),
        },
    ],
  };
}

/// Reads what [buildTuningLog] needs from [db] and returns it as JSON.
Future<String> exportTuningLog(
  AppDatabase db, {
  required GameRules rules,
  required DateTime now,
}) async {
  final checkIns = await db.select(db.checkIns).get();
  final events = await db.select(db.goldEvents).get();
  final purchases = await db.select(db.purchases).get();
  LogicalDay dayOf(DateTime at) =>
      LogicalDay.of(at, dayStartHour: rules.dayStartHour);
  LogicalDay eventDay(GoldEventRow e) {
    final ref = e.ref;
    if (ref != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(ref)) {
      return LogicalDay.parse(ref);
    }
    return dayOf(e.at);
  }

  final sessions = await db.select(db.focusSessions).get();
  final seconds = <LogicalDay, int>{};
  for (final s in sessions) {
    seconds[s.day] = (seconds[s.day] ?? 0) + s.seconds;
  }
  return const JsonEncoder.withIndent('  ').convert(
    buildTuningLog(
      now: now,
      rules: rules,
      casinoWeeks: await CasinoRepository(db).weeks(),
      tickets: await db.select(db.casinoTickets).get(),
      focusWeeks: await db.select(db.focusWeeks).get(),
      focusSecondsByDay: seconds,
      gold: [
        for (final c in checkIns)
          if (c.gold != 0) (day: c.day, source: 'checkIn', amount: c.gold),
        for (final e in events)
          (day: eventDay(e), source: e.source, amount: e.amount),
        for (final p in purchases)
          if (p.price > 0)
            (
              day: dayOf(p.at),
              source: p.itemId.startsWith('inn:') ? 'inn' : 'shop',
              amount: -p.price,
            ),
      ],
    ),
  );
}
