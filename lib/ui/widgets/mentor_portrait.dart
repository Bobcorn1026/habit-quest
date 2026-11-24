import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../pixel/pixel.dart';

/// A z floating off 莉娜's head, in art pixels from the portrait's corner.
typedef FloatingZ = ({PixelSprite sprite, int x, int y});

/// What 莉娜 looks like at one moment of her idle loop.
@immutable
class MentorPose {
  const MentorPose(this.face, this.zs);
  final PixelSprite face;
  final List<FloatingZ> zs;

  @override
  bool operator ==(Object other) =>
      other is MentorPose && other.face == face && listEquals(other.zs, zs);

  @override
  int get hashCode => Object.hash(face, Object.hashAll(zs));
}

/// 莉娜's idle loop: she blinks now and then, yawns once a loop, and z's
/// drift up from her head the whole time. Fixed times (no randomness) so
/// screenshots and tests always see the same frame.
abstract final class MentorIdle {
  static const loop = Duration(seconds: 24);
  static const blink = Duration(milliseconds: 130);
  static const blinks = [2600, 7400, 11800, 12150, 16600, 21800];

  /// Yawn: opening, wide open, closing (ms into the loop).
  static const yawnStart = 18000;
  static const yawnWide = 18250;
  static const yawnClose = 19650;
  static const yawnEnd = 19900;

  static const zPeriod = 3200;

  static MentorPose at(Duration elapsed) {
    final t = elapsed.inMilliseconds % loop.inMilliseconds;
    return MentorPose(_face(t), [
      _z(MentorFrames.zSmall, t, 0, x: 36, y: 9, rise: 7),
      _z(MentorFrames.zBig, t, zPeriod ~/ 2, x: 40, y: 7, rise: 7),
    ]);
  }

  static PixelSprite _face(int t) {
    if (t >= yawnWide && t < yawnClose) return MentorFrames.yawn;
    if (t >= yawnStart && t < yawnEnd) return MentorFrames.yawnStart;
    for (final b in blinks) {
      if (t >= b && t < b + blink.inMilliseconds) return MentorFrames.blink;
    }
    return MentorFrames.idle;
  }

  /// Rises [rise] art pixels and drifts right as it goes; gone for the
  /// last part of its cycle so the next one starts fresh.
  static FloatingZ _z(
    PixelSprite sprite,
    int t,
    int offset, {
    required int x,
    required int y,
    required int rise,
  }) {
    final p = ((t + offset) % zPeriod) / zPeriod;
    if (p > .8) return (sprite: sprite, x: x, y: -100);
    return (
      sprite: sprite,
      x: x + (p * 3).floor(),
      y: y - (p / .8 * rise).floor(),
    );
  }
}

/// 莉娜's portrait, animated with [MentorIdle]. Holds still when the system
/// asks for reduced motion.
class MentorPortrait extends StatefulWidget {
  const MentorPortrait({super.key});

  @override
  State<MentorPortrait> createState() => _MentorPortraitState();
}

class _MentorPortraitState extends State<MentorPortrait>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  var _pose = MentorIdle.at(Duration.zero);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still && _ticker.isActive) {
      _ticker.stop();
      _pose = MentorIdle.at(Duration.zero);
    } else if (!still && !_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final pose = MentorIdle.at(elapsed);
    // Most frames change nothing; rebuild only when a pixel moves.
    if (pose != _pose) setState(() => _pose = pose);
  }

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel;
    final face = _pose.face;
    return RepaintBoundary(
      child: SizedBox(
        width: face.width * px,
        height: face.height * px,
        child: Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            PixelSpriteView(face),
            for (final z in _pose.zs)
              if (z.y > -z.sprite.height)
                Positioned(
                  left: z.x * px,
                  top: z.y * px,
                  child: PixelSpriteView(z.sprite),
                ),
          ],
        ),
      ),
    );
  }
}
