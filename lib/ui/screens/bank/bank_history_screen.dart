import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/notion_sync.dart';
import '../../../data/database.dart';
import '../../../domain/bank.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import 'bank_format.dart';
import 'bank_screen.dart';

/// Every money move, newest first, by day; or one envelope's.
class BankHistoryScreen extends ConsumerWidget {
  const BankHistoryScreen({super.key, this.account});

  final BankAccountRow? account;

  static Future<void> open(BuildContext context, {BankAccountRow? account}) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BankHistoryScreen(account: account)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final view = ref.watch(bankViewProvider).value;
    final account = this.account;
    final txns = ref.watch(bankTxnsProvider(account?.id)).value;
    final children = <Widget>[];
    if (view != null && account != null) {
      children.add(
        AccountRow(account: account, balance: view.balanceOf(account)),
      );
    }
    if (view != null && txns != null) {
      if (txns.isEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text('還沒有紀錄', style: text.bodySmall),
          ),
        );
      }
      String? lastDay;
      for (final txn in txns) {
        final key = txn.day.toKey();
        if (key != lastDay) {
          lastDay = key;
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(
                formatDayLabel(txn.day.month, txn.day.day, txn.day.weekday),
                style: text.bodySmall,
              ),
            ),
          );
        }
        children.add(_TxnRow(txn: txn, view: view, account: account));
      }
    }
    return PixelPage(
      title: account == null ? '明細' : '${account.name}的明細',
      children: children,
    );
  }
}

class _TxnRow extends ConsumerWidget {
  const _TxnRow({required this.txn, required this.view, this.account});

  final BankTxnRow txn;
  final BankView view;
  final BankAccountRow? account;

  BankAccountRow? _byId(int? id) =>
      id == null ? null : view.accounts.where((a) => a.id == id).firstOrNull;

  Future<void> _void(BuildContext context, WidgetRef ref) async {
    final yes = await showPixelDialog<bool>(
      context,
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('作廢這筆？', style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${txn.title}  ${formatNtd(txn.amount)} 元'
              '${txn.kind == TxnKind.transfer || txn.kind == TxnKind.fee ? '（轉帳和手續費一起作廢）' : ''}'
              '${txn.notionPageId == null ? '' : '\nNotion 記帳本裡的這筆也會移到垃圾桶。'}',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    tone: PixelButtonTone.quiet,
                    expand: true,
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PixelButton(
                    tone: PixelButtonTone.danger,
                    expand: true,
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('作廢'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (yes == true && await ref.read(bankServiceProvider).voidTxn(txn.id)) {
      syncNotionSoon(ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final from = _byId(txn.fromId);
    final to = _byId(txn.toId);
    final voided = txn.voidedAt != null;
    final canVoid = !voided && kVoidableKinds.contains(txn.kind);
    // The envelope the move is about, else the vault.
    final shown = [to, from].firstWhere(
      (a) => a != null && !kSystemRoles.contains(a.role),
      orElse: () => from ?? to,
    );
    final int? signed = switch (account) {
      final a? => txn.toId == a.id ? txn.amount : -txn.amount,
      null when txn.fromId == null => txn.amount,
      null when txn.toId == null => -txn.amount,
      null => null,
    };
    final route = from != null && to != null
        ? '${accountName(from)} → ${accountName(to)}'
        : accountName(from ?? to);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canVoid ? () => _void(context, ref) : null,
        child: Opacity(
          opacity: voided ? 0.45 : 1,
          child: PixelFrame(
            style: PixelFrameStyle.panel,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                PixelSpriteView(
                  shown == null ? PixelBankIcons.vault : accountIcon(shown),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voided ? '${txn.title}（已作廢）' : txn.title,
                        style: text.bodyMedium,
                      ),
                      Text(
                        [route, if (txn.note.isNotEmpty) txn.note].join('・'),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (signed == null)
                  Text(formatNtd(txn.amount), style: text.bodyMedium)
                else
                  NtdText(signed, style: text.bodyMedium, sign: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
