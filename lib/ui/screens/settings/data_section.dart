import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/backup_files.dart';
import '../../../app/focus_service.dart';
import '../../../app/providers.dart';
import '../../../app/records.dart';
import '../../../app/reminders.dart';
import '../../../app/tuning_log.dart';
import '../../../data/backup.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';

/// Export and restore of the whole local database.
class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final text = await BackupService(ref.read(databaseProvider))
        .export(ref.read(clockProvider).now());
    final name = 'habit_quest-backup-${ref.read(todayProvider).toKey()}.json';
    try {
      final saved = await ref
          .read(backupFilesProvider)
          .save(name, text, origin: origin);
      if (saved && context.mounted) showPixelToast(context, '備份已匯出');
    } on PlatformException catch (e) {
      if (context.mounted) {
        showPixelToast(context, '匯出失敗：${e.message}', icon: PixelIcons.skull);
      }
    }
  }

  /// The adventure as a readable Markdown file, e.g. to hand to any AI.
  Future<void> _exportRecord(BuildContext context, WidgetRef ref) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final record = await loadRecord(ref);
    if (record == null) return;
    final name = 'habit_quest-record-${ref.read(todayProvider).toKey()}.md';
    try {
      final saved = await ref
          .read(backupFilesProvider)
          .save(name, record.toMarkdown(), origin: origin);
      if (saved && context.mounted) showPixelToast(context, '冒險紀錄已匯出');
    } on PlatformException catch (e) {
      if (context.mounted) {
        showPixelToast(context, '匯出失敗：${e.message}', icon: PixelIcons.skull);
      }
    }
  }

  /// The town's weekly numbers, for tuning prices and prizes with Claude.
  Future<void> _exportTuning(BuildContext context, WidgetRef ref) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final text = await exportTuningLog(
      ref.read(databaseProvider),
      rules: ref.read(gameRulesProvider),
      now: ref.read(clockProvider).now(),
    );
    final name = 'habit_quest-tuning-${ref.read(todayProvider).toKey()}.json';
    try {
      final saved = await ref
          .read(backupFilesProvider)
          .save(name, text, origin: origin);
      if (saved && context.mounted) showPixelToast(context, '數值紀錄已匯出');
    } on PlatformException catch (e) {
      if (context.mounted) {
        showPixelToast(context, '匯出失敗：${e.message}', icon: PixelIcons.skull);
      }
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final service = BackupService(ref.read(databaseProvider));
    final Backup backup;
    try {
      final text = await ref.read(backupFilesProvider).open();
      if (text == null) return;
      backup = service.inspect(text);
    } on BackupException catch (e) {
      if (context.mounted) {
        showPixelToast(context, e.message, icon: PixelIcons.skull);
      }
      return;
    } on Exception {
      if (context.mounted) {
        showPixelToast(context, '讀不到這個檔案。', icon: PixelIcons.skull);
      }
      return;
    }
    if (!context.mounted) return;
    final ok = await showPixelDialog<bool>(
      context,
      builder: (ctx) => _ConfirmRestore(backup: backup),
    );
    if (ok != true) return;
    await service.restore(backup);
    if (!context.mounted) return;
    showPixelToast(context, '已從備份還原');
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  /// Wipes everything but the Keychain, once the player has typed the words.
  Future<void> _startOver(BuildContext context, WidgetRef ref) async {
    final ok = await showPixelSheet<bool>(
      context,
      builder: (ctx) =>
          _ConfirmStartOver(onExport: (button) => _export(button, ref)),
    );
    if (ok != true) return;
    await BackupService(ref.read(databaseProvider)).wipe();
    // A resting break would still ring, and the focus controller keeps the
    // old session in memory.
    await ref.read(reminderSchedulerProvider).cancel(kBreakNotificationId);
    ref.invalidate(focusProvider);
    if (!context.mounted) return;
    showPixelToast(context, '已清除，從頭開始');
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PixelHeading('資料', icon: PixelIcons.chest),
        Text(
          '所有資料只存在這台裝置。定期匯出備份，換手機或重灌時就能還原。'
          'API key 不會放進備份。',
          style: text.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Builder(
                // Its own context, so the iPad share popover points here.
                builder: (button) => PixelButton(
                  expand: true,
                  onPressed: () => _export(button, ref),
                  child: const Text('匯出備份'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: () => _restore(context, ref),
                child: const Text('從備份還原'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (button) => PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => _exportRecord(button, ref),
            child: const Text('匯出冒險紀錄（可交給任何 AI 閱讀）'),
          ),
        ),
        const SizedBox(height: 8),
        Builder(
          builder: (button) => PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => _exportTuning(button, ref),
            child: const Text('匯出城鎮數值紀錄（給 Claude 調整數值）'),
          ),
        ),
        const SizedBox(height: 16),
        PixelButton(
          tone: PixelButtonTone.danger,
          expand: true,
          onPressed: () => _startOver(context, ref),
          child: const Text('從頭開始'),
        ),
      ],
    );
  }
}

