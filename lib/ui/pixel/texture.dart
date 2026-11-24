import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'board_wood.dart';
import 'palette.dart';

/// Procedural fills (wood, paper, dark panels) are rendered once at art-pixel
/// resolution into a tiny image, then scaled up with hard edges. A textured
/// card therefore costs one draw call per frame instead of thousands of
/// rectangles.
abstract final class PixelTextures {
  static final _cache = <String, ui.Image>{};
  static const _maxEntries = 64;

  /// The image for [key] at [cols]×[rows] art pixels, built by [colorAt]
  /// (null means transparent) on first use.
  static ui.Image image(
    String key,
    int cols,
    int rows,
    Color? Function(int x, int y) colorAt,
  ) {
    final id = '$key@${cols}x$rows';
    final hit = _cache.remove(id);
    if (hit != null) return _cache[id] = hit;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = false;
    for (var y = 0; y < rows; y++) {
      Color? run;
      var start = 0;
      for (var x = 0; x <= cols; x++) {
        final c = x < cols ? colorAt(x, y) : null;
        if (c == run) continue;
        if (run != null) {
          paint.color = run;
          canvas.drawRect(
            Rect.fromLTWH(start.toDouble(), y.toDouble(), x - start + 0.0, 1),
            paint,
          );
        }
        run = c;
        start = x;
      }
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(math.max(cols, 1), math.max(rows, 1));
    picture.dispose();

    if (_cache.length >= _maxEntries) _cache.remove(_cache.keys.first);
    return _cache[id] = image;
  }
}

/// Draws a texture image so each of its pixels covers one art pixel.
void paintTexture(Canvas canvas, ui.Image image, Offset origin, double px) {
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    origin & Size(image.width * px, image.height * px),
    Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false,
  );
}

// ---------------------------------------------------------------------------
// Noise

/// A stable 0–1 value for an integer lattice point.
double latticeNoise(int x, int y, [int seed = 0]) {
  var h = (x * 374761393 + y * 668265263 + seed * 362437) & 0x7fffffff;
  h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff;
  return ((h ^ (h >> 16)) & 0xffff) / 0xffff;
}

/// Smooth 0–1 value noise: lattice noise blended with smoothstep.
double valueNoise(double x, double y, [int seed = 0]) {
  final x0 = x.floor();
  final y0 = y.floor();
  double s(double t) => t * t * (3 - 2 * t);
  final tx = s(x - x0);
  final ty = s(y - y0);
  final a = latticeNoise(x0, y0, seed);
  final b = latticeNoise(x0 + 1, y0, seed);
  final c = latticeNoise(x0, y0 + 1, seed);
  final d = latticeNoise(x0 + 1, y0 + 1, seed);
  final top = a + (b - a) * tx;
  final bottom = c + (d - c) * tx;
  return top + (bottom - top) * ty;
}

const _bayer = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5];

/// Ordered-dither threshold in (0, 1) for an art pixel, the classic 4×4
/// Bayer pattern pixel artists use for gradients.
double bayer4(int x, int y) => (_bayer[(y & 3) * 4 + (x & 3)] + 0.5) / 16;

// ---------------------------------------------------------------------------
// Fills

