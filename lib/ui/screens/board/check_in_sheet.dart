import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/habit.dart';
import '../../../domain/quest.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';

typedef CheckInInput = ({double? amount, String note});

/// A sanity cap for a typed amount.
const _maxAmount = 99999.0;

/// Asks how much was done and for an optional one-line note.
class CheckInSheet extends StatefulWidget {
  const CheckInSheet({super.key, required this.habit, required this.quest});

  final Habit habit;
  final Quest quest;

  static Future<CheckInInput?> show(
    BuildContext context, {
    required Habit habit,
    required Quest quest,
  }) => showPixelSheet<CheckInInput>(
    context,
    builder: (_) => CheckInSheet(habit: habit, quest: quest),
  );

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  late double? _amount = widget.quest.target ?? widget.habit.target;
  final _note = TextEditingController();
  final _amountField = TextEditingController();

  /// True while the big number is replaced by a field for typing it.
  bool _typing = false;

  double get _target => widget.quest.target ?? widget.habit.target ?? 1;

  /// Minutes move in fives; small counts move by one.
  double get _step => _target >= 10 ? 5 : 1;

  @override
  void dispose() {
    _note.dispose();
    _amountField.dispose();
    super.dispose();
  }

  void _set(double v) => setState(() {
    _amount = v < 0 ? 0 : v;
    _typing = false;
  });

  void _startTyping() => setState(() {
    final shown = formatAmount(_amount ?? 0);
    _amountField.value = TextEditingValue(
      text: shown,
      selection: TextSelection(baseOffset: 0, extentOffset: shown.length),
    );
    _typing = true;
  });

  /// Anything that is not a positive number counts as nothing done yet, which
  /// keeps the report button off.
  void _typed(String v) {
    final n = double.tryParse(v.trim());
    setState(() => _amount = n == null || n < 0 ? 0 : math.min(n, _maxAmount));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final habit = widget.habit;
    final amount = _amount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('回報：${widget.quest.title}', style: text.titleLarge),
        Text(habit.name, style: text.bodySmall),
        if (habit.hasAmount && amount != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: () => _set(amount - _step),
                child: const Text('－'),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  if (_typing)
                    SizedBox(
                      width: 140,
                      child: PixelTextField(
                        key: const Key('amount-field'),
                        controller: _amountField,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: _typed,
                        onSubmitted: (_) => setState(() => _typing = false),
                      ),
                    )
                  else
                    GestureDetector(
                      key: const Key('amount-value'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _startTyping,
                      child: Text(
                        formatAmount(amount),
                        style: text.displaySmall,
                      ),
                    ),
                  Text(
                    '${habit.unit ?? ''}（目標 ${formatAmount(_target)}）',
                    style: text.bodySmall,
                  ),
                  if (!_typing) Text('點數字可以直接輸入', style: text.bodySmall),
                ],
              ),
              const SizedBox(width: 16),
              PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: () => _set(amount + _step),
                child: const Text('＋'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in const [0.5, 1.0, 1.5, 2.0])
                PixelButton(
                  tone: PixelButtonTone.parchment,
                  onPressed: () => _set((_target * f).roundToDouble()),
                  child: Text(f == 1 ? '剛好' : '×$f'),
                ),
            ],
          ),
          if (amount < _target)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '未達目標也沒關係：出席本身就是修行（部分經驗值）。',
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
        const SizedBox(height: 16),
        PixelTextField(
          controller: _note,
          hint: '一句話心得（選填，會寫進故事裡）',
          maxLines: 2,
          minLines: 1,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: amount == 0
              ? null
              : () => Navigator.pop<CheckInInput>(context, (
                  amount: habit.hasAmount ? amount : null,
                  note: _note.text,
                )),
          child: const Text('回報冒險成果'),
        ),
      ],
    );
  }
}

/// Confirms a relapse with an optional note.
class CrackDialog extends StatefulWidget {
  const CrackDialog({super.key, required this.title});

  final String title;

  static Future<String?> show(BuildContext context, String title) =>
      showPixelDialog<String>(
        context,
        builder: (_) => CrackDialog(title: title),
      );

  @override
  State<CrackDialog> createState() => _CrackDialogState();
}

class _CrackDialogState extends State<CrackDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PixelSpriteView(PixelArt.crack),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${widget.title}的封印出現裂痕？', style: text.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('一道裂痕不會讓封印破碎，連續兩天才會。誠實面對，也是勇者的修行。', style: text.bodyMedium),
        const SizedBox(height: 12),
        PixelTextField(controller: _note, hint: '發生了什麼？（選填）', maxLines: 2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.danger,
                expand: true,
                onPressed: () => Navigator.pop(context, _note.text),
                child: const Text('記下裂痕'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
