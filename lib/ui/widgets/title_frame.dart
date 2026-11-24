import 'package:flutter/material.dart';

import '../pixel/pixel.dart';

/// The adventurer's title, in the frame bought from the guild shop.
class TitleFrame extends StatelessWidget {
  const TitleFrame({super.key, required this.title, this.frame});

  final String title;

  /// A frame id from the shop (`bronze`, `silver`, `gold`, `crystal`); null
  /// draws plain text.
  final String? frame;

  static (Color, Color, Color)? colorsFor(String? frame) => switch (frame) {
    'bronze' => (PixelPalette.ember, PixelPalette.redShade, PixelPalette.white),
    'silver' => (
      PixelPalette.white,
      PixelPalette.steelLight,
      PixelPalette.outline,
    ),
    'gold' => (PixelPalette.goldLight, PixelPalette.gold, PixelPalette.outline),
    'crystal' => (
      PixelPalette.tealLight,
      PixelPalette.violetLight,
      PixelPalette.outline,
    ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final colors = colorsFor(frame);
    if (colors == null) {
      return Text(
        '稱號「$title」',
        style: style?.copyWith(color: PixelPalette.goldLight),
      );
    }
    final (light, base, ink) = colors;
    final px = context.artPixel;
    return CustomPaint(
      painter: FramePainter(
        FrameSpec(
          rings: [
            const FrameRing(PixelPalette.outline),
            FrameRing(light, base),
            if (frame == 'crystal') const FrameRing(PixelPalette.white),
          ],
          fill: PixelPalette.panel,
          foreground: ink,
        ),
        px,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: px * 6, vertical: px * 3),
        child: Text(title, style: style?.copyWith(color: light, height: 1)),
      ),
    );
  }
}
