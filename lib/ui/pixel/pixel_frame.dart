import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'pixel_metrics.dart';
import 'sprite.dart';
import 'texture.dart';

/// One beveled band of a frame: [light] on the top/left edges, [dark] on the
/// bottom/right edges.
@immutable
class FrameRing {
  const FrameRing(this.light, [Color? dark]) : dark = dark ?? light;
  final Color light;
  final Color dark;
}

enum FrameTexture { none, parchment, panel, night, beam }

/// Everything needed to draw a frame style; all sizes are in art pixels.
@immutable
class FrameSpec {
  const FrameSpec({
    required this.rings,
    required this.fill,
    required this.foreground,
    this.texture = FrameTexture.none,
    this.roundCorners = true,
    this.cornerOrnament,
    this.contentInset = 4,
    this.shadow = 0,
    this.pinned = false,
  });

  /// Outermost first.
  final List<FrameRing> rings;
  final Color fill;

  /// Default text color inside the frame.
  final Color foreground;
  final FrameTexture texture;

  /// Leaves the outermost corner pixels empty so corners look rounded.
  final bool roundCorners;

  /// Drawn at the top-left corner and mirrored into the other three.
  final PixelSprite? cornerOrnament;
  final int contentInset;

  /// Depth in art pixels of the shadow cast onto the board below; 0 for
  /// frames nested inside other frames.
  final int shadow;

  /// Draws a brass tack at the top, as if pinned to the board.
  final bool pinned;

  double borderWidth(double px) => rings.length * px;
  double padding(double px) => (rings.length + contentInset) * px;
}

const _gem = PixelSprite('gem', [
  '..kk..',
  '.kgGk.',
  'kGrrok',
  'kGrRok',
  '.kook.',
  '..kk..',
]);

const _tack = PixelSprite('tack', [
  '..kkk..',
  '.kgGGk.',
  'kgGGGok',
  'kGGGook',
  'kGooooO',
  '.kOOOk.',
  '..kkk..',
]);

/// Shadows are translucent so the wood grain shows through them.
const _shadowColor = Color(0x8C140A0C);

enum PixelFrameStyle {
  /// Gold-trimmed dark panel for headers and important moments.
  ornate(
    FrameSpec(
      rings: [
        FrameRing(PixelPalette.outline),
        FrameRing(PixelPalette.goldLight, PixelPalette.goldShade),
        FrameRing(PixelPalette.gold, PixelPalette.goldDark),
        FrameRing(PixelPalette.outline),
      ],
      fill: PixelPalette.panel,
      foreground: PixelPalette.parchmentLight,
      texture: FrameTexture.panel,
      cornerOrnament: _gem,
      contentInset: 5,
      shadow: 3,
    ),
  ),

  /// Parchment card for build-habit quests and story pages.
  parchment(
    FrameSpec(
      rings: [
        FrameRing(PixelPalette.outline),
        FrameRing(PixelPalette.parchmentDark, PixelPalette.leather),
        FrameRing(PixelPalette.parchmentLight, PixelPalette.parchmentShade),
      ],
      fill: PixelPalette.parchment,
      foreground: PixelPalette.leather,
      texture: FrameTexture.parchment,
      contentInset: 6,
      shadow: 3,
      pinned: true,
    ),
  ),

  /// Quiet dark panel for secondary content.
  panel(
    FrameSpec(
      rings: [
        FrameRing(PixelPalette.outline),
        FrameRing(PixelPalette.panelLight, PixelPalette.panelEdge),
      ],
      fill: PixelPalette.panel,
      foreground: PixelPalette.parchmentLight,
      contentInset: 3,
    ),
  ),

  /// Violet arcane frame for quit-habit seals.
  seal(
    FrameSpec(
      rings: [
        FrameRing(PixelPalette.outline),
        FrameRing(PixelPalette.violetLight, PixelPalette.violet),
        FrameRing(PixelPalette.outline),
      ],
      fill: PixelPalette.night,
      foreground: PixelPalette.parchmentLight,
      texture: FrameTexture.night,
      contentInset: 6,
      shadow: 3,
    ),
  );

  const PixelFrameStyle(this.spec);
  final FrameSpec spec;
}

/// A pixel-art box around [child].
class PixelFrame extends StatelessWidget {
  const PixelFrame({
    super.key,
    this.style = PixelFrameStyle.parchment,
    this.padding,
    this.seed = 0,
    required this.child,
  });

  final PixelFrameStyle style;

  /// Varies the texture between frames of the same size.
  final int seed;

