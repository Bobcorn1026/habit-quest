import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../domain/stat.dart';

enum CheckResult {
  criticalSuccess('大成功'),
  success('成功'),
  failure('失敗'),
  criticalFailure('大失敗');

  const CheckResult(this.label);
  final String label;

  bool get passed => this == criticalSuccess || this == success;
}

/// A TRPG-style stat check shown in a chapter. It looks like a d20 roll,
/// but the result was decided by how well the period's quests of that stat
/// went; the dice are only picked to agree with it.
@immutable
class StoryCheck {
  const StoryCheck({
    required this.stat,
    required this.dc,
    required this.roll,
    required this.modifier,
    required this.result,
  });

  factory StoryCheck.fromJson(Map<String, Object?> json) => StoryCheck(
    stat: Stat.parse(json['stat']) ?? Stat.luk,
    dc: (json['dc'] as num?)?.toInt() ?? 12,
    roll: (json['roll'] as num?)?.toInt() ?? 10,
    modifier: (json['modifier'] as num?)?.toInt() ?? 0,
    result:
        CheckResult.values.where((r) => r.name == json['result']).firstOrNull ??
        CheckResult.success,
  );

  final Stat stat;
  final int dc;

  /// The d20 face, 1–20.
  final int roll;
  final int modifier;
  final CheckResult result;

  int get total => roll + modifier;

  /// e.g. 「智力檢定 DC 12：擲出 15＋3＝18，成功」
  String get line {
    final sign = modifier >= 0 ? '＋' : '－';
    return '${stat.label}檢定 DC $dc：擲出 $roll$sign${modifier.abs()}＝$total，'
        '${result.label}';
  }

  Map<String, Object?> toJson() => {
    'stat': stat.code,
    'dc': dc,
    'roll': roll,
    'modifier': modifier,
    'result': result.name,
  };
}

/// The stat modifier on a d20: +1 per 5 points.
int checkModifier(int statValue) => statValue ~/ 5;

/// How a period's completion decides a check.
CheckResult resultFor(double completion) => completion >= 0.95
    ? CheckResult.criticalSuccess
    : completion >= 0.6
    ? CheckResult.success
    : completion >= 0.25
    ? CheckResult.failure
    : CheckResult.criticalFailure;

/// Rolls one check per stat in [completion] (most practised first, at most
/// [max]). The same inputs always give the same dice.
List<StoryCheck> rollChecks({
  required List<(Stat, double)> completion,
  required Map<Stat, int> statValues,
  required int seed,
  int dc = 12,
  int max = 3,
}) {
  final out = <StoryCheck>[];
  for (final (i, (stat, rate)) in completion.take(max).indexed) {
    final random = math.Random(seed * 31 + i * 7 + stat.index);
    final mod = checkModifier(statValues[stat] ?? 0);
    var result = resultFor(rate);
    // Lowest and highest faces that still give the decided result.
    final passFrom = (dc - mod).clamp(2, 20);
    int pick(int lo, int hi) =>
        lo >= hi ? lo : lo + random.nextInt(hi - lo + 1);
    final roll = switch (result) {
      CheckResult.criticalSuccess => 20,
      CheckResult.criticalFailure => 1,
      CheckResult.success => pick(passFrom, 19),
      CheckResult.failure when passFrom > 2 => pick(2, passFrom - 1),
      // So strong that only a natural 1 could fail.
      CheckResult.failure => 1,
    };
    if (roll == 1) result = CheckResult.criticalFailure;
    out.add(
      StoryCheck(stat: stat, dc: dc, roll: roll, modifier: mod, result: result),
    );
  }
  return out;
}
