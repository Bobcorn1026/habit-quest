import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pixel/pixel.dart';

/// How big a win looks: coins fly for the better prizes; the top prize also
/// flashes the screen and shakes the board.
enum FxSize { none, small, big, jackpot }

/// Whether to skip motion: reduce-motion on iOS (which Flutter does not
/// fold into `disableAnimations`), or animations off elsewhere.
bool reduceMotion(BuildContext context) =>
    (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ||
    (View.maybeOf(context)
            ?.platformDispatcher
            .accessibilityFeatures
            .reduceMotion ??
        false);

/// Plays a one-shot effect each time [shot] changes; [shot] 0 plays
/// nothing.
abstract class _ShotWidget extends StatefulWidget {
  const _ShotWidget({super.key, required this.shot, required this.child});

  final int shot;
  final Widget child;

  Duration get duration;
}

abstract class _ShotState<T extends _ShotWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.shot != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  @override
  void didUpdateWidget(T old) {
    super.didUpdateWidget(old);
    if (widget.shot != old.shot && widget.shot != 0) _play();
  }

  void _play() {
    if (!mounted || reduceMotion(context)) return;
    controller.forward(from: 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// Shakes [child] side to side, art pixel by art pixel.
class ShakeBox extends _ShotWidget {
  const ShakeBox({super.key, required super.shot, required super.child});

  @override
  Duration get duration => const Duration(milliseconds: 450);

  @override
  State<ShakeBox> createState() => _ShakeBoxState();
}

class _ShakeBoxState extends _ShotState<ShakeBox> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final t = controller.value;
      final shaking = controller.isAnimating && t < 1;
      final px = context.artPixel;
      final dx = shaking
          ? (math.sin(t * math.pi * 10) * (1 - t) * 3).round() * px
          : 0.0;
      // Always a Transform, still or not: swapping it for the bare child
      // would rebuild everything below (the game in play) from scratch.
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
    child: widget.child,
  );
}

/// A white flash over [child] that fades out.
class FlashOverlay extends _ShotWidget {
  const FlashOverlay({super.key, required super.shot, required super.child});

  @override
  Duration get duration => const Duration(milliseconds: 380);

  @override
  State<FlashOverlay> createState() => _FlashOverlayState();
}

class _FlashOverlayState extends _ShotState<FlashOverlay> {
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (!controller.isAnimating) return const SizedBox.shrink();
              // Stepped, like an old console's palette fade.
              final step = (controller.value * 4).floor();
              return ColoredBox(
                color: PixelPalette.white.withValues(
                  alpha: const [0.75, 0.45, 0.2, 0.0, 0.0][step],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

/// Gold coins bursting out of the middle of [child] and falling away.
class CoinBurst extends _ShotWidget {
  const CoinBurst({
    super.key,
    required super.shot,
    required super.child,
    this.coins = 24,
  });

  final int coins;

  @override
  Duration get duration => const Duration(milliseconds: 1100);

  @override
  State<CoinBurst> createState() => _CoinBurstState();
}

class _CoinBurstState extends _ShotState<CoinBurst> {
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => controller.isAnimating
                ? CustomPaint(
                    painter: CoinBurstPainter(
                      t: controller.value,
                      px: context.artPixel,
                      coins: widget.coins,
                      seed: widget.shot,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    ],
  );
}

/// Coins thrown up and out from the center, pulled down again, snapped to
/// the art-pixel grid. The same [seed] throws the same coins.
class CoinBurstPainter extends CustomPainter {
  CoinBurstPainter({
    required this.t,
    required this.px,
    required this.coins,
    required this.seed,
  });

  final double t;
  final double px;
  final int coins;
  final int seed;

  // A 5×5 coin: rim, face and a shine in the top left.
  static const _coin = ['.ooo.', 'oYYyo', 'oYyyo', 'oyyGo', '.ooo.'];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint();
    final cx = size.width / 2, cy = size.height / 2;
    final fade = t > 0.75 ? 1 - (t - 0.75) / 0.25 : 1.0;
    for (var i = 0; i < coins; i++) {
      final angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.4;
      final speed = (90 + random.nextDouble() * 140) * px / 1.33;
      final x = cx + math.cos(angle) * speed * t;
      final y = cy + math.sin(angle) * speed * t + 260 * px / 1.33 * t * t;
      final sx = (x / px).floorToDouble() * px;
      final sy = (y / px).floorToDouble() * px;
      // Coins spin: narrower every other frame.
      final edge = ((t * 12).floor() + i).isEven;
      for (var r = 0; r < _coin.length; r++) {
        for (var c = 0; c < _coin[r].length; c++) {
          if (edge && (c == 0 || c == 4)) continue;
          final color = switch (_coin[r][c]) {
            'o' => PixelPalette.goldDark,
            'Y' => PixelPalette.white,
            'y' => PixelPalette.goldLight,
            'G' => PixelPalette.gold,
            _ => null,
          };
          if (color == null) continue;
          paint.color = color.withValues(alpha: fade);
          canvas.drawRect(
            Rect.fromLTWH(sx + c * px, sy + r * px, px, px),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CoinBurstPainter old) => old.t != t || old.seed != seed;
}

/// [value] counted up from zero, in [style].
class CountUpText extends StatefulWidget {
  const CountUpText(
    this.value, {
    super.key,
    this.prefix = '',
    this.suffix = '',
    this.style,
  });

  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final _run = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_run.isAnimating || _run.isCompleted) return;
    if (reduceMotion(context)) {
      _run.value = 1;
    } else {
      _run.forward();
    }
  }

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !reduceMotion(context)) {
      _run.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _run,
    builder: (context, _) {
      final t = Curves.easeOutCubic.transform(_run.value);
      return Text(
        '${widget.prefix}${(widget.value * t).round()}${widget.suffix}',
        style: (widget.style ?? const TextStyle()).copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    },
  );
}

/// The effects of a win of [size] around [child], played on each new
/// [shot].
class WinFx extends StatelessWidget {
  const WinFx({
    super.key,
    required this.shot,
    required this.size,
    required this.child,
  });

  final int shot;
  final FxSize size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final coins = switch (size) {
      FxSize.none => 0,
      FxSize.small => 10,
      FxSize.big => 24,
      FxSize.jackpot => 48,
    };
    // Always the same tree, so the game inside keeps its state when the
    // size of the next win changes; a shot of 0 plays nothing.
    final jackpot = size == FxSize.jackpot ? shot : 0;
    return FlashOverlay(
      shot: jackpot,
      child: ShakeBox(
        shot: jackpot,
        child: CoinBurst(
          shot: coins > 0 ? shot : 0,
          coins: coins,
          child: child,
        ),
      ),
    );
  }
}
