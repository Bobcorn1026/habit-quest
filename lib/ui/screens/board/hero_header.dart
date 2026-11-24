import 'package:flutter/material.dart';

import '../../../app/board.dart';
import '../../../domain/hero_class.dart';
import '../../pixel/pixel.dart';

/// Portrait, level and EXP at the top of the board.
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.state});

  final BoardState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hero = state.adventurer;
    final level = state.level;
    final chapter = state.latestChapter;
    final chapterLine = chapter == null
        ? '序章・尚未展開'
        : chapter.number == 0
        ? '序章・${chapter.title}'
        : '第${chapter.number}章・${chapter.title.isEmpty ? '撰寫中' : chapter.title}';
    return PixelFrame(
      style: PixelFrameStyle.ornate,
      child: Row(
        children: [
          PixelSpriteView(
            PixelPortraits.forAdventurer(hero?.portraitId, hero?.heroClass),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hero?.name ?? '無名的冒險者',
                        style: text.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const PixelSpriteView(PixelIcons.coin),
                    const SizedBox(width: 4),
                    Text('${state.gold}', style: text.bodyMedium),
                    const SizedBox(width: 8),
                    if (hero != null) RankBadge(hero.guildRank),
                  ],
                ),
                Text(
                  'Lv.${level.level}  ${hero?.heroClass ?? kNoviceClass}',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 6),
                PixelBar(value: level.progress, segments: 10),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'EXP ${level.xpIntoLevel} / ${level.xpForLevel}',
                      style: text.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chapterLine,
                        style: text.bodySmall,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
