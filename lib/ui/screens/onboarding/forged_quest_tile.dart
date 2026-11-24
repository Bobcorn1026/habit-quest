import 'package:flutter/material.dart';

import '../../../ai/ai_tasks.dart';
import '../../../domain/habit.dart';
import '../../pixel/pixel.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/quest_art.dart';

/// Preview of a freshly forged quest; tap to rename.
class ForgedQuestTile extends StatelessWidget {
  const ForgedQuestTile({
    super.key,
    required this.habit,
    required this.quest,
    required this.onEdited,
  });

  final ForgeHabit habit;
  final ForgedQuest quest;
  final ValueChanged<ForgedQuest> onEdited;

  Future<void> _edit(BuildContext context) async {
    final title = TextEditingController(text: quest.title);
    final subtitle = TextEditingController(text: quest.subtitle);
    final ok = await showPixelDialog<bool>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('修改任務', style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 10),
          PixelTextField(controller: title, hint: '任務名稱'),
          const SizedBox(height: 8),
          PixelTextField(controller: subtitle, hint: '副標題'),
          const SizedBox(height: 16),
          PixelButton(
            expand: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('確定'),
          ),
        ],
      ),
    );
    if (ok == true && title.text.trim().isNotEmpty) {
      onEdited(
        ForgedQuest(
          key: quest.key,
          rank: quest.rank,
          title: title.text.trim(),
          subtitle: subtitle.text.trim(),
          flavor: quest.flavor,
          spriteId: quest.spriteId,
          attribute: quest.attribute,
        ),
      );
    }
    title.dispose();
    subtitle.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final seal = habit.kind == HabitKind.quit;
    final ink = seal ? PixelPalette.parchmentLight : PixelPalette.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _edit(context),
        child: PixelFrame(
          style: seal ? PixelFrameStyle.seal : PixelFrameStyle.parchment,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestArt(
                spriteId: quest.spriteId,
                habitName: habit.name,
                seal: seal,
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
                          child: Text(
                            quest.title,
                            style: text.titleLarge?.copyWith(color: ink),
                          ),
                        ),
                      ],
                    ),
                    if (quest.subtitle.isNotEmpty)
                      Text(
                        quest.subtitle,
                        style: text.bodyMedium?.copyWith(
                          color: seal
                              ? PixelPalette.violetLight
                              : PixelPalette.parchmentDark,
                        ),
                      ),
                    Text(
                      '${seal ? '戒除' : '習慣'}：${habit.name}',
                      style: text.bodySmall?.copyWith(
                        color: seal
                            ? PixelPalette.parchmentShade
                            : PixelPalette.leather,
                      ),
                    ),
                    if (quest.flavor.isNotEmpty)
                      Text(
                        quest.flavor,
                        style: text.bodySmall?.copyWith(
                          color: seal
                              ? PixelPalette.parchmentShade
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
    );
  }
}
