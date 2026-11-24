import 'package:flutter/widgets.dart';

import 'board_wood.dart';
import 'pixel_metrics.dart';
import 'texture.dart';

/// The wooden quest board behind every screen. Cards and plaques are pinned
/// onto it.
class PixelBackdrop extends StatelessWidget {
  const PixelBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BoardPainter(context.artPixel, BoardWoodScope.of(context)),
      isComplex: true,
      child: child,
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.px, this.wood);
  final double px;
  final BoardWood wood;

  /// Board images are made in steps of this many art pixels so rotating or
  /// resizing (iPad split view) does not rebuild the texture every frame.
  static const _step = 32;

  @override
  void paint(Canvas canvas, Size size) {
    int bucket(double extent) => ((extent / px) / _step).ceil() * _step;
    final cols = bucket(size.width);
    final rows = bucket(size.height);
    if (cols == 0 || rows == 0) return;
    // Center the (slightly larger) board so the lantern light stays centered.
    final dx = -((cols - size.width / px) / 2).floor() * px;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    paintTexture(
      canvas,
      woodBoardTexture(cols, rows, wood: wood),
      Offset(dx, 0),
      px,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.px != px || old.wood != wood;
}
