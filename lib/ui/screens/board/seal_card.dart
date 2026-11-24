import 'package:flutter/material.dart';

import '../../../app/board.dart';
import '../../../domain/check_in.dart';
import '../../pixel/pixel.dart';
import '../../widgets/quest_art.dart';
import 'quest_card.dart';

/// A quit-habit seal: report each day whether it held.
class SealCard extends StatelessWidget {
  const SealCard({
    super.key,
    required this.entry,
    required this.sealMasteryDays,
    required this.onHold,
    required this.onCrack,
    required this.onUndo,
    required this.onOffer,
  });

  final BoardEntry entry;
  final int sealMasteryDays;
  final VoidCallback onHold;
  final VoidCallback onCrack;
  final VoidCallback onUndo;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final quest = entry.active.quest;
    final today = entry.today;
    final cracked = today?.outcome == CheckInOutcome.relapsed;
    final strength = (entry.streak.clean / sealMasteryDays).clamp(0.0, 1.0);

    return PixelFrame(
      style: PixelFrameStyle.seal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              QuestArt(
                spriteId: quest.spriteId,
                habitName: entry.habit.name,
                seal: true,
                cracked: cracked,
              ),
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
                          child: Text(quest.title, style: text.titleLarge),
                        ),
                      ],
                    ),
                    if (quest.subtitle.isNotEmpty)
                      Text(
                        quest.subtitle,
                        style: text.bodyMedium?.copyWith(
                          color: PixelPalette.violetLight,
                        ),
                      ),
                    Text('戒除：${entry.habit.name}', style: text.bodySmall),
                    const SizedBox(height: 6),
                    PixelBar(
                      value: strength,
                      tone: PixelBarTone.seal,
                      segments: 10,
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
            Align(
              alignment: Alignment.centerRight,
              child: PixelButton(
                tone: PixelButtonTone.gold,
                onPressed: onOffer,
                child: const Text('封印已穩固・查看'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StreakLabel(
                  entry: entry,
                  ink: PixelPalette.parchmentShade,
                ),
              ),
              if (today == null) ...[
                PixelButton(
                  tone: PixelButtonTone.danger,
                  onPressed: onCrack,
                  child: const Text('有裂痕'),
                ),
                const SizedBox(width: 8),
                PixelButton(
                  tone: PixelButtonTone.arcane,
                  onPressed: onHold,
                  child: const Text('守住了'),
                ),
              ] else ...[
                Text(
                  cracked ? '出現裂痕' : '+${today.xp} EXP',
                  style: text.bodySmall?.copyWith(
                    color: cracked
                        ? PixelPalette.red
                        : PixelPalette.violetLight,
                  ),
                ),
                const SizedBox(width: 8),
                PixelButton(
                  tone: PixelButtonTone.quiet,
                  onPressed: onUndo,
                  child: const Text('撤回'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
