import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/habit.dart';
import '../domain/quest.dart';
import 'game_rules.dart';
import 'habit_stats.dart';
import 'streak.dart';

/// Whether a quest has been outgrown and should be invited to its next tier.
/// There is no penalty either way: staying on a quest is always fine.
@immutable
class PromotionVerdict {
  const PromotionVerdict({this.surpassed = false, this.sealMastered = false});

  /// Consistently far above the target.
  final bool surpassed;

  /// A seal held long enough to tighten or retire.
  final bool sealMastered;

  bool get offersUpgrade => surpassed || sealMastered;
}

/// Judges [quest] from [weeks]: finished calendar weeks that lie entirely
/// within the quest's current tier, oldest first.
PromotionVerdict assessPromotion({
  required Habit habit,
  required Quest quest,
  required List<HabitPeriodStats> weeks,
  required StreakState streak,
  required PromotionRules rules,
}) {
  if (habit.kind == HabitKind.quit) {
    return PromotionVerdict(
      sealMastered: streak.cleanDays >= rules.sealMasteryDays,
    );
  }

  final target = quest.target;
  if (target == null || target <= 0) return const PromotionVerdict();
  bool isSurpassing(HabitPeriodStats w) =>
      w.completion >= rules.surpassCompletionRate &&
      (w.averageAmount ?? 0) >= target * rules.surpassAmountRatio;

  var run = 0;
  for (final w in weeks.reversed) {
    if (!isSurpassing(w)) break;
    run++;
  }
  return PromotionVerdict(surpassed: run >= rules.surpassWeeks);
}

/// A harder target for an upgraded quest. Whole-number targets stay whole
/// and always grow by at least one.
double suggestedUpgradeTarget(double target, PromotionRules rules) {
  final raw = (target * rules.upgradeFactor).clamp(
    target * rules.upgradeMinFactor,
    target * rules.upgradeMaxFactor,
  );
  if (target == target.roundToDouble()) {
    return math.max(raw.ceilToDouble(), target + 1);
  }
  return double.parse(raw.toStringAsFixed(1));
}
