import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../app/notion_sync.dart';
import '../../../data/database.dart';
import '../../../core/logical_day.dart';
import '../../../domain/bank.dart';
import '../../../notion/ledger.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import '../../widgets/pixel_pickers.dart';
import 'bank_format.dart';

/// Picks one of [accounts] by id.
class AccountPicker extends StatelessWidget {
  const AccountPicker({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  final List<BankAccountRow> accounts;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => PixelSegments<int>(
    values: [for (final a in accounts) a.id],
    selected: selected,
    label: (id) => accountName(accounts.firstWhere((a) => a.id == id)),
    onChanged: onChanged,
  );
}

Widget _label(BuildContext context, String text) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 6),
  child: Text(text, style: Theme.of(context).textTheme.bodySmall),
);

/// Money spent outside, or ([income]) money from outside.
class MoneySheet extends ConsumerStatefulWidget {
  const MoneySheet({super.key, required this.view, required this.income});

  final BankView view;
  final bool income;

  static Future<void> show(
    BuildContext context,
    BankView view, {
    bool income = false,
  }) => showPixelSheet<void>(
    context,
    builder: (_) => MoneySheet(view: view, income: income),
  );

  @override
  ConsumerState<MoneySheet> createState() => _MoneySheetState();
}

class _MoneySheetState extends ConsumerState<MoneySheet> {
  final _amount = TextEditingController();
  final _title = TextEditingController();
  late int _account =
      (widget.income
              ? widget.view.byRole(AccountRole.central)
              : widget.view.byRole(AccountRole.meal) ??
                    widget.view.byRole(AccountRole.central))!
          .id;
  int _daysAgo = 0;
  String? _reserve;

  /// Picked by hand; until then it follows the account.
  String? _category;

  String get _shownCategory =>
      _category ??
      defaultCategory(
        income: widget.income,
        account: _fromVault
            ? kVaultName
            : _accounts.firstWhere((a) => a.id == _account).name,
      );

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  List<BankAccountRow> get _accounts => [
    ?widget.view.byRole(AccountRole.central),
    ...widget.view.envelopes,
  ];

  bool get _fromVault =>
      _account == widget.view.byRole(AccountRole.central)?.id;

  LogicalDay get _pickedDay => widget.view.today.addDays(-_daysAgo);

  /// Any day within the past year, for entering a receipt found late.
  Future<void> _pickDay() async {
    final today = widget.view.today;
    final day = await pickDay(
      context,
      title: '這筆帳的日期',
      initial: _pickedDay,
      first: today.addDays(-365),
      last: today,
    );
    if (day == null || !mounted) return;
    setState(() => _daysAgo = today.differenceInDays(day));
  }

