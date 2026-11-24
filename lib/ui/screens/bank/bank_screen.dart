import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/providers.dart';
import '../../../data/database.dart';
import '../../../data/settings_repository.dart';
import '../../../domain/bank.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import 'bank_accounts_screen.dart';
import 'bank_config_sheet.dart';
import 'bank_format.dart';
import 'bank_forms.dart';
import 'bank_history_screen.dart';
import 'bank_setup.dart';
import 'meal_draw.dart';

/// The bank: the vault, today's meal money and the envelopes.
class BankScreen extends ConsumerStatefulWidget {
  const BankScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const BankScreen()));

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  bool _mealTipAsked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showMentorTip(context, ref, MentorTip.bank),
    );
  }

  Future<void> _claim(BankView view) async {
    final amount = await ref.read(bankServiceProvider).claimMeal(view.today);
    if (amount != null && mounted) await showMealDraw(context, amount);
  }

  Future<void> _claimMissed(BankView view) async {
    final bank = ref.read(bankServiceProvider);
    var total = 0;
    for (final day in view.missedDays) {
      total += await bank.claimMeal(day) ?? 0;
    }
    if (total > 0 && mounted) {
      await showMealDraw(
        context,
        total,
        title: '補領 ${view.missedDays.length} 天',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(bankViewProvider).value;
    if (view != null && view.opened && !_mealTipAsked) {
      _mealTipAsked = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showMentorTip(context, ref, MentorTip.meal),
      );
    }
    return PixelPage(
      title: '銀行',
      children: [
        if (view != null && !view.opened) const BankSetup(),
        if (view != null && view.opened) ..._opened(context, view),
      ],
    );
  }

  List<Widget> _opened(BuildContext context, BankView view) {
    final hidden = ref.watch(bankHiddenProvider).value ?? false;
    return [
      _VaultCard(view: view, hidden: hidden),
      const SizedBox(height: 8),
      _MealCard(
        view: view,
        onClaim: () => _claim(view),
        onClaimMissed: () => _claimMissed(view),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PixelButton(
            tone: PixelButtonTone.parchment,
            onPressed: () => MoneySheet.show(context, view),
            child: const Text('記支出'),
          ),
          PixelButton(
            tone: PixelButtonTone.parchment,
            onPressed: () => MoneySheet.show(context, view, income: true),
            child: const Text('記收入'),
          ),
          PixelButton(
            tone: PixelButtonTone.parchment,
            onPressed: () => TransferSheet.show(context, view),
            child: const Text('轉帳'),
          ),
          PixelButton(
            tone: PixelButtonTone.parchment,
            onPressed: () => ReconcileSheet.show(context, view),
            child: const Text('對帳'),
          ),
        ],
      ),
      if (view.inbox.isNotEmpty) ...[
        const PixelHeading('待分類', icon: PixelIcons.quill),
        Text(
          'Notion 來的帳，還不知道該算哪個帳戶。錢先記在中央銀行，選好就會搬過去。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        for (final txn in view.inbox)
          _InboxRow(txn: txn, onTap: () => FileSheet.show(context, view, txn)),
      ],
      PixelHeading(
        '帳戶',
        icon: PixelIcons.chest,
        trailing: PixelButton(
          tone: PixelButtonTone.quiet,
          onPressed: () => BankAccountsScreen.open(context),
          child: const Text('管理'),
        ),
      ),
      for (final account in view.envelopes)
        AccountRow(
          account: account,
          balance: view.balanceOf(account),
          onTap: () => BankHistoryScreen.open(context, account: account),
        ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: PixelButton(
              tone: PixelButtonTone.quiet,
              expand: true,
              onPressed: () => BankHistoryScreen.open(context),
              child: const Text('明細'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PixelButton(
              tone: PixelButtonTone.quiet,
              expand: true,
              onPressed: () => BankConfigSheet.show(context),
              child: const Text('每月設定'),
            ),
          ),
        ],
      ),
    ];
  }
}

class _VaultCard extends ConsumerWidget {
  const _VaultCard({required this.view, required this.hidden});

  final BankView view;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final held = [
      if (view.mealAhead > 0) '本月餐費 ${formatNtd(view.mealAhead)}',
      for (final r in view.reserves)
        if (r.amount > 0) '${r.name} ${formatNtd(r.amount)}',
    ];
    const cover = '＊＊＊＊';
    return PixelFrame(
      style: PixelFrameStyle.ornate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelBankIcons.vault),
              const SizedBox(width: 8),
              Expanded(child: Text('中央銀行', style: text.bodyLarge)),
              PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: () => ref
                    .read(settingsRepoProvider)
                    .write(SettingKeys.bankHidden, !hidden),
                child: Text(hidden ? '顯示' : '遮住'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (hidden)
            Text(cover, style: text.displaySmall)
          else
            NtdText(view.vault, style: text.displaySmall),
          if (!hidden && held.isNotEmpty)
            Text('其中預留：${held.join('・')}', style: text.bodySmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  icon: PixelBankIcons.pool,
                  label: '賭場獎池',
                  value: NtdText(view.pool, style: text.bodyMedium),
                ),
              ),
              Expanded(
                child: _Stat(
                  icon: PixelIcons.coin,
                  label: '戶頭總額',
                  value: hidden
                      ? Text(cover, style: text.bodyMedium)
                      : NtdText(view.total, style: text.bodyMedium),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final PixelSprite icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      PixelSpriteView(icon),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          value,
        ],
      ),
    ],
  );
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.view,
    required this.onClaim,
    required this.onClaimMissed,
  });

  final BankView view;
  final VoidCallback onClaim;
  final VoidCallback onClaimMissed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meal = view.byRole(AccountRole.meal);
    final today = view.todayMeal;
    final missed = view.missedDays;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelBankIcons.meal),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.claimedToday && today != null
                          ? '今天的餐費：${formatNtd(today)}'
                          : '今天的餐費',
                      style: text.bodyLarge,
                    ),
                    Row(
                      children: [
                        Text('餐費帳戶 ', style: text.bodySmall),
                        NtdText(view.balanceOf(meal), style: text.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              if (today != null && !view.claimedToday)
                PixelButton(onPressed: onClaim, child: const Text('領今日餐費'))
              else if (today != null)
                Text('已領', style: text.bodySmall),
            ],
          ),
          if (missed.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('還有 ${missed.length} 天沒領', style: text.bodySmall),
                ),
                PixelButton(
                  tone: PixelButtonTone.quiet,
                  onPressed: onClaimMissed,
                  child: const Text('補領'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// An envelope with its icon and balance.
/// A row from Notion waiting for an account.
class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.txn, required this.onTap});

  final BankTxnRow txn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final income = txn.kind == TxnKind.income;
    final day = txn.day;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: PixelFrame(
          style: PixelFrameStyle.panel,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.title, style: text.bodyMedium),
                    Text(
                      '${day.month}/${day.day}'
                      '${txn.category == null ? '' : '・${txn.category}'}',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${income ? '+' : '-'}${formatNtd(txn.amount)}',
                style: text.bodyMedium,
              ),
              const SizedBox(width: 8),
              Text('選帳戶 ›', style: text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.account,
    required this.balance,
    this.onTap,
    this.trailing,
  });

  final BankAccountRow account;
  final int balance;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: PixelFrame(
          style: PixelFrameStyle.panel,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              PixelSpriteView(accountIcon(account)),
              const SizedBox(width: 10),
              Expanded(child: Text(account.name, style: text.bodyMedium)),
              NtdText(balance, style: text.bodyMedium),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
