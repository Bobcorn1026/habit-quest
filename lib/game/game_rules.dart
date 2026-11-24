import 'package:flutter/foundation.dart';

import '../domain/quest_rank.dart';
import 'bank_rules.dart';
import 'casino_rules.dart';
import 'focus.dart';
import 'price_level.dart';
import 'progression.dart';

/// Every tunable number of the game in one place. Screens and the engine read
/// from here; nothing should hard-code these values.
@immutable
class GameRules {
  const GameRules({
    this.dayStartHour = 4,
    this.weekStartsOn = DateTime.monday,
    this.rankBaseXp = const {
      QuestRank.f: 5,
      QuestRank.e: 8,
      QuestRank.d: 12,
      QuestRank.c: 18,
      QuestRank.b: 25,
      QuestRank.a: 35,
      QuestRank.s: 50,
      QuestRank.ss: 70,
      QuestRank.sss: 100,
    },
    this.amountFactorCap = 1.5,
    this.streakBonusPerDay = 0.02,
    this.streakBonusCap = 0.30,
    this.qualityBonusCap = 0.20,
    this.levelCurveBase = 60,
    this.levelCurveExponent = 1.7,
    this.judgement = const JudgementRules(),
    this.promotion = const PromotionRules(),
    this.progression = const ProgressionRules(),
    this.prices = const PriceRules(),
    this.focus = const FocusRules(),
    this.bank = const BankRules(),
    this.casino = const CasinoRules(),
  });

  /// A logical day starts at this local hour (night owls keep "today").
  final int dayStartHour;

  /// `DateTime.monday` … `DateTime.sunday`.
  final int weekStartsOn;

  final Map<QuestRank, int> rankBaseXp;

  /// Doing more than the target pays more, up to this multiple.
  final double amountFactorCap;

  /// Streak bonus per consecutive day (weekly-quota habits earn 7× per week).
  final double streakBonusPerDay;
  final double streakBonusCap;

  /// Ceiling for the AI's weekly quality bonus, as a fraction of the week's
  /// XP. Applied client-side so pasted text can't inflate rewards.
  final double qualityBonusCap;

  /// Total XP to reach level L is `base × (L − 1)^exponent`.
  final double levelCurveBase;
  final double levelCurveExponent;

  final JudgementRules judgement;
  final PromotionRules promotion;
  final ProgressionRules progression;
  final PriceRules prices;
  final FocusRules focus;
  final BankRules bank;
  final CasinoRules casino;

  int baseXp(QuestRank rank) => rankBaseXp[rank] ?? 10;
}

/// Score thresholds for the weekly TRPG-style judgement.
@immutable
class JudgementRules {
  const JudgementRules({
    this.triumph = 0.9,
    this.success = 0.7,
    this.struggle = 0.4,
  });

  final double triumph;
  final double success;
  final double struggle;
}

/// When a quest is invited to its next tier.
@immutable
class PromotionRules {
  const PromotionRules({
    this.upgradeFactor = 1.25,
    this.upgradeMinFactor = 1.1,
    this.upgradeMaxFactor = 2.0,
    this.surpassCompletionRate = 0.9,
    this.surpassAmountRatio = 1.5,
    this.surpassWeeks = 3,
    this.sealMasteryDays = 30,
  });

  /// Suggested new target = old × factor, clamped to [min, max] × old.
  final double upgradeFactor;
  final double upgradeMinFactor;
  final double upgradeMaxFactor;

  /// Beating the target by [surpassAmountRatio] in weeks completed at least
  /// this well, [surpassWeeks] weeks running, invites an upgrade.
  final double surpassCompletionRate;
  final double surpassAmountRatio;
  final int surpassWeeks;

  /// Days of unbroken seal before offering to tighten or retire it.
  final int sealMasteryDays;
}
