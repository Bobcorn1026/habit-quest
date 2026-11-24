/// 「-50:00」「12:34」「1:05:00」: the training-ground timer.
String formatFocusClock(int seconds) {
  final sign = seconds < 0 ? '-' : '';
  final s = seconds.abs();
  final h = s ~/ 3600;
  final m = s % 3600 ~/ 60;
  final rest = (s % 60).toString().padLeft(2, '0');
  return h > 0
      ? '$sign$h:${m.toString().padLeft(2, '0')}:$rest'
      : '$sign${m.toString().padLeft(2, '0')}:$rest';
}

/// 「3 小時 20 分」「45 分鐘」「10 小時」, rounded down to the minute.
String formatFocusSpan(int seconds) {
  final minutes = seconds ~/ 60;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m 分鐘';
  return m == 0 ? '$h 小時' : '$h 小時 $m 分';
}

/// Minutes still owed for [seconds] below zero, rounded up so that the last
/// few seconds of debt still show.
int owedMinutes(int seconds) => seconds >= 0 ? 0 : (-seconds + 59) ~/ 60;

/// 「×1.5」 for a price level of 150 percent.
String formatPriceLevel(int percent) {
  final whole = percent ~/ 100;
  final rest = percent % 100;
  if (rest == 0) return '×$whole';
  final digits = rest % 10 == 0
      ? '${rest ~/ 10}'
      : rest.toString().padLeft(2, '0');
  return '×$whole.$digits';
}
