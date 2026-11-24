import 'package:flutter/widgets.dart';

/// Physical pixels per art pixel: four on a 3x iPhone and three on a 2x iPad,
/// fine enough to read as detailed modern pixel art while every art pixel
/// still covers a whole number of physical pixels. At these sizes one art
/// pixel also equals one pixel of the body font (see [PixelTypeScale]).
int physicalPixelsPerArtPixel(double devicePixelRatio) =>
    devicePixelRatio >= 2.5 ? 4 : (devicePixelRatio >= 1.5 ? 3 : 2);

/// Size of one art pixel in logical points.
double artPixelFor(double devicePixelRatio) =>
    physicalPixelsPerArtPixel(devicePixelRatio) / devicePixelRatio;

extension ArtPixelOf on BuildContext {
  /// Size of one art pixel on this screen, in logical points.
  double get artPixel => artPixelFor(MediaQuery.devicePixelRatioOf(this));
}

/// Cubic 11 is drawn on a 12px em grid; text is crisp only when
/// `fontSize * devicePixelRatio / 12` is a whole number.
const double _fontGrid = 12;

/// The smallest size at or above [target] that draws the pixel font crisply
/// at [dpr].
double crispFontSize(double dpr, double target) {
  // Sizes are multiples of 12 / dpr; fall back to the 12pt grid when the
  // ratio is fractional (e.g. some external displays).
  final step = dpr == dpr.roundToDouble() ? _fontGrid / dpr : _fontGrid;
  return (target / step).ceil() * step;
}

/// Font sizes that render the pixel font crisply on the current screen.
@immutable
class PixelTypeScale {
  const PixelTypeScale({
    required this.small,
    required this.body,
    required this.title,
    required this.display,
  });

  /// Picks the smallest crisp size at or above each target size.
  factory PixelTypeScale.forDevicePixelRatio(double dpr) {
    double crisp(double target) => crispFontSize(dpr, target);

    return PixelTypeScale(
      small: crisp(12),
      body: crisp(15),
      title: crisp(22),
      display: crisp(34),
    );
  }

  final double small;
  final double body;
  final double title;
  final double display;

  @override
  bool operator ==(Object other) =>
      other is PixelTypeScale &&
      other.small == small &&
      other.body == body &&
      other.title == title &&
      other.display == display;

  @override
  int get hashCode => Object.hash(small, body, title, display);
}