/// The quest board: vertical planks with grain and knots, lit by a lantern
/// above the middle of the screen.
ui.Image woodBoardTexture(
  int cols,
  int rows, {
  BoardWood wood = BoardWood.classic,
}) {
  final plankOf = List<int>.filled(cols, 0);
  final lefts = <int>[];
  final widths = <int>[];
  var left = 0;
  for (var i = 0; left < cols; i++) {
    final w = 30 + (latticeNoise(i, 0, 11) * 14).floor();
    lefts.add(left);
    widths.add(w);
    for (var x = left; x < math.min(left + w, cols); x++) {
      plankOf[x] = i;
    }
    left += w;
  }

  // At most one knot per plank, sometimes none.
  final knots = <int, (double, double, double, double)>{};
  for (var i = 0; i < lefts.length; i++) {
    if (latticeNoise(i, 1, 23) < 0.35) continue;
    knots[i] = (
      lefts[i] + widths[i] * (0.3 + latticeNoise(i, 2, 23) * 0.4),
      rows * (0.15 + latticeNoise(i, 3, 23) * 0.75),
      2.2 + latticeNoise(i, 4, 23) * 1.4,
      5.0 + latticeNoise(i, 5, 23) * 4,
    );
  }

  final ramp = wood.ramp;
  return PixelTextures.image('wood_${wood.name}', cols, rows, (x, y) {
    final p = plankOf[x];
    final u = x - lefts[p];
    final w = widths[p];
    if (u == 0) return ramp[0];

    var warp = (valueNoise(p * 5.0, y / 40, 3) - 0.5) * 7;
    final knot = knots[p];
    if (knot != null) {
      final (kx, ky, rx, ry) = knot;
      final dx = x - kx;
      final dy = y - ky;
      final e = (dx / rx) * (dx / rx) + (dy / ry) * (dy / ry);
      if (e < 1) {
        if (e < 0.35) return ramp[1];
        if (e < 0.7) return ramp[2];
        return dx + dy < 0 ? ramp[5] : ramp[1];
      }
      if (e < 9) warp += (dx >= 0 ? 1 : -1) * 4 * math.exp(-(e - 1) * 0.45);
    }

    final gx = u + warp;
    final band = valueNoise(gx / 3.4, y / 150 + p * 3.0, p + 17);
    final grain = band < 0.34 ? 0 : (band < 0.7 ? 1 : 2);
    final streak = valueNoise(gx / 1.2, y / 26 + p * 9.0, p + 41) > 0.84;

    final lx = (x - cols / 2) / (cols * 0.62);
    final ly = y / rows;
    final plankTone = (latticeNoise(p, 7, 5) - 0.5) * 0.35;
    final light = (1 - lx * lx * 0.9 - ly * 0.8 + plankTone).clamp(0.0, 1.0);
    // Light steps break along the grain instead of in a dither pattern.
    final jitter = valueNoise(gx / 0.9, y / 9 + p * 5.0, p + 61) - 0.5;
    final lit = (light * 2.7 + jitter * 0.7).floor().clamp(0, 3);

    var idx = 1 + grain + lit;
    if (streak) idx -= 1;
    if (u == 1) idx += 1;
    if (u == w - 1) idx -= 1;
    return ramp[idx.clamp(1, 6)];
  });
}

/// Aged paper: soft mottling, light from the top left, worn edges and a few
/// fibres. [seed] varies the pattern between cards of the same size.
ui.Image parchmentTexture(int cols, int rows, int seed) {
  return PixelTextures.image('parchment$seed', cols, rows, (x, y) {
    final edge = math.min(math.min(x, y), math.min(cols - 1 - x, rows - 1 - y));
    final h = latticeNoise(x, y, seed + 101);
    if (edge < 3 && h < (3 - edge) * 0.16) {
      return edge == 0
          ? PixelPalette.parchmentDark
          : PixelPalette.parchmentShade;
    }
    if (latticeNoise(x ~/ 3, y, seed + 7) < 0.005) {
      return PixelPalette.parchmentShade;
    }
    // Mostly the base tone: a lit corner at the top left, a shaded one at
    // the bottom right, with soft mottled borders between them.
    final mottle = valueNoise(x / 10, y / 6, seed + 3) - 0.5;
    final light = 1 - x / cols * 0.3 - y / rows * 0.5;
    final v = light + mottle * 0.3 + (bayer4(x, y) - 0.5) * 0.08;
    if (v < 0.3) return PixelPalette.parchmentShade;
    if (v > 0.93) return PixelPalette.parchmentLight;
    return PixelPalette.parchment;
  });
}

/// A dark plaque that catches a little light along its top.
ui.Image panelTexture(int cols, int rows, Color base, Color lit) {
  // A one-pixel sheen under the top edge, fading out through a checker.
  return PixelTextures.image(
    'panel${base.toARGB32()}',
    cols,
    rows,
    (x, y) => y == 0 || (y == 1 && x.isEven) ? lit : base,
  );
}

/// A wooden beam with horizontal grain, for the tab bar.
ui.Image beamTexture(int cols, int rows) {
  const ramp = PixelPalette.woodRamp;
  return PixelTextures.image('beam', cols, rows, (x, y) {
    final warp = (valueNoise(x / 50, 1.5, 9) - 0.5) * 5;
    final band = valueNoise(x / 140, (y + warp) / 2.6, 13);
    final grain = band < 0.35 ? 0 : (band < 0.7 ? 1 : 2);
    final streak = valueNoise(x / 22, (y + warp) / 1.1, 29) > 0.85;
    final shade = y < 2 ? 1 : 0;
    return ramp[(1 + grain + shade - (streak ? 1 : 0)).clamp(1, 4)];
  });
}