  Future<void> _save() async {
    final amount = parseNtd(_amount.text);
    if (amount == null || amount <= 0) return;
    final bank = ref.read(bankServiceProvider);
    final day = widget.view.today.addDays(-_daysAgo);
    final reserve = !widget.income && _fromVault ? _reserve : null;
    final linked = ref.read(notionLinkProvider).value?.linked ?? false;
    final category = linked ? _shownCategory : null;
    final title = _title.text.trim().isNotEmpty
        ? _title.text.trim()
        : reserve != null
        ? widget.view.reserves.firstWhere((r) => r.id == reserve).name
        : widget.income
        ? '收入'
        : '支出';
    if (widget.income) {
      await bank.earn(
        accountId: _account,
        amount: amount,
        title: title,
        day: day,
        category: category,
      );
    } else {
      await bank.spend(
        accountId: _account,
        amount: amount,
        title: title,
        day: day,
        fixedId: reserve,
        category: category,
      );
    }
    if (linked) syncNotionSoon(ref);
    if (!mounted) return;
    showPixelToast(
      context,
      '記下了：$title ${widget.income ? '+' : '-'}${formatNtd(amount)}',
      icon: PixelIcons.quill,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final amount = parseNtd(_amount.text);
    final reserves = widget.view.reserves;
    final linked = ref.watch(notionLinkProvider).value?.linked ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.income ? '記收入' : '記支出', style: text.titleLarge),
        _label(context, '金額（元）'),
        PixelTextField(
          controller: _amount,
          hint: '例如 120',
          autofocus: true,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        _label(context, widget.income ? '放進' : '從哪個帳戶'),
        AccountPicker(
          accounts: _accounts,
          selected: _account,
          onChanged: (id) => setState(() => _account = id),
        ),
        if (!widget.income && _fromVault && reserves.isNotEmpty) ...[
          _label(context, '用預留的錢付？'),
          PixelSegments<String?>(
            values: [null, for (final r in reserves) r.id],
            selected: _reserve,
            label: (id) => id == null
                ? '一般支出'
                : '${reserves.firstWhere((r) => r.id == id).name}預留',
            onChanged: (id) => setState(() => _reserve = id),
          ),
        ],
        if (linked) ...[
          _label(context, '分類（寫進 Notion）'),
          PixelSegments<String>(
            values: widget.income ? kIncomeCategories : kExpenseCategories,
            selected: _shownCategory,
            label: (c) => c,
            onChanged: (c) => setState(() => _category = c),
          ),
        ],
        _label(context, '項目'),
        PixelTextField(
          controller: _title,
          hint: widget.income ? '例如 紅包' : '例如 午餐',
          textInputAction: TextInputAction.done,
        ),
        _label(context, '日期'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, name) in const ['今天', '昨天', '前天'].indexed)
              PixelButton(
                tone: _daysAgo == i
                    ? PixelButtonTone.gold
                    : PixelButtonTone.quiet,
                onPressed: () => setState(() => _daysAgo = i),
                child: Text(name),
              ),
            PixelButton(
              tone: _daysAgo > 2 ? PixelButtonTone.gold : PixelButtonTone.quiet,
              onPressed: _pickDay,
              child: Text(
                _daysAgo > 2 ? '${_pickedDay.month}/${_pickedDay.day}' : '其他日期',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: amount == null || amount <= 0 ? null : _save,
          child: const Text('記下'),
        ),
      ],
    );
  }
}

/// Moves money between envelopes, for a fee that goes to the pool.
class TransferSheet extends ConsumerStatefulWidget {
  const TransferSheet({super.key, required this.view});

  final BankView view;

  static Future<void> show(BuildContext context, BankView view) =>
      showPixelSheet<void>(context, builder: (_) => TransferSheet(view: view));

  @override
  ConsumerState<TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<TransferSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late int _from = _sources.first.id;
  late int _to = _targets.first.id;

  List<BankAccountRow> get _sources => [
    for (final a in widget.view.envelopes)
      if (a.role != AccountRole.meal) a,
  ];

  List<BankAccountRow> get _targets => [
    for (final a in widget.view.envelopes)
      if (a.id != _from) a,
  ];

  BankAccountRow get _source => _sources.firstWhere((a) => a.id == _from);

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseNtd(_amount.text);
    if (amount == null) return;
    final result = await ref
        .read(bankServiceProvider)
        .transfer(
          fromId: _from,
          toId: _to,
          amount: amount,
          note: _note.text.trim(),
        );
    if (!mounted) return;
    showPixelToast(
      context,
      switch (result) {
        TransferResult.done => '轉好了',
        TransferResult.notEnough => '這個帳戶沒有那麼多錢',
        TransferResult.tooSmall => '金額太小，扣掉手續費就沒了',
        TransferResult.notAllowed => '這兩個帳戶之間不能轉',
      },
      icon: result == TransferResult.done ? PixelIcons.coin : PixelIcons.skull,
    );
    if (result == TransferResult.done) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final amount = parseNtd(_amount.text);
    final fee = amount == null
        ? null
        : ref.read(bankServiceProvider).feeFor(_source, amount);
    final balance = widget.view.balanceOf(_source);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('轉帳', style: text.titleLarge),
        Text('從「通用」轉出免手續費，其他帳戶收 10%（進獎池）。餐費不能轉出。', style: text.bodySmall),
        _label(context, '從（現有 ${formatNtd(balance)} 元）'),
        AccountPicker(
          accounts: _sources,
          selected: _from,
          onChanged: (id) => setState(() {
            _from = id;
            if (_to == id) _to = _targets.first.id;
          }),
        ),
        _label(context, '到'),
        AccountPicker(
          accounts: _targets,
          selected: _to,
          onChanged: (id) => setState(() => _to = id),
        ),
        _label(context, '金額（元）'),
        PixelTextField(
          controller: _amount,
          hint: '例如 100',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        if (amount != null && amount > 0 && fee != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              fee == 0
                  ? '免手續費，到帳 ${formatNtd(amount)} 元'
                  : '手續費 ${formatNtd(fee)} 元，到帳 ${formatNtd(amount - fee)} 元',
              style: text.bodySmall?.copyWith(
                color: amount > balance ? PixelPalette.redLight : null,
              ),
            ),
          ),
        _label(context, '備註（選填）'),
        PixelTextField(
          controller: _note,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: amount == null || amount <= 0 ? null : _save,
          child: const Text('轉帳'),
        ),
      ],
    );
  }
}