/// Asks before wiping everything; the wipe button stays locked until the
/// player types [_words].
class _ConfirmStartOver extends StatefulWidget {
  const _ConfirmStartOver({required this.onExport});

  /// Exports a backup; given the button's context for the share popover.
  final Future<void> Function(BuildContext button) onExport;

  @override
  State<_ConfirmStartOver> createState() => _ConfirmStartOverState();
}

class _ConfirmStartOverState extends State<_ConfirmStartOver> {
  static const _words = '從頭開始';
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ready = _typed.text.trim() == _words;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PixelSpriteView(PixelArt.scroll),
            const SizedBox(width: 12),
            Expanded(child: Text('要從頭開始嗎？', style: text.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          '會清掉這台裝置上的所有資料：角色、習慣與打卡、故事、金幣、'
          '城鎮與銀行，還有所有設定，回到第一次打開的樣子。',
        ),
        const SizedBox(height: 8),
        Text(
          'API key（Claude、OpenAI、Notion）會留著。Notion 連動會解除，'
          'Notion 上的帳不會動。',
          style: text.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          '清掉就救不回來，除非你有匯出的備份。',
          style: text.bodySmall?.copyWith(color: PixelPalette.red),
        ),
        const SizedBox(height: 12),
        Builder(
          // Its own context, so the iPad share popover points here.
          builder: (button) => PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => widget.onExport(button),
            child: const Text('先匯出備份'),
          ),
        ),
        const SizedBox(height: 16),
        Text('確定的話，在下面輸入「$_words」：', style: text.bodySmall),
        const SizedBox(height: 8),
        PixelTextField(
          controller: _typed,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.danger,
                expand: true,
                onPressed: ready ? () => Navigator.of(context).pop(true) : null,
                child: const Text('全部清除'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmRestore extends StatelessWidget {
  const _ConfirmRestore({required this.backup});

  final Backup backup;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final when = backup.exportedAt;
    final counts = backup.counts;
    String two(int n) => n.toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PixelSpriteView(PixelArt.chest),
            const SizedBox(width: 12),
            Expanded(child: Text('從備份還原？', style: text.titleLarge)),
          ],
        ),
        const SizedBox(height: 12),
        if (when != null)
          Text(
            '備份時間：${when.year}/${two(when.month)}/${two(when.day)} '
            '${two(when.hour)}:${two(when.minute)}',
          ),
        Text(
          '習慣 ${counts['habits'] ?? 0} 個・打卡 ${counts['check_ins'] ?? 0} 筆・'
          '章節 ${counts['chapters'] ?? 0} 章',
        ),
        const SizedBox(height: 8),
        Text(
          '還原會取代這台裝置上目前的所有資料。API key 不在備份裡，還原後要重新輸入。',
          style: text.bodySmall?.copyWith(color: PixelPalette.red),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.danger,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('還原'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
