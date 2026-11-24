import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../ai/template_writer.dart';
import '../../../app/adventure_service.dart';
import '../../../app/ai_runner.dart';
import '../../../app/board.dart';
import '../../../app/progression.dart';
import '../../../app/providers.dart';
import '../../../domain/hero_class.dart';
import '../../../game/progression.dart';
import '../../pixel/pixel.dart';
import '../../widgets/celebration.dart';
import '../../widgets/pixel_controls.dart';

/// The guild's class appraisal: the AI (or a template) reads what the
/// quests train and proposes a class; the player accepts or waits.
abstract final class ClassAppraisal {
  static Future<HeroClass?> start(BuildContext context, WidgetRef ref) async {
    final board = ref.read(boardProvider).value;
    final progression = ref.read(progressionProvider).value;
    final hero = board?.adventurer;
    if (board == null || progression == null || hero == null) return null;
    final changing = hero.hasClass;
    final checkIns = ref.read(recentCheckInsProvider).value ?? const [];
    final stats = progression.stats;
    final request = ClassRequest(
      requestId: newRequestId(),
      heroName: hero.name,
      identity: hero.identity,
      config: await ref.read(settingsRepoProvider).storyConfig(),
      world: await ref.read(adventureServiceProvider).world(),
      currentClass: changing ? hero.heroClass : null,
      level: board.level.level,
      stats: [for (final s in stats.ranked) (s, stats[s])],
      habits: [
        for (final e in board.entries)
          ClassHabit(
            questTitle: e.active.quest.title,
            habitName: e.habit.name,
            kind: e.habit.kind,
            attribute: e.active.attribute,
            finished: checkIns
                .where((c) => c.habitId == e.habit.id && counts(c))
                .length,
          ),
      ],
    );
    if (!context.mounted) return null;
    final result = await runAiTask<ClassResult>(
      context,
      ref,
      title: changing ? '轉職鑑定' : '就職鑑定',
      prompt: PromptBuilder.heroClass(request),
      parse: (raw) => parseClass(raw, request),
      template: () => TemplateWriter.heroClass(request),
    );
    if (result == null || !context.mounted) return null;
    final ok = await showPixelDialog<bool>(
      context,
      builder: (_) => _ClassOffer(result: result, changing: changing),
    );
    if (ok != true) return null;
    final taken = HeroClass(
      name: result.name,
      stats: result.stats,
      since: board.today,
      flavor: result.flavor,
    );
    await ref
        .read(adventurerRepoProvider)
        .setClass(hero.id, taken, portraitId: result.portraitId);
    if (context.mounted) {
      await showCelebration(
        context,
        title: '${changing ? '轉職' : '就職'}：${result.name}',
        detail: '主屬性：${result.stats.map((s) => s.label).join('・')}',
        lines: [
          if (result.ceremony.isNotEmpty) result.ceremony,
          '從今天起，${result.stats.map((s) => s.label).join('和')}的任務會讓你成長得更快。',
        ],
      );
    }
    return taken;
  }
}

class _ClassOffer extends StatelessWidget {
  const _ClassOffer({required this.result, required this.changing});

  final ClassResult result;
  final bool changing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            PixelSpriteView(
              PixelPortraits.forAdventurer(result.portraitId, result.name),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.name, style: text.titleLarge),
                  Text(
                    '主屬性：${result.stats.map((s) => '${s.label} ${s.code}').join('、')}',
                    style: text.bodySmall?.copyWith(
                      color: PixelPalette.goldLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (result.flavor.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(result.flavor, style: text.bodyMedium),
        ],
        if (result.ceremony.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(result.ceremony, style: text.bodySmall),
        ],
        const SizedBox(height: 8),
        Text(
          changing
              ? '轉職後，專精會從頭累積；能力值會照新職業的主屬性重新計算。'
              : '主屬性的任務會讓能力值長得更快，經驗值也會多一點。',
          style: text.bodySmall?.copyWith(
            color: changing ? PixelPalette.red : null,
          ),
        ),
        const SizedBox(height: 16),
        PixelButton(
          expand: true,
          onPressed: () => Navigator.pop(context, true),
          child: Text(changing ? '轉職' : '就職'),
        ),
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          tone: PixelButtonTone.quiet,
          onPressed: () => Navigator.pop(context, false),
          child: const Text('再想想'),
        ),
      ],
    );
  }
}
