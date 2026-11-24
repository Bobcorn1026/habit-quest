import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'pixel_metrics.dart';

/// A small piece of pixel art written as rows of palette keys.
///
/// Each character is one art pixel; `.` and space are transparent. Keys map
/// to colors through [PixelPalette.byKey] unless [palette] overrides them,
/// which lets one drawing be recolored (e.g. a grey and a gold crown).
@immutable
class PixelSprite {
  const PixelSprite(this.id, this.rows, {this.palette = const {}});

  final String id;
  final List<String> rows;
  final Map<String, Color> palette;

  int get width => rows.isEmpty ? 0 : rows.first.length;
  int get height => rows.length;

  /// Returns a copy that draws [from] keys with the colors of [to] keys.
  PixelSprite recolor(Map<String, String> swaps, {String? id}) {
    return PixelSprite(
      id ?? this.id,
      rows,
      palette: {
        ...palette,
        for (final e in swaps.entries) e.key: colorFor(e.value)!,
      },
    );
  }

  Color? colorFor(String key) =>
      key == '.' || key == ' ' ? null : palette[key] ?? PixelPalette.byKey[key];

  /// Horizontal runs of one color, so painting draws few rectangles.
  List<SpriteRun> get runs => _runs[this] ??= _computeRuns();

  // Sprites are const, so the parsed runs are cached off-instance.
  static final _runs = Expando<List<SpriteRun>>('runs');

  List<SpriteRun> _computeRuns() {
    final out = <SpriteRun>[];
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      var x = 0;
      while (x < row.length) {
        final key = row[x];
        var end = x + 1;
        while (end < row.length && row[end] == key) {
          end++;
        }
        final color = colorFor(key);
        if (color != null) out.add(SpriteRun(x, y, end - x, color));
        x = end;
      }
    }
    return out;
  }
}

@immutable
class SpriteRun {
  const SpriteRun(this.x, this.y, this.length, this.color);
  final int x;
  final int y;
  final int length;
  final Color color;
}

/// Draws a [PixelSprite] with hard edges, one sprite pixel per art pixel.
///
/// Sprites are not scaled up: a larger picture gets its own finer drawing
/// (see `PixelArt`) so every pixel on screen shares one grid. The one
/// exception is [scale] for showpieces like the celebration dancers, where
/// whole-number blocks keep the edges crisp.
class PixelSpriteView extends StatelessWidget {
  const PixelSpriteView(this.sprite, {super.key, this.flipX, this.scale = 1});

  final PixelSprite sprite;
  final bool? flipX;
  final int scale;

  @override
  Widget build(BuildContext context) {
    final px = context.artPixel * scale;
    return SizedBox(
      width: sprite.width * px,
      height: sprite.height * px,
      child: CustomPaint(painter: _SpritePainter(sprite, px, flipX ?? false)),
    );
  }
}

class _SpritePainter extends CustomPainter {
  _SpritePainter(this.sprite, this.px, this.flipX) : _runs = sprite.runs;

  final PixelSprite sprite;
  final double px;
  final bool flipX;
  final List<SpriteRun> _runs;

  @override
  void paint(Canvas canvas, Size size) {
    paintSpriteRuns(
      canvas,
      _runs,
      Offset.zero,
      px,
      flipWidth: flipX ? sprite.width : null,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter old) =>
      old.sprite != sprite || old.px != px || old.flipX != flipX;
}

/// Paints sprite runs at [origin]; shared with frames that embed ornaments.
void paintSpriteRuns(
  Canvas canvas,
  List<SpriteRun> runs,
  Offset origin,
  double px, {
  int? flipWidth,
  bool flipY = false,
  int? height,
}) {
  final paint = Paint()..isAntiAlias = false;
  for (final run in runs) {
    final x = flipWidth == null ? run.x : flipWidth - run.x - run.length;
    final y = flipY ? height! - 1 - run.y : run.y;
    paint.color = run.color;
    canvas.drawRect(
      Rect.fromLTWH(
        origin.dx + x * px,
        origin.dy + y * px,
        run.length * px,
        px,
      ),
      paint,
    );
  }
}
