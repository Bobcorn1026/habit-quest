import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/clock.dart';
import '../../pixel/pixel.dart';

/// Moves the debug clock forward, to see new days and weeks without waiting.
/// Shows nothing when the clock cannot be moved (release builds, tests).
/// Going back to now keeps whatever happened in the future (weeks settled,
/// fines taken): reload the demo data for a clean state.
class DebugClockControls extends ConsumerStatefulWidget {
  const DebugClockControls({super.key});

  @override
  ConsumerState<DebugClockControls> createState() => _DebugClockControlsState();
}

class _DebugClockControlsState extends ConsumerState<DebugClockControls> {
  void _move(AdjustableClock clock, Duration? by) {
    setState(
      () => clock.offset = by == null ? Duration.zero : clock.offset + by,
    );
    ref.read(todayProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final clock = ref.watch(clockProvider);
    if (clock is! AdjustableClock) return const SizedBox.shrink();
    final today = ref.watch(todayProvider);
    final days = clock.offset.inDays;
    Widget button(String label, Duration? by) => Expanded(
      child: PixelButton(
        tone: PixelButtonTone.quiet,
        expand: true,
        onPressed: () => _move(clock, by),
        child: Text(label),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今天：${today.toKey()}${days == 0 ? '' : '（快 $days 天）'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            button('+1 天', const Duration(days: 1)),
            const SizedBox(width: 8),
            button('+1 週', const Duration(days: 7)),
            const SizedBox(width: 8),
            button('回到現在', null),
          ],
        ),
      ],
    );
  }
}
