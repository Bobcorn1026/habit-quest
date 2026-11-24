import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/chapter.dart';
import '../../../game/judgement.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';

String chapterHeading(Chapter c) =>
    c.number == 0 ? '序章・${c.title}' : '第 ${c.number} 章・${c.title}';

/// Reads one chapter and, when it ends in choices, records the pick.
class ChapterReader extends ConsumerWidget {
  const ChapterReader({super.key, required this.chapterId});

  final int chapterId;

  static Future<void> open(BuildContext context, int chapterId) =>
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChapterReader(chapterId: chapterId)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref
        .watch(chaptersProvider)
        .value
        ?.where((c) => c.id == chapterId)
        .firstOrNull;
    final pixelFont = ref.watch(storyPixelFontProvider).value ?? true;
    if (chapter == null) return const PixelPage(title: '', children: []);
    final text = Theme.of(context).textTheme;
    final bodyStyle = pixelFont
        ? text.bodyMedium?.copyWith(color: PixelPalette.leather, height: 1.7)
        : text.bodyMedium?.copyWith(
            fontFamily: '.SF UI Text',
            fontFamilyFallback: const ['PingFang TC'],
            color: PixelPalette.leather,
            height: 1.7,
          );
    final p = chapter.period;

    return PixelPage(
      title: chapterHeading(chapter),
      children: [
        if (chapter.judgement != null)
          PixelFrame(
            style: PixelFrameStyle.ornate,
            child: Row(
              children: [
                const PixelSpriteView(PixelArt.d20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '判定：${chapter.judgement!.label}',
                        style: text.titleLarge?.copyWith(
                          color: _judgementColor(chapter.judgement!),
                        ),
                      ),
                      Text(
                        '${p.start.month}/${p.start.day}～${p.last.month}/${p.last.day}'
                        '・表現 ${((chapter.score ?? 0) * 100).round()}%',
                        style: text.bodySmall,
                      ),
                      for (final c in chapter.checks)
                        Text(
                          c.line,
                          style: text.bodySmall?.copyWith(
                            color: c.result.passed
                                ? PixelPalette.goldLight
                                : PixelPalette.redLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        PixelFrame(
          child: Text(
            chapter.status == ChapterStatus.pending
                ? '（這一章還在撰寫中）'
                : chapter.body,
            style: bodyStyle,
          ),
        ),
        if (chapter.sideQuest case final side?) ...[
          const PixelHeading('支線委託', icon: PixelIcons.scroll),
          PixelFrame(
            style: PixelFrameStyle.panel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(side.title, style: text.titleLarge),
                if (side.story.isNotEmpty)
                  Text(side.story, style: text.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '下一段期間內：${side.goal(null)}',
                  style: text.bodySmall?.copyWith(
                    color: PixelPalette.tealLight,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (chapter.choices.isNotEmpty) ...[
          PixelHeading(
            chapter.chosenIndex == null ? '你的抉擇是？' : '你的抉擇',
            icon: PixelIcons.sword,
          ),
          for (final (i, choice) in chapter.choices.indexed)
            _ChoiceButton(
              choice: choice,
              chosen: chapter.chosenIndex == i,
              locked: chapter.chosenIndex != null,
              onTap: () async {
                await ref.read(storyRepoProvider).choose(chapter.id, i);
                if (context.mounted) {
                  showPixelToast(context, '命運的齒輪開始轉動……', icon: PixelIcons.d20);
                }
              },
            ),
          if (chapter.chosenIndex != null)
            Text('下一章會從這個選擇接續，加持在下一段期間生效。', style: text.bodySmall)
          else
            Text('選了之後，那個加持會在下一段期間生效。', style: text.bodySmall),
        ],
      ],
    );
  }

  static Color _judgementColor(Judgement j) => switch (j) {
    Judgement.triumph => PixelPalette.goldLight,
    Judgement.success => PixelPalette.green,
    Judgement.struggle => PixelPalette.parchmentShade,
    Judgement.setback => PixelPalette.red,
  };
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.choice,
    required this.chosen,
    required this.locked,
    required this.onTap,
  });

  final StoryChoice choice;
  final bool chosen;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final label = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(choice.label),
        if (choice.hint.isNotEmpty)
          Text(
            choice.hint,
            style: text.bodySmall?.copyWith(
              color: chosen
                  ? PixelPalette.goldDark
                  : PixelPalette.parchmentShade,
            ),
          ),
        if (choice.blessing case final b?)
          Text(
            '加持：${b.label}',
            style: text.bodySmall?.copyWith(
              color: chosen ? PixelPalette.outline : PixelPalette.tealLight,
            ),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: locked && !chosen ? 0.45 : 1,
        child: PixelButton(
          expand: true,
          tone: chosen ? PixelButtonTone.gold : PixelButtonTone.quiet,
          onPressed: locked ? null : onTap,
          child: Align(alignment: Alignment.centerLeft, child: label),
        ),
      ),
    );
  }
}
