import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/chapter_service.dart';
import '../../../app/providers.dart';
import '../../pixel/pixel.dart';
import 'chapter_flow.dart';
import 'chapter_reader.dart';

/// Shown when a chapter is ready to be written or waits for a choice.
class ChapterBanner extends ConsumerStatefulWidget {
  const ChapterBanner({super.key});

  @override
  ConsumerState<ChapterBanner> createState() => _ChapterBannerState();
}

class _ChapterBannerState extends ConsumerState<ChapterBanner> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final due = ref.watch(chapterDueProvider);
    final latest = ref.watch(chaptersProvider).value?.firstOrNull;
    final config = ref.watch(storyConfigProvider).value;
    final text = Theme.of(context).textTheme;

    final String title;
    final String detail;
    final String action;
    final VoidCallback onTap;
    if (due != null) {
      title = due.number == 0 ? '序章等待揭曉' : '第 ${due.number} 章的命運等待揭曉';
      detail = config != null && due.isLong(config)
          ? '你離開了一段時間，這一章會記下這段漫長的旅程。'
          : due.pending != null
          ? '上次還沒寫完，繼續吧。'
          : '這段期間的冒險結束了，看看吟遊詩人怎麼說。';
      final auto = ref.watch(autoWritingProvider);
      action = _busy || auto ? '撰寫中…' : '揭曉命運';
      onTap = () async {
        if (auto) return;
        setState(() => _busy = true);
        try {
          await writeDueChapter(context, ref);
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      };
    } else if (latest != null && latest.awaitsChoice) {
      title = chapterHeading(latest);
      detail = '故事停在岔路口，等你做出抉擇。';
      action = '前往抉擇';
      onTap = () => ChapterReader.open(context, latest.id);
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PixelFrame(
        style: PixelFrameStyle.seal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const PixelSpriteView(PixelArt.book),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleLarge),
                      Text(detail, style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PixelButton(
              tone: PixelButtonTone.arcane,
              expand: true,
              onPressed: _busy ? null : onTap,
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
