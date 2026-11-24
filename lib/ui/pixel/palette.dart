import 'dart:ui';

/// The limited palette every pixel-art element draws from.
///
/// Sprites refer to these colors through single-character keys (see
/// [PixelPalette.byKey]) so a sprite can be written as rows of text.
abstract final class PixelPalette {
  // Ink: outlines, dark panels and plaques. Warm so they sit well on wood.
  static const outline = Color(0xFF150D10);
  static const night = Color(0xFF22171C);
  static const panel = Color(0xFF2F2127);
  static const panelEdge = Color(0xFF47333A);
  static const panelLight = Color(0xFF6B5157);

  // Wood: the quest board and the tab bar. Shadows lean red-violet and
  // highlights lean orange, as hand-picked pixel ramps do.
  static const wood0 = Color(0xFF1D1013);
  static const wood1 = Color(0xFF36201B);
  static const wood2 = Color(0xFF4D2E20);
  static const wood3 = Color(0xFF643D26);
  static const wood4 = Color(0xFF7D4F2E);
  static const wood5 = Color(0xFF986439);
  static const wood6 = Color(0xFFB57F4A);
  static const woodRamp = [wood0, wood1, wood2, wood3, wood4, wood5, wood6];

  // Parchment: quest cards and story pages.
  static const parchmentLight = Color(0xFFF3E4BD);
  static const parchment = Color(0xFFE2C992);
  static const parchmentShade = Color(0xFFC4A36A);
  static const parchmentDark = Color(0xFF8E6C3E);
  static const leather = Color(0xFF5A3F22);

  // Gold: frames, EXP, highlights.
  static const goldLight = Color(0xFFFFF0A8);
  static const gold = Color(0xFFF2C14E);
  static const goldShade = Color(0xFFC98A2B);
  static const goldDark = Color(0xFF7D4F17);

  // Blood: relapses, danger.
  static const redLight = Color(0xFFF59A78);
  static const red = Color(0xFFE0594B);
  static const redShade = Color(0xFF9B2A35);
  static const redDark = Color(0xFF5A1424);

  // Arcane teal: magic, streaks.
  static const tealLight = Color(0xFF7FE0D0);
  static const teal = Color(0xFF3A9E9A);
  static const tealDark = Color(0xFF1F5866);

  // Seal purple: quit-habit seals.
  static const violetLight = Color(0xFFB48CE0);
  static const violet = Color(0xFF6C4A9E);
  static const violetDark = Color(0xFF3D2659);

  // Life green: success.
  static const green = Color(0xFF9AD35A);
  static const greenShade = Color(0xFF4A8A3A);
  static const greenDark = Color(0xFF284A33);

  // Steel and skin.
  static const steelLight = Color(0xFFB8C4D8);
  static const steel = Color(0xFF6F7D99);
  static const steelDark = Color(0xFF454B66);
  static const ember = Color(0xFFE8812F);
  static const skin = Color(0xFFF0B98C);
  static const skinShade = Color(0xFFC47E5A);
  static const white = Color(0xFFFFFBEA);

  // Extra steps for the 48×48 portraits: hair, skin and cloth need softer
  // ramps than the small sprites.
  static const emberLight = Color(0xFFF7A859);
  static const emberShade = Color(0xFFC0532C);
  static const skinLight = Color(0xFFFAD3AE);
  static const skinDark = Color(0xFF9A5546);
  static const whiteShade = Color(0xFFD9CBB4);

  /// Character keys used by sprite rows. `.` (or space) is transparent.
  static const byKey = <String, Color>{
    'k': outline,
    'd': night,
    'D': panel,
    'm': panelEdge,
    'M': panelLight,
    'p': parchmentLight,
    'P': parchment,
    'q': parchmentShade,
    'Q': parchmentDark,
    'b': leather,
    'g': goldLight,
    'G': gold,
    'o': goldShade,
    'O': goldDark,
    'h': redLight,
    'r': red,
    'R': redShade,
    'x': redDark,
    't': tealLight,
    'T': teal,
    'u': tealDark,
    'v': violetLight,
    'V': violet,
    'i': violetDark,
    'n': green,
    'N': greenShade,
    'l': greenDark,
    'e': steelLight,
    'E': steel,
    'a': steelDark,
    'f': ember,
    'F': emberLight,
    'z': emberShade,
    's': skin,
    'c': skinLight,
    'C': skinDark,
    'S': skinShade,
    'w': white,
    'W': whiteShade,
    '0': wood0,
    '1': wood1,
    '2': wood2,
    '3': wood3,
    '4': wood4,
    '5': wood5,
    '6': wood6,
  };
}
