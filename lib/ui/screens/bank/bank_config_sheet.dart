import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/providers.dart';
import '../../../domain/bank.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import 'bank_format.dart';

class _FixedDraft {
  _FixedDraft(this.id, String name, int amount, this.reserve)
    : name = TextEditingController(text: name),
      amount = TextEditingController(text: '$amount');

  final String id;
  final TextEditingController name;
  final TextEditingController amount;
  bool reserve;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

/// The bank's monthly numbers. A change counts from the next month.
class BankConfigSheet extends ConsumerStatefulWidget {
  const BankConfigSheet({super.key, required this.config});

  final BankConfig config;

  static Future<void> show(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final config = await container.read(bankServiceProvider).config();
    if (!context.mounted) return;
    await showPixelSheet<void>(
      context,
      builder: (_) => BankConfigSheet(config: config),
    );
  }

  @override
  ConsumerState<BankConfigSheet> createState() => _BankConfigSheetState();
}

class _BankConfigSheetState extends ConsumerState<BankConfigSheet> {
  late final _income = TextEditingController(text: '${widget.config.income}');
  late final _meal = TextEditingController(text: '${widget.config.meal}');
  late final _mealMin = TextEditingController(text: '${widget.config.mealMin}');
  late final _mealMax = TextEditingController(text: '${widget.config.mealMax}');
  late final _fixed = [
    for (final f in widget.config.fixed)
      _FixedDraft(f.id, f.name, f.amount, f.reserve),
  ];

  @override
  void dispose() {
    for (final c in [_income, _meal, _mealMin, _mealMax]) {
      c.dispose();
    }
    for (final f in _fixed) {
      f.dispose();
    }
    super.dispose();
  }

  /// What was typed, or null when something is not a valid amount.
  BankConfig? get _draft {
    int? read(TextEditingController c) {
      final v = parseNtd(c.text);
      return v != null && v >= 0 ? v : null;
    }

    final income = read(_income);
    final meal = read(_meal);
    final min = read(_mealMin);
    final max = read(_mealMax);
    final fixed = <FixedCost>[];
    for (final f in _fixed) {
      final amount = read(f.amount);
      if (amount == null) return null;
      final name = f.name.text.trim();
      fixed.add(
        FixedCost(
          id: f.id,
          name: name.isEmpty ? '固定支出' : name,
          amount: amount,
          reserve: f.reserve,
        ),
      );
    }
    if (income == null || meal == null || min == null || max == null) {
      return null;
    }
    if (min > max) return null;
    return BankConfig(
      income: income,
      meal: meal,
      mealMin: min,
      mealMax: max,
      fixed: fixed,
    );
  }

  Future<void> _save(BankConfig config) async {
    await ref.read(bankServiceProvider).saveConfig(config);
    if (!mounted) return;
    showPixelToast(context, '存好了，下個月 1 號起生效', icon: PixelIcons.scroll);
    Navigator.pop(context);
  }

  Widget _field(String label, TextEditingController c) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: text.bodySmall)),
          Expanded(
            child: PixelTextField(
              controller: c,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final draft = _draft;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('每月設定', style: text.titleLarge),
        Text('改了從下個月 1 號開始算，這個月照舊。', style: text.bodySmall),
        const SizedBox(height: 12),
        _field('每月收入', _income),
        _field('每月餐費', _meal),
        _field('每天至少', _mealMin),
        _field('每天至多', _mealMax),
        const PixelHeading('固定支出', icon: PixelIcons.scroll),
        for (final f in _fixed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PixelTextField(
                        controller: f.name,
                        hint: '名稱',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: PixelTextField(
                        controller: f.amount,
                        hint: '金額',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PixelButton(
                      tone: PixelButtonTone.quiet,
                      onPressed: () => setState(() {
                        _fixed.remove(f);
                        f.dispose();
                      }),
                      child: const Text('×'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                PixelSegments<bool>(
                  values: const [false, true],
                  selected: f.reserve,
                  label: (r) => r ? '只預留（年繳）' : '每月 1 號扣',
                  onChanged: (r) => setState(() => f.reserve = r),
                ),
              ],
            ),
          ),
        PixelButton(
          tone: PixelButtonTone.quiet,
          onPressed: () => setState(
            () => _fixed.add(
              _FixedDraft(
                ref.read(bankRepoProvider).newUid().substring(0, 8),
                '',
                0,
                false,
              ),
            ),
          ),
          child: const Text('＋ 固定支出'),
        ),
        const SizedBox(height: 12),
        Text(
          draft == null
              ? '有數字不對（金額要是 0 以上的整數，每天至少不能大於至多）'
              : '每月進賭場獎池：${formatNtd(draft.refill)} 元',
          style: text.bodyMedium?.copyWith(
            color: draft == null ? PixelPalette.redLight : null,
          ),
        ),
        const SizedBox(height: 12),
        PixelButton(
          expand: true,
          onPressed: draft == null ? null : () => _save(draft),
          child: const Text('儲存'),
        ),
      ],
    );
  }
}
