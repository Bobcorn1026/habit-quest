import 'package:flutter/widgets.dart';

import '../pixel/pixel.dart';

/// A quest's 32×32 picture: the item for a quest, or for a seal the monster
/// it holds with a small seal (or crack) badge at its feet.
class QuestArt extends StatelessWidget {
  const QuestArt({
    super.key,
    required this.spriteId,
    required this.habitName,
    required this.seal,
    this.cracked = false,
  });

  final String spriteId;
  final String habitName;
  final bool seal;
  final bool cracked;

  @override
  Widget build(BuildContext context) {
    if (!seal) return PixelSpriteView(PixelArt.byId(spriteId));
    final px = context.artPixel;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PixelSpriteView(PixelMonsters.forSeal(spriteId, habitName)),
        Positioned(
          right: -4 * px,
          bottom: -4 * px,
          child: PixelSpriteView(cracked ? PixelIcons.crack : PixelIcons.seal),
        ),
      ],
    );
  }
}
