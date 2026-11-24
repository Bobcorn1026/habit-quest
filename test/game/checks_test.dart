import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/checks.dart';

void main() {
  List<StoryCheck> roll(double rate, {int stat = 15, int seed = 1}) =>
      rollChecks(
        completion: [(Stat.intel, rate)],
        statValues: {Stat.intel: stat},
        seed: seed,
      );

  test('completion decides the result; the dice agree with it', () {
    for (var seed = 0; seed < 50; seed++) {
      final ok = roll(0.7, seed: seed).single;
      expect(ok.result, CheckResult.success);
      expect(ok.total, greaterThanOrEqualTo(ok.dc));
      expect(ok.roll, inInclusiveRange(2, 19));

      final bad = roll(0.4, seed: seed).single;
      expect(bad.result, CheckResult.failure);
      expect(bad.total, lessThan(bad.dc));
      expect(bad.roll, inInclusiveRange(2, 19));
    }
    expect(roll(1).single.roll, 20);
    expect(roll(0.1).single.roll, 1);
  });

  test('a stat too strong to fail normally fails on a natural 1', () {
    final c = roll(0.4, stat: 60).single;
    expect(c.roll, 1);
    expect(c.result, CheckResult.criticalFailure);
  });

  test('the same seed rolls the same dice', () {
    expect(roll(0.7, seed: 9).single.roll, roll(0.7, seed: 9).single.roll);
  });

  test('round-trips through JSON and reads as a line', () {
    final c = roll(0.7).single;
    final back = StoryCheck.fromJson(c.toJson());
    expect(back.roll, c.roll);
    expect(back.result, c.result);
    expect(c.line, startsWith('智力檢定 DC 12：擲出'));
  });
}
