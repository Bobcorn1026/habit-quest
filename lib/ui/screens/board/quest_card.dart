import 'package:flutter/material.dart';

import '../../../app/board.dart';
import '../../../domain/check_in.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';

/// A build-habit quest on parchment.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.entry,
    required this.onReport,
    required this.onUndo,
    required this.onOffer,
  });

  final BoardEntry entry;
  final VoidCallback onReport;
  final VoidCallback onUndo;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final quest = entry.active.quest;
    final habit = entry.habit;
    const ink = PixelPalette.leather;
    final goal = habit.hasAmount
        ? '${habit.name} ${formatAmount(quest.target ?? habit.target!)} ${habit.unit ?? ''}'
        : habit.name;
    final schedule = habit.isDaily ? '每日' : '每週 ${habit.timesPerWeek} 次';

    return PixelFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelSpriteView(PixelArt.byId(quest.spriteId)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RankBadge(quest.rank),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quest.title,
                            style: text.titleLarge?.copyWith(
                              color: PixelPalette.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (quest.subtitle.isNotEmpty)
                      Text(
                        quest.subtitle,
                        style: text.bodyMedium?.copyWith(
                          color: PixelPalette.parchmentDark,
                        ),
                      ),
                    Text(
                      '${entry.active.attribute.label}・$schedule・$goal',
                      style: text.bodySmall?.copyWith(color: ink),
                    ),
                    if (entry.anchorLabel case final anchor?)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '接在『$anchor』之後',
                                style: text.bodySmall?.copyWith(color: ink),
                              ),
                            ),
                            if (entry.nextStep) ...[
                              const SizedBox(width: 6),
                              PixelFrame(
                                style: PixelFrameStyle.panel,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  '下一步',
                                  style: text.bodySmall?.copyWith(
                                    color: PixelPalette.goldLight,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (entry.cursed) ...[
            const SizedBox(height: 8),
            CurseBanner(entry: entry),
          ],
          if (entry.offer != null) ...[
            const SizedBox(height: 8),
            _OfferBanner(onTap: onOffer),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StreakLabel(entry: entry, ink: ink),
              ),
              if (entry.reportedToday)
                _Reported(entry: entry, onUndo: onUndo)
              else
                PixelButton(onPressed: onReport, child: const Text('完成')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Reported extends StatelessWidget {
  const _Reported({required this.entry, required this.onUndo});

  final BoardEntry entry;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = entry.today!;
    final partial = c.outcome == CheckInOutcome.partial;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              partial ? '部分達成' : '已完成',
              style: text.bodyMedium?.copyWith(
                color: partial
                    ? PixelPalette.goldDark
                    : PixelPalette.greenShade,
              ),
            ),
            Text(
              '+${c.xp} EXP',
              style: text.bodySmall?.copyWith(color: PixelPalette.leather),
            ),
          ],
        ),
        const SizedBox(width: 8),
        PixelButton(
          tone: PixelButtonTone.parchment,
          onPressed: onUndo,
          child: const Text('撤回'),
        ),
      ],
    );
  }
}

/// Today's curse after an edit: do it fully or lose XP tomorrow.
class CurseBanner extends StatelessWidget {
  const CurseBanner({super.key, required this.entry});

  final BoardEntry entry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lifted = entry.curseLifted;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: Row(
        children: [
          PixelSpriteView(lifted ? PixelIcons.star : PixelIcons.skull),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lifted
                  ? '詛咒解除了。'
                  : entry.isSeal
                  ? '詛咒：今天一定要守住封印，否則會失去經驗值。'
                  : '詛咒：今天一定要完整完成，否則會失去經驗值。',
              style: text.bodySmall?.copyWith(
                color: lifted ? PixelPalette.goldLight : PixelPalette.redLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      child: Row(
        children: [
          const PixelSpriteView(PixelIcons.scroll),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '晉階邀請',
              style: text.bodySmall?.copyWith(color: PixelPalette.goldLight),
            ),
          ),
          PixelButton(
            tone: PixelButtonTone.arcane,
            onPressed: onTap,
            child: const Text('查看'),
          ),
        ],
      ),
    );
  }
}

/// 「連續 5 天」 with wounded / broken states.
class StreakLabel extends StatelessWidget {
  const StreakLabel({super.key, required this.entry, required this.ink});

  final BoardEntry entry;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = entry.streak;
    final unit = s.slotDays == 7 ? '週' : '天';
    final (label, color) = s.wounded
        ? ('負傷中：今天別再錯過！', PixelPalette.red)
        : s.broken
        ? ('重新出發吧', ink)
        : s.length == 0
        ? ('今天是第一步', ink)
        : ('連續 ${s.length} $unit', ink);
    return Row(
      children: [
        PixelSpriteView(s.wounded ? PixelIcons.potion : PixelIcons.flame),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: text.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}
