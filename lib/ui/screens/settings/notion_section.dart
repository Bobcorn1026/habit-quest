import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/secret_store.dart';
import '../../../app/notion_sync.dart';
import '../../pixel/pixel.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import 'secret_key_field.dart';

String _when(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.month}/${t.day} ${two(t.hour)}:${two(t.minute)}';
}

/// The link between the bank and the Notion ledger.
class NotionSection extends ConsumerStatefulWidget {
  const NotionSection({super.key});

  @override
  ConsumerState<NotionSection> createState() => _NotionSectionState();
}

class _NotionSectionState extends ConsumerState<NotionSection> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(NotionSync sync) work) async {
    setState(() => _busy = true);
    try {
      await work(ref.read(notionSyncProvider));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() => _run((sync) async {
    final problem = await sync.start();
    if (!mounted) return;
    if (problem != null) {
      showPixelToast(context, problem.friendly, icon: PixelIcons.skull);
      return;
    }
    showPixelToast(context, '記帳本連上了', icon: PixelIcons.quill);
    await showMentorTip(context, ref, MentorTip.notion);
  });

  Future<void> _sync() => _run((sync) async {
    await sync.sync();
    final error = (await sync.link()).error;
    if (!mounted) return;
    showPixelToast(
      context,
      error ?? '同步好了',
      icon: error == null ? PixelIcons.quill : PixelIcons.skull,
    );
  });

  Future<void> _stop() async {
    final yes = await showPixelDialog<bool>(
      context,
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('解除連動？', style: text.titleLarge),
            const SizedBox(height: 8),
            Text(
              '已經同步的帳會留在銀行和 Notion。之後兩邊各記各的；'
              '再連一次的話，只會同步重新連動之後新記的帳。',
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
                    child: const Text('解除'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (yes == true) await ref.read(notionSyncProvider).stop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final link = ref.watch(notionLinkProvider).value ?? const NotionLink();
    final since = link.since;
    final lastSync = link.lastSync;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PixelHeading('Notion 記帳本', icon: PixelIcons.quill),
        Text(
          since == null
              ? '把銀行和 Notion 的「收支紀錄」連起來：在 Notion 記的帳會搬進銀行，'
                    '在這裡記的也會寫回 Notion。'
              : '${_when(since)} 起新記的帳，銀行和 Notion 會互相同步。'
                    '領餐費、中獎、轉帳這些銀行裡的搬錢不會寫進 Notion。',
          style: text.bodySmall,
        ),
        if (since != null) ...[
          const SizedBox(height: 6),
          Text(
            link.error != null
                ? '上次同步失敗：${link.error}'
                : lastSync == null
                ? '還沒同步過'
                : '上次同步：${_when(lastSync)}',
            style: text.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        const SecretKeyField(
          secretKey: SecretKeys.notion,
          hint: 'ntn_…',
          name: 'Notion 金鑰',
          saveLabel: '儲存金鑰',
        ),
        const SizedBox(height: 8),
        if (since == null) ...[
          Text(
            '金鑰怎麼拿：\n'
            '1. 到 Notion 的開發者頁面（app.notion.com/developers/connections）'
            '建立一個「內部連線」，複製它的金鑰。\n'
            '2. 在 Notion 打開「記帳」頁，按右上角「⋯」→「連線」，加入剛剛的連線。\n'
            '3. 把金鑰貼在上面按「儲存金鑰」，再按「開始連動」。',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          PixelButton(
            expand: true,
            onPressed: _busy ? null : _start,
            child: Text(_busy ? '連線中…' : '開始連動'),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  expand: true,
                  onPressed: _busy ? null : _sync,
                  child: Text(_busy ? '同步中…' : '立即同步'),
                ),
              ),
              const SizedBox(width: 8),
              PixelButton(
                tone: PixelButtonTone.danger,
                onPressed: _busy ? null : _stop,
                child: const Text('解除連動'),
              ),
            ],
          ),
      ],
    );
  }
}
