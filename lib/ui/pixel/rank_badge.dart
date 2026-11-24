import 'package:flutter/widgets.dart';

import '../../domain/quest_rank.dart';
import 'palette.dart';
import 'pixel_frame.dart';
import 'pixel_metrics.dart';

/// A small tag showing a quest's rank letter in its rank color.
class RankBadge extends StatelessWidget {
  const RankBadge(this.rank, {super.key});

  final QuestRank rank;

  static (Color, Color, Color) colorsFor(QuestRank rank) => switch (rank) {
    QuestRank.sss => (
      PixelPalette.white,
      PixelPalette.goldLight,
      PixelPalette.redShade,
    ),
    QuestRank.ss => (
      PixelPalette.goldLight,
      PixelPalette.ember,
      PixelPalette.outline,
    ),
    QuestRank.s => (
      PixelPalette.goldLight,
      PixelPalette.gold,
      PixelPalette.outline,
    ),
    QuestRank.a => (
      PixelPalette.red,
      PixelPalette.redShade,
      PixelPalette.white,
    ),
    QuestRank.b => (
      PixelPalette.violetLight,
      PixelPalette.violet,
      PixelPalette.white,
    ),
    QuestRank.c => (
      PixelPalette.tealLight,
      PixelPalette.teal,
      PixelPalette.outline,
    ),
    QuestRank.d => (
      PixelPalette.green,
      PixelPalette.greenShade,
      PixelPalette.outline,
    ),
    QuestRank.e => (
      PixelPalette.steelLight,
      PixelPalette.steel,
      PixelPalette.outline,
    ),
    QuestRank.f => (
      PixelPalette.parchmentLight,
      PixelPalette.parchmentShade,
      PixelPalette.leather,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (light, base, ink) = colorsFor(rank);
    final px = context.artPixel;
    return CustomPaint(
      painter: FramePainter(
        FrameSpec(
          rings: [
            const FrameRing(PixelPalette.outline),
            FrameRing(light, base),
          ],
          fill: base,
          foreground: ink,
        ),
        px,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: px * 5, vertical: px * 2),
        child: Text(rank.label, style: TextStyle(color: ink, height: 1)),
      ),
    );
  }
}
