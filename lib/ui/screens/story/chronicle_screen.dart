import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/chapter_service.dart';
import '../../../app/providers.dart';
import '../../../domain/chapter.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import 'chapter_banner.dart';
import 'chapter_reader.dart';

/// Every chapter so far, newest first.
class ChronicleScreen extends ConsumerWidget {
  const ChronicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];
    final due = ref.watch(chapterDueProvider);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const PixelHeading('冒險日誌', icon: PixelIcons.book),
        if (due != null) const ChapterBanner(),
        if (chapters.isEmpty)
          const PixelFrame(
            style: PixelFrameStyle.panel,
            child: Text('故事還沒開始。'),
          ),
        for (final c in chapters.where(
          (c) => c.status == ChapterStatus.written,
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => ChapterReader.open(context, c.id),
              child: PixelFrame(
                child: Row(
                  children: [
                    PixelSpriteView(
                      c.awaitsChoice ? PixelIcons.sword : PixelIcons.scroll,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapterHeading(c),
                            style: text.bodyMedium?.copyWith(
                              color: PixelPalette.outline,
                            ),
                          ),
                          Text(
                            [
                              if (c.judgement != null)
                                '判定：${c.judgement!.label}',
                              if (c.awaitsChoice) '等待你的抉擇',
                              if (c.chosen != null) '選擇：${c.chosen!.label}',
                            ].join('・'),
                            style: text.bodySmall?.copyWith(
                              color: c.awaitsChoice
                                  ? PixelPalette.redShade
                                  : PixelPalette.leather,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
