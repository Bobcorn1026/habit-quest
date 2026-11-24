import 'package:flutter/material.dart';

import '../../../domain/quest_rank.dart';
import '../../pixel/pixel.dart';
import '../../widgets/celebration.dart';
import '../../widgets/mentor.dart';
import '../../widgets/mentor_tips.dart';

/// Every pixel component on one scrolling page, for judging the style and
/// for golden tests.
class KitGallery extends StatelessWidget {
  const KitGallery({super.key});

  static const _story =
      '霧之圖書館的大門在你面前緩緩開啟。守門的老貓頭鷹瞇起眼睛：'
      '「七日之內，你破譯了五卷古代文字——雖然第三天你在卷軸上睡著了，'
      '口水差點毀掉一段咒語。」';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: PixelBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _HeroHeader(),
                  const _Section('任務卡'),
                  const _QuestCardSample(),
                  const SizedBox(height: 12),
                  const _SealCardSample(),
                  const _Section('按鈕'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tone in PixelButtonTone.values)
                        PixelButton(
                          tone: tone,
                          onPressed: () {},
                          child: Text(tone.name),
                        ),
                      const PixelButton(onPressed: null, child: Text('停用')),
                    ],
                  ),
                  const _Section('進度條'),
                  for (final (i, tone) in PixelBarTone.values.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PixelBar(
                        value: 0.2 + i * 0.17,
                        tone: tone,
                        segments: i.isEven ? 10 : 0,
                      ),
                    ),
                  const _Section('等級'),
                  Wrap(
                    spacing: 8,
                    children: [for (final r in QuestRank.values) RankBadge(r)],
                  ),
                  const _Section('圖示'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final icon in PixelIcons.all)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PixelSpriteView(icon),
                            Text(icon.id, style: text.labelSmall),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final art in PixelArt.all) PixelSpriteView(art),
                    ],
                  ),
                  const _Section('頭像與封印魔物'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final art in [
                        ...PixelPortraits.all,
                        ...PixelMonsters.all,
                      ])
                        PixelSpriteView(art),
                    ],
                  ),
                  const _Section('莉娜與 Q 版角色'),
                  Row(
                    children: [
                      const PixelSpriteView(PixelPortraits.mentor),
                      const SizedBox(width: 12),
                      for (final c in PixelChibis.all) ...[
                        PixelSpriteView(c),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      PixelButton(
                        tone: PixelButtonTone.arcane,
                        onPressed: () => showCelebration(
                          context,
                          title: '等級提升！',
                          detail: 'Lv.9 → Lv.10',
                          lines: const [
                            '恭喜！升到 Lv.10 了！',
                            '大家都跑來幫你慶祝了——今天也辛苦了！',
                          ],
                        ),
                        child: const Text('慶祝畫面'),
                      ),
                      const SizedBox(width: 8),
                      PixelButton(
                        tone: PixelButtonTone.quiet,
                        onPressed: () =>
                            showMentor(context, MentorTip.board.lines('勇者')),
                        child: const Text('莉娜說明'),
                      ),
                    ],
                  ),
                  const _Section('字級'),
                  Text('勇者日課', style: text.displaySmall),
                  Text('第三章：霧之圖書館', style: text.titleLarge),
                  Text('每日讀英文 20 分鐘，連續 5 天。', style: text.bodyMedium),
                  Text('小字：上次打卡 23:41', style: text.bodySmall),
                  const _Section('故事頁（像素字／系統字）'),
                  const PixelFrame(child: Text(_story)),
                  const SizedBox(height: 12),
                  PixelFrame(
                    child: Text(
                      _story,
                      style: text.bodyMedium?.copyWith(
                        fontFamily: '.SF UI Text',
                        fontFamilyFallback: const ['PingFang TC'],
                        color: PixelPalette.leather,
                      ),
                    ),
                  ),
                  const _Section('面板'),
                  const PixelFrame(
                    style: PixelFrameStyle.panel,
                    child: Text('暗色面板：放次要資訊，例如本週統計。'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Row(
        children: [
          const PixelSpriteView(PixelIcons.star),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.ornate,
      child: Row(
        children: [
          const PixelSpriteView(PixelArt.crown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('第三章：霧之圖書館', style: text.titleLarge),
                Text('Lv.7 見習賢者・亞倫', style: text.bodyMedium),
                const SizedBox(height: 6),
                const PixelBar(value: 0.68, segments: 10),
                const SizedBox(height: 4),
                Text('EXP 340 / 500', style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCardSample extends StatelessWidget {
  const _QuestCardSample();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const ink = PixelPalette.leather;
    return PixelFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PixelSpriteView(PixelArt.scroll),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const RankBadge(QuestRank.b),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '破譯古代卷軸',
                            style: text.titleLarge?.copyWith(
                              color: PixelPalette.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '～那些字母在對我低語～',
                      style: text.bodyMedium?.copyWith(
                        color: PixelPalette.parchmentDark,
                      ),
                    ),
                    Text(
                      '每日讀英文 20 分鐘',
                      style: text.bodySmall?.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const PixelSpriteView(PixelIcons.flame),
              const SizedBox(width: 4),
              Text('連續 5 天', style: text.bodySmall?.copyWith(color: ink)),
              const Spacer(),
              PixelButton(onPressed: () {}, child: const Text('完成')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SealCardSample extends StatelessWidget {
  const _SealCardSample();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.seal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelArt.seal),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('【封印】深夜手機魔', style: text.titleLarge),
                    Text('十一點後不滑手機', style: text.bodySmall),
                    const SizedBox(height: 6),
                    const PixelBar(
                      value: 0.6,
                      tone: PixelBarTone.seal,
                      segments: 12,
                    ),
                    const SizedBox(height: 4),
                    Text('封印第 12 天', style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PixelButton(
                tone: PixelButtonTone.danger,
                onPressed: () {},
                child: const Text('有裂痕'),
              ),
              const SizedBox(width: 8),
              PixelButton(
                tone: PixelButtonTone.arcane,
                onPressed: () {},
                child: const Text('守住了'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
