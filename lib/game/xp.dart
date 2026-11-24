import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/check_in.dart';
import '../domain/quest_rank.dart';
import 'game_rules.dart';

/// XP for one check-in.
///
/// `base(rank) × amount factor × streak bonus × multiplier` (class bonus), where
/// [streakDays] is the run length including this check-in.
int checkInXp({
  required GameRules rules,
  required QuestRank rank,
  required CheckInOutcome outcome,
  double? amount,
  double? target,
  int streakDays = 0,
  double multiplier = 1,
}) {
  if (outcome == CheckInOutcome.relapsed) return 0;

  var amountFactor = 1.0;
  if (outcome == CheckInOutcome.done || outcome == CheckInOutcome.partial) {
    if (target != null && target > 0 && amount != null) {
      amountFactor = (amount / target).clamp(0, rules.amountFactorCap);
    } else if (outcome == CheckInOutcome.partial) {
      amountFactor = 0.5;
    }
  }
  if (amountFactor <= 0) return 0;

  final streakBonus = math.min(
    rules.streakBonusCap,
    rules.streakBonusPerDay * math.max(0, streakDays - 1),
  );
  final xp = rules.baseXp(rank) * amountFactor * (1 + streakBonus) * multiplier;
  return math.max(1, xp.round());
}

/// The AI's weekly quality bonus, clamped by [GameRules.qualityBonusCap].
int qualityBonusXp({
  required GameRules rules,
  required int weekXp,
  required double requestedFraction,
}) {
  final f = requestedFraction.isNaN
      ? 0.0
      : requestedFraction.clamp(0, rules.qualityBonusCap);
  return (weekXp * f).round();
}

/// Total XP needed to reach [level] (level 1 needs 0).
int totalXpForLevel(int level, GameRules rules) => level <= 1
    ? 0
    : (rules.levelCurveBase * math.pow(level - 1, rules.levelCurveExponent))
          .round();

@immutable
class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.totalXp,
    required this.levelStartXp,
    required this.nextLevelXp,
  });

  factory LevelInfo.fromTotal(int totalXp, GameRules rules) {
    var level = 1;
    while (totalXpForLevel(level + 1, rules) <= totalXp) {
      level++;
    }
    return LevelInfo(
      level: level,
      totalXp: totalXp,
      levelStartXp: totalXpForLevel(level, rules),
      nextLevelXp: totalXpForLevel(level + 1, rules),
    );
  }

  final int level;
  final int totalXp;
  final int levelStartXp;
  final int nextLevelXp;

  int get xpIntoLevel => totalXp - levelStartXp;
  int get xpForLevel => nextLevelXp - levelStartXp;
  double get progress => xpForLevel == 0 ? 0 : xpIntoLevel / xpForLevel;
}