  /// Overrides the default inner padding.
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spec = style.spec;
    final px = context.artPixel;
    return CustomPaint(
      painter: FramePainter(spec, px, seed: seed),
      child: Padding(
        padding: padding ?? EdgeInsets.all(spec.padding(px)),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: spec.foreground),
          child: IconTheme.merge(
            data: IconThemeData(color: spec.foreground),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FramePainter extends CustomPainter {
  FramePainter(this.spec, this.px, {this.seed = 0});

  final FrameSpec spec;
  final double px;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    paintFrame(canvas, Offset.zero & size, spec, px, seed: seed);
  }

  @override
  bool shouldRepaint(FramePainter old) =>
      old.spec != spec || old.px != px || old.seed != seed;
}

/// Draws [spec] filling [bounds]. Exposed so buttons and bars can reuse it.
void paintFrame(
  Canvas canvas,
  Rect bounds,
  FrameSpec spec,
  double px, {
  int seed = 0,
}) {
  final paint = Paint()..isAntiAlias = false;
  void fill(Rect r, Color c) {
    if (r.width <= 0 || r.height <= 0) return;
    paint.color = c;
    canvas.drawRect(r, paint);
  }

  if (spec.shadow > 0) {
    // Light comes from above: the shadow falls mostly downward.
    final s = bounds.translate(px, spec.shadow * px);
    fill(
      Rect.fromLTRB(s.left + px, s.top, s.right - px, s.bottom),
      _shadowColor,
    );
    fill(
      Rect.fromLTRB(s.left, s.top + px, s.left + px, s.bottom - px),
      _shadowColor,
    );
    fill(
      Rect.fromLTRB(s.right - px, s.top + px, s.right, s.bottom - px),
      _shadowColor,
    );
  }

  for (final (i, ring) in spec.rings.indexed) {
    final l = bounds.left + i * px;
    final t = bounds.top + i * px;
    final r = bounds.right - i * px;
    final b = bounds.bottom - i * px;
    final cut = (i == 0 && spec.roundCorners) ? px : 0.0;
    fill(Rect.fromLTRB(l + cut, t, r - cut, t + px), ring.light);
    fill(Rect.fromLTRB(l, t + cut, l + px, b - cut), ring.light);
    fill(Rect.fromLTRB(l + cut, b - px, r - cut, b), ring.dark);
    fill(Rect.fromLTRB(r - px, t + cut, r, b - cut), ring.dark);
  }

  final inner = bounds.deflate(spec.borderWidth(px));
  fill(inner, spec.fill);
  _paintTexture(canvas, inner, spec.texture, px, seed);

  final ornament = spec.cornerOrnament;
  if (ornament != null) {
    final runs = ornament.runs;
    final w = ornament.width * px;
    final h = ornament.height * px;
    final o = px; // sit on the bevel, just inside the outline
    paintSpriteRuns(canvas, runs, bounds.topLeft + Offset(o, o), px);
    paintSpriteRuns(
      canvas,
      runs,
      Offset(bounds.right - o - w, bounds.top + o),
      px,
      flipWidth: ornament.width,
    );
    paintSpriteRuns(
      canvas,
      runs,
      Offset(bounds.left + o, bounds.bottom - o - h),
      px,
      flipY: true,
      height: ornament.height,
    );
    paintSpriteRuns(
      canvas,
      runs,
      Offset(bounds.right - o - w, bounds.bottom - o - h),
      px,
      flipWidth: ornament.width,
      flipY: true,
      height: ornament.height,
    );
  }

  if (spec.pinned) {
    final runs = _tack.runs;
    final at = Offset(
      bounds.center.dx - (_tack.width / 2).floor() * px,
      bounds.top - 2 * px,
    );
    final shadow = [
      for (final r in runs) SpriteRun(r.x, r.y, r.length, _shadowColor),
    ];
    paintSpriteRuns(canvas, shadow, at + Offset(px, 2 * px), px);
    paintSpriteRuns(canvas, runs, at, px);
  }
}

void _paintTexture(
  Canvas canvas,
  Rect area,
  FrameTexture texture,
  double px,
  int seed,
) {
  final cols = (area.width / px).floor();
  final rows = (area.height / px).floor();
  if (cols <= 0 || rows <= 0) return;
  final image = switch (texture) {
    FrameTexture.none => null,
    FrameTexture.parchment => parchmentTexture(cols, rows, seed),
    FrameTexture.panel => panelTexture(
      cols,
      rows,
      PixelPalette.panel,
      PixelPalette.panelEdge,
    ),
    FrameTexture.night => panelTexture(
      cols,
      rows,
      PixelPalette.night,
      PixelPalette.panel,
    ),
    FrameTexture.beam => beamTexture(cols, rows),
  };
  if (image != null) paintTexture(canvas, image, area.topLeft, px);
}
