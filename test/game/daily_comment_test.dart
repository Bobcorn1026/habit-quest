import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/game/daily_comment.dart';

void main() {
  DayRecap recap({
    LogicalDay day = const LogicalDay(2026, 11, 9),
    bool perfect = true,
    int partial = 0,
    int cracks = 0,
    int streak = 3,
    (int, int)? trial,
  }) => (
    day: day,
    perfect: perfect,
    done: 2,
    partial: partial,
    cracks: cracks,
    bestStreak: streak,
    bestQuest: '破譯古代卷軸',
    trial: trial,
  );

  test('the running trial comes first', () {
    expect(dailyComment(recap(trial: (2, 5))), contains('還剩 3 天'));
  });

  test('a crack gets comfort, a streak milestone gets noticed', () {
    expect(dailyComment(recap(cracks: 1)), contains('裂痕'));
    expect(dailyComment(recap(streak: 30)), contains('連續 30 天'));
  });

  test('partial days and perfect days have their own lines', () {
    final mixed = dailyComment(recap(perfect: false, partial: 1));
    final perfect = dailyComment(recap());
    expect(mixed, isNot(perfect));
    expect(dailyComment(recap()), dailyComment(recap()), reason: 'stable');
  });
}
