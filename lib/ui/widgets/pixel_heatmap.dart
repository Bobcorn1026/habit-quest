import 'package:flutter/widgets.dart';

import '../../core/logical_day.dart';
import '../../domain/check_in.dart';
import '../pixel/pixel.dart';

/// The last [weeks] weeks of one habit as a grid of tiny pixel tiles:
/// columns are weeks (oldest left), rows are Monday to Sunday.
class PixelHeatmap extends StatelessWidget {
  const PixelHeatmap({
    super.key,
    required this.outcomes,
    required this.today,
    required this.firstDay,
    this.weeks = 8,
    this.weekStartsOn = DateTime.monday,
  });

  final Map<LogicalDay, CheckInOutcome> outcomes;
  final LogicalDay today;
  final LogicalDay firstDay;
  final int weeks;
  final int weekStartsOn;

  static const _cell = 6; // art pixels
  static const _gap = 1;

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel;
    final step = (_cell + _gap) * px;
    return SizedBox(
      width: weeks * step,
      height: 7 * step,
      child: CustomPaint(painter: _HeatmapPainter(this, px)),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter(this.map, this.px);
  final PixelHeatmap map;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = PixelHeatmap._cell * px;
    final step = (PixelHeatmap._cell + PixelHeatmap._gap) * px;
    final paint = Paint()..isAntiAlias = false;
    final offset = (map.today.weekday - map.weekStartsOn) % 7;
    final firstColumnStart = map.today.addDays(-offset - 7 * (map.weeks - 1));
    for (var w = 0; w < map.weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final day = firstColumnStart.addDays(w * 7 + d);
        if (day.isAfter(map.today)) continue;
        paint.color = day.isBefore(map.firstDay)
            ? PixelPalette.night
            : switch (map.outcomes[day]) {
                CheckInOutcome.done => PixelPalette.green,
                CheckInOutcome.partial => PixelPalette.gold,
                CheckInOutcome.resisted => PixelPalette.violetLight,
                CheckInOutcome.relapsed => PixelPalette.red,
                null => PixelPalette.panelEdge,
              };
        canvas.drawRect(Rect.fromLTWH(w * step, d * step, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.map.outcomes != map.outcomes ||
      old.map.today != map.today ||
      old.px != px;
}

/// A whole year at a glance: one small tile per day, brighter green the
/// more of that day's commissions were finished, gold for a perfect day.
class YearHeatmap extends StatelessWidget {
  const YearHeatmap({
    super.key,
    required this.levels,
    required this.today,
    this.weeks = 52,
    this.weekStartsOn = DateTime.monday,
  });

  /// 0–1 per day (see `dailyCompletion`); missing days had nothing due.
  final Map<LogicalDay, double> levels;
  final LogicalDay today;
  final int weeks;
  final int weekStartsOn;

  static const _cell = 3; // art pixels
  static const _gap = 1;

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel;
    final step = (_cell + _gap) * px;
    return SizedBox(
      width: weeks * step,
      height: 7 * step,
      child: CustomPaint(painter: _YearPainter(this, px)),
    );
  }
}

class _YearPainter extends CustomPainter {
  _YearPainter(this.map, this.px);
  final YearHeatmap map;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = YearHeatmap._cell * px;
    final step = (YearHeatmap._cell + YearHeatmap._gap) * px;
    final paint = Paint()..isAntiAlias = false;
    final offset = (map.today.weekday - map.weekStartsOn) % 7;
    final start = map.today.addDays(-offset - 7 * (map.weeks - 1));
    for (var w = 0; w < map.weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final day = start.addDays(w * 7 + d);
        if (day.isAfter(map.today)) continue;
        final level = map.levels[day];
        paint.color = level == null
            ? PixelPalette.night
            : level >= 1
            ? PixelPalette.goldLight
            : level >= 0.66
            ? PixelPalette.green
            : level >= 0.33
            ? PixelPalette.greenShade
            : level > 0
            ? PixelPalette.greenDark
            : PixelPalette.panelEdge;
        canvas.drawRect(Rect.fromLTWH(w * step, d * step, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_YearPainter old) =>
      old.map.levels != map.levels ||
      old.map.today != map.today ||
      old.px != px;
}
