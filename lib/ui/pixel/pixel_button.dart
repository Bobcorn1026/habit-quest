import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'pixel_frame.dart';
import 'pixel_metrics.dart';

enum PixelButtonTone {
  gold(
    PixelPalette.goldLight,
    PixelPalette.goldShade,
    PixelPalette.gold,
    PixelPalette.goldDark,
    PixelPalette.outline,
  ),
  parchment(
    PixelPalette.parchmentLight,
    PixelPalette.parchmentShade,
    PixelPalette.parchment,
    PixelPalette.leather,
    PixelPalette.leather,
  ),
  danger(
    PixelPalette.red,
    PixelPalette.redDark,
    PixelPalette.redShade,
    PixelPalette.redDark,
    PixelPalette.white,
  ),
  arcane(
    PixelPalette.violetLight,
    PixelPalette.violet,
    PixelPalette.violet,
    PixelPalette.outline,
    PixelPalette.white,
  ),
  quiet(
    PixelPalette.panelLight,
    PixelPalette.panelEdge,
    PixelPalette.panel,
    PixelPalette.outline,
    PixelPalette.parchmentLight,
  );

  const PixelButtonTone(
    this.light,
    this.shade,
    this.face,
    this.lip,
    this.foreground,
  );
  final Color light;
  final Color shade;
  final Color face;
  final Color lip;
  final Color foreground;
}

/// A chunky button that sinks by one lip height while pressed.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tone = PixelButtonTone.gold,
    this.expand = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final PixelButtonTone tone;

  /// Stretch to the available width.
  final bool expand;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tone = _enabled ? widget.tone : PixelButtonTone.quiet;
    final pressed = _pressed && _enabled;
    final px = context.artPixel;
    final lip = px * 2;
    final spec = FrameSpec(
      rings: [
        const FrameRing(PixelPalette.outline),
        FrameRing(tone.light, tone.shade),
      ],
      fill: tone.face,
      foreground: tone.foreground,
    );
    final content = Padding(
      padding: EdgeInsets.only(
        top: pressed ? lip : 0,
        bottom: pressed ? 0 : lip,
      ),
      child: CustomPaint(
        painter: FramePainter(spec, px),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: px * 10, vertical: px * 5),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: _enabled ? tone.foreground : PixelPalette.panelLight,
            ),
            textAlign: TextAlign.center,
            child: IconTheme.merge(
              data: IconThemeData(color: tone.foreground),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Flexible(child: widget.child)],
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: CustomPaint(
          painter: _LipPainter(pressed ? null : tone.lip, px),
          child: content,
        ),
      ),
    );
  }
}

/// The dark slab under a raised button.
class _LipPainter extends CustomPainter {
  _LipPainter(this.color, this.px);
  final Color? color;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final c = color;
    if (c == null) return;
    final paint = Paint()..isAntiAlias = false;
    final top = size.height - px * 4;
    paint.color = PixelPalette.outline;
    canvas.drawRect(
      Rect.fromLTRB(px, top, size.width - px, size.height),
      paint,
    );
    paint.color = c;
    canvas.drawRect(
      Rect.fromLTRB(px * 2, top, size.width - px * 2, size.height - px),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LipPainter old) => old.color != color || old.px != px;
}
