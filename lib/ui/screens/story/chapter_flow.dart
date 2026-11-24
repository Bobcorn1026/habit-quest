import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../ai/template_writer.dart';
import '../../../app/ai_runner.dart';
import '../../../app/chapter_service.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import 'chapter_reader.dart';

/// Writes the due chapter with the configured AI and opens it.
Future<void> writeDueChapter(BuildContext context, WidgetRef ref) async {
  final service = ref.read(chapterServiceProvider);
  final plan = await service.due();
  if (plan == null || !context.mounted) return;
  final request = await service.buildRequest(plan);
  final pending = await service.ensurePending(plan, request);
  if (!context.mounted) return;

  final result = await runAiTask<ChapterResult>(
    context,
    ref,
    title: plan.number == 0 ? '撰寫序章' : '撰寫第 ${plan.number} 章',
    prompt: PromptBuilder.chapter(request),
    parse: (raw) => parseChapter(raw, request),
    template: () => TemplateWriter.chapter(request),
  );
  if (result == null) return;
  final bonus = await service.apply(pending, result);
  if (!context.mounted) return;
  if (bonus > 0) {
    showPixelToast(context, '品質獎勵 +$bonus EXP', icon: PixelIcons.crown);
  }
  await ChapterReader.open(context, pending.id);
}
