import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../ai/template_writer.dart';
import '../../../app/ai_runner.dart';
import '../../../app/providers.dart';
import '../../../app/records.dart';
import '../../pixel/pixel.dart';
import '../../widgets/celebration.dart';
import '../../widgets/pixel_controls.dart';

/// The guild reads the whole adventure record and grants a title.
abstract final class TitleAppraisal {
  static Future<void> start(BuildContext context, WidgetRef ref) async {
    final record = await loadRecord(ref);
    final hero = await ref.read(adventurerRepoProvider).get();
    if (record == null || hero == null || !context.mounted) return;
    final request = TitleRequest(
      requestId: newRequestId(),
      config: await ref.read(settingsRepoProvider).storyConfig(),
      record: record.toJson(),
      currentTitle: hero.title,
    );
    if (!context.mounted) return;
    final result = await runAiTask<TitleResult>(
      context,
      ref,
      title: '稱號鑑定',
      prompt: PromptBuilder.title(request),
      parse: (raw) => parseTitle(raw, request),
      template: () => TemplateWriter.title(request),
    );
    if (result == null || !context.mounted) return;
    final ok = await showPixelDialog<bool>(
      context,
      builder: (ctx) {
        final text = Theme.of(ctx).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const PixelSpriteView(PixelArt.crown),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('「${result.title}」', style: text.titleLarge),
                ),
              ],
            ),
            if (result.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(result.reason, style: text.bodyMedium),
            ],
            if (hero.title != null) ...[
              const SizedBox(height: 8),
              Text('會取代目前的稱號「${hero.title}」。', style: text.bodySmall),
            ],
            const SizedBox(height: 16),
            PixelButton(
              expand: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('接受稱號'),
            ),
            const SizedBox(height: 8),
            PixelButton(
              expand: true,
              tone: PixelButtonTone.quiet,
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('不用了'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await ref
        .read(adventurerRepoProvider)
        .updateClassAndTitle(hero.id, title: result.title);
    if (context.mounted) {
      await showCelebration(
        context,
        title: '獲得稱號',
        detail: '「${result.title}」',
        lines: [
          if (result.reason.isNotEmpty) result.reason,
          '從今天起，公會的人都會這樣稱呼你了！',
        ],
      );
    }
  }
}
