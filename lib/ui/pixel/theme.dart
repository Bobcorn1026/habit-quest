import 'package:flutter/material.dart';

import 'palette.dart';
import 'pixel_metrics.dart';

const kPixelFont = 'Cubic11';

/// Fallbacks for characters Cubic 11 lacks (rare hanzi, emoji).
const kFontFallback = ['PingFang TC', 'Heiti TC', 'Apple Color Emoji'];

/// Material theme dressed in the pixel palette. Ripples are disabled because
/// pixel buttons show their own pressed state.
ThemeData buildPixelTheme(PixelTypeScale scale) {
  TextStyle style(double size, Color color) => TextStyle(
    fontFamily: kPixelFont,
    fontFamilyFallback: kFontFallback,
    fontSize: size,
    height: 1.4,
    color: color,
  );

  const ink = PixelPalette.parchmentLight;
  const dim = PixelPalette.parchmentShade;
  return ThemeData(
    brightness: Brightness.dark,
    fontFamily: kPixelFont,
    fontFamilyFallback: kFontFallback,
    scaffoldBackgroundColor: PixelPalette.night,
    canvasColor: PixelPalette.night,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: PixelPalette.gold,
      onPrimary: PixelPalette.outline,
      secondary: PixelPalette.teal,
      surface: PixelPalette.panel,
      onSurface: ink,
      error: PixelPalette.red,
    ),
    textTheme: TextTheme(
      displaySmall: style(scale.display, PixelPalette.goldLight),
      titleLarge: style(scale.title, PixelPalette.goldLight),
      titleMedium: style(scale.body, ink),
      bodyLarge: style(scale.body, ink),
      bodyMedium: style(scale.body, ink),
      bodySmall: style(scale.small, dim),
      labelLarge: style(scale.body, ink),
      labelMedium: style(scale.small, ink),
      labelSmall: style(scale.small, dim),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: PixelPalette.gold,
      selectionColor: PixelPalette.goldDark,
    ),
  );
}
