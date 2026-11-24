import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/focus_settings.dart';
import 'package:habit_quest/ui/screens/focus/focus_format.dart';

void main() {
  test('the timer reads like a stopwatch, below zero with a minus', () {
    expect(formatFocusClock(-50 * 60), '-50:00');
    expect(formatFocusClock(-59), '-00:59');
    expect(formatFocusClock(0), '00:00');
    expect(formatFocusClock(754), '12:34');
    expect(formatFocusClock(3900), '1:05:00');
    expect(formatFocusClock(-3601), '-1:00:01');
  });

  test('spans and debt in minutes', () {
    expect(formatFocusSpan(0), '0 分鐘');
    expect(formatFocusSpan(45 * 60 + 59), '45 分鐘');
    expect(formatFocusSpan(600 * 60), '10 小時');
    expect(formatFocusSpan(200 * 60), '3 小時 20 分');
    expect(owedMinutes(-3000), 50);
    expect(owedMinutes(-1), 1, reason: 'the last seconds still show');
    expect(owedMinutes(30), 0);
  });

  test('price levels drop trailing zeros', () {
    expect(formatPriceLevel(100), '×1');
    expect(formatPriceLevel(150), '×1.5');
    expect(formatPriceLevel(220), '×2.2');
    expect(formatPriceLevel(400), '×4');
    expect(formatPriceLevel(105), '×1.05');
  });

  test('screen switches survive a round trip and default off', () {
    expect(FocusSettings.fromJson(null).showClock, isFalse);
    expect(FocusSettings.fromJson(null).hideTimer, isFalse);
    const chosen = FocusSettings(breakMinutes: 15, showClock: true);
    final back = FocusSettings.fromJson(
      chosen.copyWith(hideTimer: true).toJson(),
    );
    expect(back.breakMinutes, 15);
    expect(back.showClock, isTrue);
    expect(back.hideTimer, isTrue);
    expect(back.sound, isTrue);
    expect(const FocusSettings().toJson(), isEmpty);
  });
}
