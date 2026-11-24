import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/progression.dart';
import '../../../core/logical_day.dart';
import '../../../domain/stat.dart';
import '../../../game/progression.dart';
import '../../pixel/pixel.dart';

PixelSprite statIcon(Stat s) => switch (s) {
  Stat.str => PixelIcons.sword,
  Stat.agi => PixelIcons.flame,
  Stat.vit => PixelIcons.potion,
  Stat.intel => PixelIcons.book,
  Stat.spi => PixelIcons.seal,
  Stat.cha => PixelIcons.crown,
  Stat.luk => PixelIcons.star,
};

/// The seven stats as bars; the class's stats glow gold.
class StatPanel extends StatelessWidget {
  const StatPanel({super.key, required this.progression});

  final ProgressionState progression;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final stats = progression.stats;
    final mine = progression.adventurer?.classInfo?.stats ?? const <Stat>[];
    final top = Stat.values.map((s) => stats[s]).reduce(math.max);
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final s in Stat.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  PixelSpriteView(statIcon(s)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '${s.label} ${s.code}',
                      style: text.bodySmall?.copyWith(
                        color: mine.contains(s)
                            ? PixelPalette.goldLight
                            : PixelPalette.parchmentLight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PixelBar(
                      value: top == 0 ? 0 : stats[s] / top,
                      tone: mine.contains(s)
                          ? PixelBarTone.exp
                          : s == Stat.luk
                          ? PixelBarTone.life
                          : PixelBarTone.streak,
                      height: 5,
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${stats[s]}',
                      textAlign: TextAlign.end,
                      style: text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '完成任務會提升它的屬性；幸運來自完美的一天（每日委託全部完成、封印全部守住），'
            '目前 ${progression.perfectDays} 天。',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// The class, its mastery, or when the appraisal opens.
class ClassPanel extends StatelessWidget {
  const ClassPanel({
    super.key,
    required this.progression,
    required this.today,
    required this.onAppraise,
  });

  final ProgressionState progression;
  final LogicalDay today;

  /// Opens the class appraisal (first class or a change).
  final VoidCallback onAppraise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cls = progression.adventurer?.classInfo;
    final rules = progression.rules;

    if (cls == null) {
      final open = progression.classAppraisalOpen;
      return PixelFrame(
        style: PixelFrameStyle.panel,
        child: Row(
          children: [
            const PixelSpriteView(PixelIcons.shield),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                open
                    ? '公會的就職鑑定開放了：依你的任務決定職業。'
                    : '就職鑑定在冒險第 ${rules.classAfterDays + 1} 天開放'
                          '（還有 ${progression.daysUntilAppraisal} 天）。',
                style: text.bodySmall,
              ),
            ),
            if (open) ...[
              const SizedBox(width: 8),
              PixelButton(onPressed: onAppraise, child: const Text('鑑定')),
            ],
          ],
        ),
      );
    }

    final m = progression.mastery!;
    final tier = m.tier;
    final xpBonus = ((rules.classXpBonus + tier * rules.masteryXpBonus) * 100)
        .round();
    final growth = 1 + rules.classStatBonus + tier * rules.masteryStatBonus;
    final roman = const ['', 'I', 'II', 'III', 'IV', 'V'][tier.clamp(0, 5)];
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(cls.name, style: text.titleLarge)),
              for (final s in cls.stats) ...[
                const SizedBox(width: 4),
                Text(
                  s.code,
                  style: text.bodySmall?.copyWith(
                    color: PixelPalette.goldLight,
                  ),
                ),
              ],
            ],
          ),
          if (cls.flavor.isNotEmpty) Text(cls.flavor, style: text.bodySmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(tier == 0 ? '專精：尚未入門' : '專精 $roman', style: text.bodyMedium),
              const SizedBox(width: 8),
              Expanded(
                child: PixelBar(
                  value: m.nextAt == null ? 1 : m.count / m.nextAt!,
                  height: 5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                m.nextAt == null ? '${m.count}' : '${m.count}/${m.nextAt}',
                style: text.bodySmall,
              ),
            ],
          ),
          Text(
            '${cls.stats.map((s) => s.label).join('、')}任務：'
            'EXP +$xpBonus%、屬性成長 ×${growth.toStringAsFixed(2)}',
            style: text.bodySmall,
          ),
          if (progression.canChangeClass(today)) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: onAppraise,
                child: const Text('轉職'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Guild rank, points toward the next trial, and the trial itself.
class GuildPanel extends StatelessWidget {
  const GuildPanel({
    super.key,
    required this.guild,
    required this.commissions,
    required this.limit,
    required this.onStartTrial,
  });

  final GuildProgress guild;

  /// Quests and seals held now, and how many the rank allows.
  final int commissions;
  final int limit;
  final VoidCallback onStartTrial;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final g = guild;
    final needed = g.needed;
    final status = switch (g.state) {
      TrialState.none when needed == null => '已是公會最高的 SSS 級冒險者。',
      TrialState.none => '累積 $needed 點就能挑戰晉升考驗。高 Rank 委託點數比較多。',
      TrialState.available => '晉升考驗開放了：連續 ${g.trialDays} 天完成全部每日委託、守住全部封印。',
      TrialState.running =>
        '晉升考驗中：${g.trialDaysDone} / ${g.trialDays} 天。今天也別漏掉任何委託！',
      TrialState.passed => '考驗通過！',
      TrialState.failed => '考驗失敗了……有一天沒能全部完成。準備好就再挑戰吧。',
    };
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('公會 Rank', style: text.bodyMedium),
              const SizedBox(width: 8),
              RankBadge(g.rank),
              if (needed != null) ...[
                const SizedBox(width: 6),
                Text('→', style: text.bodySmall),
                const SizedBox(width: 6),
                RankBadge(g.rank.next),
              ],
              const Spacer(),
              if (needed != null)
                Text(
                  '${math.min(g.points, needed)} / $needed 點',
                  style: text.bodySmall,
                ),
            ],
          ),
          if (needed != null) ...[
            const SizedBox(height: 6),
            PixelBar(value: g.progress, segments: 10, height: 5),
          ],
          const SizedBox(height: 6),
          Text(status, style: text.bodySmall),
          Text(
            '可同時接的委託：$commissions / $limit 件'
            '${needed == null ? '' : '（升上 ${g.rank.next.label} 可接 ${limit + 1} 件）'}',
            style: text.bodySmall?.copyWith(color: PixelPalette.goldLight),
          ),
          if (g.canStartTrial) ...[
            const SizedBox(height: 8),
            PixelButton(
              expand: true,
              tone: PixelButtonTone.arcane,
              onPressed: onStartTrial,
              child: Text(g.state == TrialState.failed ? '再次挑戰' : '接受晉升考驗'),
            ),
          ],
        ],
      ),
    );
  }
}
