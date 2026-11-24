import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/providers.dart';
import '../../../domain/bank.dart';
import '../../../game/bank_rules.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';
import '../../widgets/pixel_controls.dart';
import 'bank_format.dart';

/// Opening the bank: what it will do each month, and the one number it
/// needs, the real account's balance today.
class BankSetup extends ConsumerStatefulWidget {
  const BankSetup({super.key});

  @override
  ConsumerState<BankSetup> createState() => _BankSetupState();
}

class _BankSetupState extends ConsumerState<BankSetup> {
  final _balance = TextEditingController();
  BankConfig? _config;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(bankServiceProvider).config().then((c) {
      if (mounted) setState(() => _config = c);
    });
  }

  @override
  void dispose() {
    _balance.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final balance = parseNtd(_balance.text);
    if (balance == null) return;
    setState(() => _busy = true);
    await ref.read(bankServiceProvider).open(balance: balance);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final config = _config;
    final today = ref.watch(todayProvider);
    final daysInMonth = daysInMonthOf(today);
    final daysLeft = daysInMonth - today.day + 1;
    int part(int monthly, {int step = 1}) => prorate(
      monthly,
      daysLeft: daysLeft,
      daysInMonth: daysInMonth,
      step: step,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelFrame(
          style: PixelFrameStyle.ornate,
          child: Row(
            children: [
              const PixelSpriteView(PixelBankIcons.vault),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '把現實的錢放進城鎮：中央銀行是你的戶頭，底下的子帳戶是各種用途的信封。',
                  style: text.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        if (config != null) ...[
          const PixelHeading('每個月 1 號', icon: PixelIcons.scroll),
          PixelFrame(
            style: PixelFrameStyle.panel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _line(context, '收入進中央銀行', config.income),
                _line(
                  context,
                  '餐費（每天領 ${config.mealMin}–${config.mealMax}）',
                  -config.meal,
                ),
                for (final f in config.fixed)
                  _line(
                    context,
                    f.reserve ? '${f.name}（留在中央預留）' : f.name,
                    -f.amount,
                  ),
                const Divider(color: PixelPalette.panelEdge),
                _line(context, '進賭場獎池', config.refill),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '這個月從今天算起（剩 $daysLeft 天）：餐費 ${formatNtd(part(config.meal, step: 10))}、'
            '獎池 ${formatNtd(part(config.refill))}。收入和健身房從下個月開始記。'
            '數字之後可以在「每月設定」改。',
            style: text.bodySmall,
          ),
        ],
        const PixelHeading('戶頭現在有多少錢？', icon: PixelIcons.coin),
        PixelTextField(
          controller: _balance,
          hint: '例如 20000',
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text('整筆先放在中央銀行；子帳戶從 0 開始，靠賭場贏錢（餐費每天領）。', style: text.bodySmall),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: _busy || parseNtd(_balance.text) == null ? null : _open,
          child: const Text('開戶'),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: () => ref.read(bankServiceProvider).openDemo(),
              child: const Text('示範開戶（開發用）'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _line(BuildContext context, String label, int amount) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodySmall)),
          NtdText(amount, style: text.bodyMedium, sign: true),
        ],
      ),
    );
  }
}
