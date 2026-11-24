import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import 'price_level.dart';

/// Numbers of the training ground (the focus timer).
@immutable
class FocusRules {
  const FocusRules({
    this.dailyMinutes = 50,
    this.weeklyGoalMinutes = 600,
    this.baseGoldPerHour = 20,
    this.penaltyPercent = 30,
    this.awayGraceSeconds = 30,
    this.breakMinutes = 10,
    this.saveEverySeconds = 10,
    this.powerSaveBrightness = 0.05,
  });

  /// Every day that is not a rest day starts this far below zero.
  final int dailyMinutes;

  /// Focus a week that can count; the player may change it for later weeks.
  final int weeklyGoalMinutes;

  /// Gold for an hour above zero at guild rank F; see [PriceRules].
  final int baseGoldPerHour;

  /// Debt left when the week closes is fined at this share of what the same
  /// time would have earned.
  final int penaltyPercent;

  /// Leaving the app for up to this long keeps a session running.
  final int awayGraceSeconds;

  /// The break that follows a session.
  final int breakMinutes;

  /// A running session is saved this often: at most this much is lost if
  /// the app is killed without going to the background first.
  final int saveEverySeconds;

  /// Screen brightness (0–1) of the power-saving view.
  final double powerSaveBrightness;
}

/// What one week of focus runs on, fixed when the week starts so that a
/// changed setting or a promotion only matters from the next week on.
@immutable
class FocusTerms {
  const FocusTerms({
    required this.dailyMinutes,
    required this.capMinutes,
    required this.earnCapMinutes,
    required this.goldPerHour,
  });

  /// The week's terms from the rules, the price level of the week, and
  /// whatever the player changed.
  factory FocusTerms.of({
    required FocusRules rules,
    required int priceLevelPercent,
    int? dailyMinutes,
    int? goalMinutes,
  }) {
    final daily = dailyMinutes ?? rules.dailyMinutes;
    final goal = goalMinutes ?? rules.weeklyGoalMinutes;
    return FocusTerms(
      dailyMinutes: daily,
      capMinutes: goal,
      // What is left of the goal after a week of daily debt: someone who
      // clears every day earns exactly this, and nobody earns more by
      // cramming the hours into one day.
      earnCapMinutes: math.max(0, goal - 7 * daily),
      goldPerHour: inflate(rules.baseGoldPerHour, priceLevelPercent),
    );
  }

  final int dailyMinutes;

  /// The weekly goal: focus past it earns nothing.
  final int capMinutes;

  /// Minutes above zero that can earn gold in one week.
  final int earnCapMinutes;
  final int goldPerHour;

  /// Gold of a week that reaches the earn cap.
  int get maxGold => earnCapMinutes * goldPerHour ~/ 60;
}

/// One day of the week's ledger.
@immutable
class FocusDay {
  const FocusDay({
    required this.day,
    required this.startSeconds,
    required this.focusedSeconds,
    required this.earnedSeconds,
    required this.gold,
  });

  final LogicalDay day;

  /// Where the timer stood before any focus: the day's debt plus what was
  /// left from earlier days, less anything prepaid. Never above zero.
  final int startSeconds;
  final int focusedSeconds;

  /// The part of [focusedSeconds] that counted toward gold.
  final int earnedSeconds;
  final int gold;

  /// What the timer shows now (or showed when the day closed).
  int get endSeconds => startSeconds + focusedSeconds;
}

/// A week of focus up to some day: what each day started at and earned.
@immutable
class FocusLedger {
  const FocusLedger({
    required this.days,
    required this.focusedSeconds,
    required this.earnedSeconds,
    required this.gold,
    required this.debtSeconds,
    required this.prepaidSeconds,
  });

  /// Oldest first; ends with the last day counted.
  final List<FocusDay> days;
  final int focusedSeconds;
  final int earnedSeconds;
  final int gold;

  /// Still owed after the last day counted. When that is the last day of the
  /// week, this is what gets fined.
  final int debtSeconds;

  /// Focus past the earn cap that has not yet paid for a later day.
  final int prepaidSeconds;
}

/// The focus ledger of the week that starts on [week], through [today] or
/// the end of the week, whichever is first.
///
/// Every day that is not in [restDays] opens [FocusTerms.dailyMinutes] below
/// zero, plus what earlier days left unpaid. Focus first pays that off; above
/// zero it earns gold, until the week has earned [FocusTerms.earnCapMinutes]
/// or reached [FocusTerms.capMinutes] in all. Focus beyond that earns nothing
/// but is kept as prepayment: it pays the debt of the days that follow, so a
/// whole week done in one sitting ends up like the same hours spread out.
/// Time above zero that did earn gold is never carried to the next day.
///
/// No debt is counted before [fromDay], the day focus was switched on.
FocusLedger computeFocusLedger({
  required LogicalDay week,
  required LogicalDay fromDay,
  required LogicalDay today,
  required FocusTerms terms,
  required Map<LogicalDay, int> secondsByDay,
  Set<LogicalDay> restDays = const {},
}) {
  final capSeconds = terms.capMinutes * 60;
  final earnCapSeconds = terms.earnCapMinutes * 60;
  int goldFor(int earned) => earned * terms.goldPerHour ~/ 3600;

  final weekEnd = week.addDays(6);
  final last = today.isAfter(weekEnd) ? weekEnd : today;
  final days = <FocusDay>[];
  var debt = 0;
  var prepaid = 0;
  var earned = 0;
  var focusedSoFar = 0;
  for (
    var day = fromDay.isAfter(week) ? fromDay : week;
    !day.isAfter(last);
    day = day.addDays(1)
  ) {
    var owed = debt + (restDays.contains(day) ? 0 : terms.dailyMinutes * 60);
    final covered = math.min(prepaid, owed);
    prepaid -= covered;
    owed -= covered;

    final focused = math.max(0, secondsByDay[day] ?? 0);
    final paid = math.min(focused, owed);
    final above = focused - paid;
    final room = math.min(
      earnCapSeconds - earned,
      capSeconds - (focusedSoFar + paid),
    );
    final gain = math.max(0, math.min(above, room));
    final goldBefore = goldFor(earned);
    earned += gain;
    prepaid += above - gain;
    debt = owed - paid;
    focusedSoFar += focused;
    days.add(
      FocusDay(
        day: day,
        startSeconds: -owed,
        focusedSeconds: focused,
        earnedSeconds: gain,
        // The difference of running totals, so the days add up to the week
        // without losing a coin to rounding.
        gold: goldFor(earned) - goldBefore,
      ),
    );
  }
  return FocusLedger(
    days: days,
    focusedSeconds: focusedSoFar,
    earnedSeconds: earned,
    gold: goldFor(earned),
    debtSeconds: debt,
    prepaidSeconds: prepaid,
  );
}

/// Gold taken when a week closes with [debtSeconds] unpaid: a share of what
/// that time would have earned, and never more than the player has.
int focusPenalty({
  required int debtSeconds,
  required FocusTerms terms,
  required FocusRules rules,
  required int balance,
}) {
  final due =
      debtSeconds * terms.goldPerHour * rules.penaltyPercent ~/ (3600 * 100);
  return math.max(0, math.min(due, balance));
}

/// Focused seconds of a session from [startedAt] to [end], without the
/// [awaySeconds] the player spent outside the app. Never negative, whatever
/// the clock did in between.
int sessionSeconds({
  required DateTime startedAt,
  required DateTime end,
  int awaySeconds = 0,
}) => math.max(0, end.difference(startedAt).inSeconds - awaySeconds);