/// Makes the bank match the real account: the difference goes in or out
/// of the vault.
class ReconcileSheet extends ConsumerStatefulWidget {
  const ReconcileSheet({super.key, required this.view});

  final BankView view;

  static Future<void> show(BuildContext context, BankView view) =>
      showPixelSheet<void>(context, builder: (_) => ReconcileSheet(view: view));

  @override
  ConsumerState<ReconcileSheet> createState() => _ReconcileSheetState();
}

class _ReconcileSheetState extends ConsumerState<ReconcileSheet> {
  final _actual = TextEditingController();

  @override
  void dispose() {
    _actual.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final actual = parseNtd(_actual.text);
    if (actual == null) return;
    final diff = await ref.read(bankServiceProvider).reconcile(actual);
    if (!mounted) return;
    showPixelToast(
      context,
      diff == 0
          ? '帳是對的，不用補'
          : '中央銀行補了 ${diff > 0 ? '+' : ''}${formatNtd(diff)}',
      icon: PixelIcons.scroll,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final actual = parseNtd(_actual.text);
    final diff = actual == null ? null : actual - widget.view.total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('對帳', style: text.titleLarge),
        Text(
          'app 裡的總額是 ${formatNtd(widget.view.total)} 元。輸入戶頭實際的餘額，差多少就在中央銀行補上或扣掉。',
          style: text.bodySmall,
        ),
        _label(context, '戶頭實際餘額（元）'),
        PixelTextField(
          controller: _actual,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          onChanged: (_) => setState(() {}),
        ),
        if (diff != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              diff == 0
                  ? '剛好對上'
                  : '中央銀行會${diff > 0 ? '補上' : '扣掉'} ${formatNtd(diff.abs())} 元',
              style: text.bodySmall,
            ),
          ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: actual == null ? null : _save,
          child: const Text('對帳'),
        ),
      ],
    );
  }
}

/// Files a row from Notion's inbox under an account.
class FileSheet extends ConsumerStatefulWidget {
  const FileSheet({super.key, required this.view, required this.txn});

  final BankView view;
  final BankTxnRow txn;

  static Future<void> show(
    BuildContext context,
    BankView view,
    BankTxnRow txn,
  ) => showPixelSheet<void>(
    context,
    builder: (_) => FileSheet(view: view, txn: txn),
  );

  @override
  ConsumerState<FileSheet> createState() => _FileSheetState();
}

class _FileSheetState extends ConsumerState<FileSheet> {
  int? _account;

  List<BankAccountRow> get _accounts => [
    ?widget.view.byRole(AccountRole.central),
    ...widget.view.envelopes,
  ];

  Future<void> _save(int account) async {
    final filed = await ref
        .read(bankServiceProvider)
        .file(widget.txn.id, account);
    if (filed) syncNotionSoon(ref);
    if (!mounted) return;
    if (filed) {
      showPixelToast(
        context,
        '放進${accountName(_accounts.firstWhere((a) => a.id == account))}了',
        icon: PixelIcons.quill,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final txn = widget.txn;
    final income = txn.kind == TxnKind.income;
    final account = _account;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(income ? '這筆收入放進哪裡？' : '這筆要算哪個帳戶？', style: text.titleLarge),
        const SizedBox(height: 8),
        Text(
          '${txn.title}  ${income ? '+' : '-'}${formatNtd(txn.amount)} 元'
          '${txn.category == null ? '' : '（${txn.category}）'}',
          style: text.bodyMedium,
        ),
        _label(context, '帳戶'),
        AccountPicker(
          accounts: _accounts,
          selected: account ?? -1,
          onChanged: (id) => setState(() => _account = id),
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: account == null ? null : () => _save(account),
          child: const Text('確定'),
        ),
      ],
    );
  }
}
