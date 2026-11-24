import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bank_service.dart';
import '../../../data/database.dart';
import '../../../domain/bank.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import 'bank_screen.dart';

/// Adding, renaming and archiving envelopes.
class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const BankAccountsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final view = ref.watch(bankViewProvider).value;
    if (view == null) return const PixelPage(title: '管理帳戶', children: []);
    return PixelPage(
      title: '管理帳戶',
      children: [
        Text('子帳戶的錢靠賭場贏（餐費每天領）。空的帳戶才能封存；通用、餐費、投資不能封存。', style: text.bodySmall),
        const SizedBox(height: 10),
        for (final account in view.envelopes)
          AccountRow(
            account: account,
            balance: view.balanceOf(account),
            trailing: PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: () => EnvelopeSheet.show(context, account: account),
              child: const Text('編輯'),
            ),
          ),
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          tone: PixelButtonTone.parchment,
          onPressed: () => EnvelopeSheet.show(context),
          child: const Text('新增帳戶'),
        ),
        if (view.archived.isNotEmpty) ...[
          const PixelHeading('已封存', icon: PixelIcons.chest),
          for (final account in view.archived)
            AccountRow(
              account: account,
              balance: view.balanceOf(account),
              trailing: PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: () =>
                    ref.read(bankServiceProvider).unarchive(account.id),
                child: const Text('恢復'),
              ),
            ),
        ],
      ],
    );
  }
}

/// Names a new envelope, or renames one, and picks its icon.
class EnvelopeSheet extends ConsumerStatefulWidget {
  const EnvelopeSheet({super.key, this.account});

  final BankAccountRow? account;

  static Future<void> show(BuildContext context, {BankAccountRow? account}) =>
      showPixelSheet<void>(
        context,
        builder: (_) => EnvelopeSheet(account: account),
      );

  @override
  ConsumerState<EnvelopeSheet> createState() => _EnvelopeSheetState();
}

class _EnvelopeSheetState extends ConsumerState<EnvelopeSheet> {
  late final _name = TextEditingController(text: widget.account?.name);
  late String _icon = widget.account?.icon ?? 'general';

  static final _icons = [
    for (final id in PixelBankIcons.all.keys)
      if (id != 'vault' && id != 'pool') id,
  ];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final bank = ref.read(bankServiceProvider);
    final account = widget.account;
    if (account == null) {
      await bank.addEnvelope(name: name, icon: _icon);
    } else {
      await bank.editEnvelope(account.id, name: name, icon: _icon);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _archive() async {
    final result = await ref
        .read(bankServiceProvider)
        .archive(widget.account!.id);
    if (!mounted) return;
    showPixelToast(
      context,
      switch (result) {
        ArchiveResult.done => '封存了「${widget.account!.name}」',
        ArchiveResult.notEmpty => '帳戶裡還有錢（或欠款），先轉走或記平再封存',
        ArchiveResult.kept => '這個帳戶不能封存',
      },
      icon: result == ArchiveResult.done ? PixelIcons.chest : PixelIcons.skull,
    );
    if (result == ArchiveResult.done) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final account = widget.account;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(account == null ? '新增帳戶' : '編輯帳戶', style: text.titleLarge),
        const SizedBox(height: 12),
        PixelTextField(
          controller: _name,
          hint: '帳戶名稱',
          autofocus: account == null,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final id in _icons)
              GestureDetector(
                onTap: () => setState(() => _icon = id),
                child: PixelFrame(
                  style: id == _icon
                      ? PixelFrameStyle.ornate
                      : PixelFrameStyle.panel,
                  padding: const EdgeInsets.all(6),
                  child: PixelSpriteView(PixelBankIcons.byId(id)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: _name.text.trim().isEmpty ? null : _save,
          child: const Text('儲存'),
        ),
        if (account != null && !kKeptRoles.contains(account.role)) ...[
          const SizedBox(height: 8),
          PixelButton(
            expand: true,
            tone: PixelButtonTone.danger,
            onPressed: _archive,
            child: const Text('封存'),
          ),
        ],
      ],
    );
  }
}
