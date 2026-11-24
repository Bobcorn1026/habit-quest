import 'package:flutter/material.dart';

import '../../../data/database.dart';
import '../../../domain/bank.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';

/// 「12,345」, 「-300」.
String formatNtd(int amount) {
  final digits = amount.abs().toString();
  final out = StringBuffer(amount < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

/// Reads what was typed as a whole amount of NT dollars; null when it is
/// not one.
int? parseNtd(String text) =>
    int.tryParse(text.replaceAll(RegExp(r'[,\s，]'), ''));

/// Money in red when below zero.
class NtdText extends StatelessWidget {
  const NtdText(this.amount, {super.key, this.style, this.sign = false});

  final int amount;
  final TextStyle? style;

  /// Show a plus in front of amounts above zero.
  final bool sign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text(
      '${sign && amount > 0 ? '+' : ''}${formatNtd(amount)}',
      style: base?.copyWith(
        color: amount < 0 ? PixelPalette.redLight : null,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

PixelSprite accountIcon(BankAccountRow account) =>
    PixelBankIcons.byId(account.icon);

/// What the history calls an account, the hidden ones included.
String accountName(BankAccountRow? account) => switch (account?.role) {
  null when account == null => '外面',
  AccountRole.central => '中央銀行',
  AccountRole.pool => '獎池',
  _ => account!.name,
};
