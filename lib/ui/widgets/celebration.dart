import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../pixel/pixel.dart';
import 'mentor.dart';

/// A big moment (level up, guild promotion, a new class): confetti, chibi
/// adventurers dancing, and 莉娜 cheering. Closes on her last line.
Future<void> showCelebration(
  BuildContext context, {
  required String title,
  required String detail,
  required List<String> lines,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: false,
  barrierColor: const Color(0xE6140A0C),
  pageBuilder: (ctx, _, _) => Material(
    type: MaterialType.transparency,
    child: Stack(
      children: [
        const Positioned.fill(child: _Confetti()),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Spacer(),
                    PixelFrame(
                      style: PixelFrameStyle.ornate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(ctx).textTheme.displaySmall
                                ?.copyWith(color: PixelPalette.goldLight),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detail,
                            textAlign: TextAlign.center,
                            style: Theme.of(ctx).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 28),
                          const DancingChibis(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const Spacer(),
                    MentorBox(
                      lines: lines,
                      onTapDone: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

/// Chibi adventurers hopping and turning to the beat.
class DancingChibis extends StatefulWidget {
  const DancingChibis({super.key});

  @override
  State<DancingChibis> createState() => _DancingChibisState();
}

class _DancingChibisState extends State<DancingChibis>
    with SingleTickerProviderStateMixin {
  static const _beat = Duration(milliseconds: 280);
  late final Ticker _ticker = createTicker((elapsed) {
    final beat = elapsed.inMilliseconds ~/ _beat.inMilliseconds;
    if (beat != _count) setState(() => _count = beat);
  });
  var _count = 0;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, chibi) in PixelChibis.all.indexed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: px * 2),
            child: Transform.translate(
              // Hop on alternate beats, neighbours out of step.
              offset: Offset(0, (_count + i).isEven ? -px * 6 : 0),
              child: PixelSpriteView(
                chibi,
                flipX: ((_count ~/ 2) + i).isEven,
                scale: 2,
              ),
            ),
          ),
      ],
    );
  }
}

class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(
    (elapsed) => setState(() => _t = elapsed.inMilliseconds / 1000),
  );
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter(_t, context.artPixel));
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.px);

  final double t;
  final double px;

  static const _colors = [
    PixelPalette.goldLight,
    PixelPalette.gold,
    PixelPalette.redLight,
    PixelPalette.tealLight,
    PixelPalette.violetLight,
    PixelPalette.white,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 48; i++) {
      final x0 = random.nextDouble() * size.width;
      final speed = 60 + random.nextDouble() * 90;
      final phase = random.nextDouble() * size.height;
      final sway = random.nextDouble() * 2 * math.pi;
      final y = (phase + t * speed) % (size.height + 20) - 10;
      final x = x0 + math.sin(t * 2 + sway) * 12;
      // Snap to the art-pixel grid so the confetti stays crisp.
      final sx = (x / px).floorToDouble() * px;
      final sy = (y / px).floorToDouble() * px;
      paint.color = _colors[i % _colors.length];
      final tall = (t * 4 + sway).floor().isEven;
      canvas.drawRect(
        Rect.fromLTWH(sx, sy, px * (tall ? 1 : 2), px * (tall ? 2 : 1)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
