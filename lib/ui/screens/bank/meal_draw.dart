import 'package:flutter/material.dart';

import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import 'bank_format.dart';

/// Rolls a wheel of digits that lands on [amount], today's meal money. The
/// money is already in the envelope when this shows: closing early loses
/// nothing.
Future<void> showMealDraw(BuildContext context, int amount, {String? title}) =>
    showPixelDialog<void>(
      context,
      builder: (_) => MealDraw(amount: amount, title: title ?? '今日餐費'),
    );

class MealDraw extends StatefulWidget {
  const MealDraw({super.key, required this.amount, required this.title});

  final int amount;
  final String title;

  @override
  State<MealDraw> createState() => _MealDrawState();
}

class _MealDrawState extends State<MealDraw>
    with SingleTickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_spin.isAnimating || _spin.isCompleted) return;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _spin.value = 1;
    } else {
      _spin.forward();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final digits = widget.amount.toString().padLeft(3, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: text.titleLarge),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _spin,
          builder: (context, _) {
            final t = _spin.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < digits.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PixelFrame(
                      style: PixelFrameStyle.panel,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        _digit(digits, i, t),
                        style: text.displaySmall?.copyWith(
                          color: t >= _stopAt(i, digits.length)
                              ? PixelPalette.goldLight
                              : PixelPalette.panelLight,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _spin,
          builder: (context, _) => Opacity(
            opacity: _spin.isCompleted ? 1 : 0,
            child: Column(
              children: [
                Text(
                  '已放進餐費帳戶：${formatNtd(widget.amount)} 元',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 12),
                PixelButton(
                  onPressed: _spin.isCompleted
                      ? () => Navigator.pop(context)
                      : null,
                  child: const Text('收下'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The wheels stop from the left, the last one at the end of the spin.
  double _stopAt(int i, int count) => 0.4 + 0.6 * (i + 1) / count;

  String _digit(String digits, int i, double t) {
    if (t >= _stopAt(i, digits.length)) return digits[i];
    return '${((t * 30).floor() + i * 3) % 10}';
  }
}
