import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'pixel_metrics.dart';

enum PixelBarTone {
  exp(PixelPalette.goldLight, PixelPalette.gold, PixelPalette.goldShade),
  streak(PixelPalette.tealLight, PixelPalette.teal, PixelPalette.tealDark),
  seal(PixelPalette.violetLight, PixelPalette.violet, PixelPalette.outline),
  danger(PixelPalette.red, PixelPalette.redShade, PixelPalette.redDark),
  life(PixelPalette.green, PixelPalette.greenShade, PixelPalette.outline);

  const PixelBarTone(this.light, this.base, this.shade);
  final Color light;
  final Color base;
  final Color shade;
}

/// A segmented progress bar; the fill snaps to whole art pixels.
class PixelBar extends StatelessWidget {
  const PixelBar({
    super.key,
    required this.value,
    this.tone = PixelBarTone.exp,
    this.segments = 0,
    this.height = 7,
  });

  /// 0.0–1.0; values outside are clamped.
  final double value;
  final PixelBarTone tone;

  /// Draws a notch every `width / segments` when > 0.
  final int segments;

  /// Total height in art pixels (including the outline).
  final int height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: SizedBox(
        height: height * context.artPixel,
        child: CustomPaint(
          painter: _BarPainter(
            value.clamp(0, 1).toDouble(),
            tone,
            segments,
            context.artPixel,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.value, this.tone, this.segments, this.px);
  final double value;
  final PixelBarTone tone;
  final int segments;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;
    void fill(Rect r, Color c) {
      if (r.width <= 0 || r.height <= 0) return;
      paint.color = c;
      canvas.drawRect(r, paint);
    }

    final w = size.width;
    final h = size.height;
    // Outline with rounded corners, then the empty trough.
    fill(Rect.fromLTRB(px, 0, w - px, h), PixelPalette.outline);
    fill(Rect.fromLTRB(0, px, w, h - px), PixelPalette.outline);
    final trough = Rect.fromLTRB(px, px, w - px, h - px);
    fill(trough, PixelPalette.night);
    fill(
      Rect.fromLTRB(
        trough.left,
        trough.bottom - px,
        trough.right,
        trough.bottom,
      ),
      PixelPalette.panelEdge,
    );

    final cols = (trough.width / px).floor();
    final filled = (cols * value).round();
    if (filled > 0) {
      final right = trough.left + filled * px;
      fill(
        Rect.fromLTRB(trough.left, trough.top, right, trough.bottom),
        tone.base,
      );
      fill(
        Rect.fromLTRB(trough.left, trough.top, right, trough.top + px),
        tone.light,
      );
      fill(
        Rect.fromLTRB(trough.left, trough.bottom - px, right, trough.bottom),
        tone.shade,
      );
    }

    if (segments > 1) {
      for (var i = 1; i < segments; i++) {
        final x = trough.left + (cols * i / segments).round() * px;
        fill(
          Rect.fromLTRB(x, trough.top, x + px, trough.bottom),
          PixelPalette.outline,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.value != value ||
      old.tone != tone ||
      old.segments != segments ||
      old.px != px;
}
