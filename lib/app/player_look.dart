import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/pixel/pixel.dart';
import 'providers.dart';

/// Applies what the player equipped from the shop (the board's wood) to
/// every screen below.
class PlayerLook extends ConsumerWidget {
  const PlayerLook({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wood = ref.watch(equippedProvider).value?.wood;
    return BoardWoodScope(wood: BoardWood.parse(wood), child: child);
  }
}
