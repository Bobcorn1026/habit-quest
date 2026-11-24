import 'package:flutter/widgets.dart';

import 'palette.dart';

/// Woods the quest board can be made of; the others come from the guild
/// shop. Each ramp runs from the seams (dark) to lantern-lit grain (light).
enum BoardWood {
  classic('原木', PixelPalette.woodRamp),
  oak('淺色橡木', [
    Color(0xFF2A1A12),
    Color(0xFF4F3420),
    Color(0xFF6E4B2C),
    Color(0xFF8E6539),
    Color(0xFFAC7F47),
    Color(0xFFC79B5C),
    Color(0xFFDDB777),
  ]),
  walnut('深色胡桃木', [
    Color(0xFF120B0C),
    Color(0xFF22161A),
    Color(0xFF302024),
    Color(0xFF3F2B2C),
    Color(0xFF503833),
    Color(0xFF654839),
    Color(0xFF7C5B44),
  ]),
  cherry('櫻桃木', [
    Color(0xFF1E0C0E),
    Color(0xFF3A1517),
    Color(0xFF551F1E),
    Color(0xFF6E2B24),
    Color(0xFF873A2C),
    Color(0xFFA04E36),
    Color(0xFFBC6843),
  ]),
  ebony('黑檀木', [
    Color(0xFF0B080D),
    Color(0xFF151018),
    Color(0xFF1E1722),
    Color(0xFF28202D),
    Color(0xFF332A39),
    Color(0xFF403545),
    Color(0xFF504356),
  ]);

  const BoardWood(this.label, this.ramp);
  final String label;
  final List<Color> ramp;

  static BoardWood parse(Object? raw) =>
      values.where((w) => w.name == raw).firstOrNull ?? classic;
}

/// Which wood the board under this subtree is made of.
class BoardWoodScope extends InheritedWidget {
  const BoardWoodScope({super.key, required this.wood, required super.child});

  final BoardWood wood;

  static BoardWood of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BoardWoodScope>()?.wood ??
      BoardWood.classic;

  @override
  bool updateShouldNotify(BoardWoodScope old) => old.wood != wood;
}
