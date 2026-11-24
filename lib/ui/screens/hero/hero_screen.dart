import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/ai_tasks.dart';
import '../../../ai/prompts.dart';
import '../../../ai/response_parser.dart';
import '../../../ai/template_writer.dart';
import '../../../app/adventure_service.dart';
import '../../../app/ai_runner.dart';
import '../../../app/board.dart';
import '../../../app/game_service.dart';
import '../../../app/progression.dart';
import '../../../app/providers.dart';
import '../../../core/logical_day.dart';
import '../../../domain/check_in.dart';
import '../../../domain/habit.dart';
import '../../../domain/quest_rank.dart';
import '../../../game/progression.dart';
import '../../pixel/pixel.dart';
import '../../widgets/habit_form.dart';
import '../../widgets/mentor.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_heatmap.dart';
import '../../widgets/title_frame.dart';
import '../settings/settings_screen.dart';
import 'class_appraisal.dart';
import 'progress_panels.dart';
import 'title_appraisal.dart';

/// The adventurer, their habits' history, and the way to settings.
class HeroScreen extends ConsumerWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider).value;
    final checkIns = ref.watch(recentCheckInsProvider).value ?? const [];
    final rules = ref.watch(gameRulesProvider);
    final progression = ref.watch(progressionProvider).value;
    if (board == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final hero = board.adventurer;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        PixelFrame(
          style: PixelFrameStyle.ornate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PixelSpriteView(
                    PixelPortraits.forAdventurer(
                      hero?.portraitId,
                      hero?.heroClass,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hero?.name ?? '冒險者', style: text.titleLarge),
                        if (hero?.title case final title?)
                          TitleFrame(
                            title: title,
                            frame: ref.watch(equippedProvider).value?.frame,
                          ),
                        Text(
                          '${hero?.heroClass ?? '見習冒險者'}・Lv.${board.level.level}',
                          style: text.bodyMedium,
                        ),
                        Text(
                          '累積 ${board.level.totalXp} EXP',
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hero?.identity case final identity?) ...[
                const SizedBox(height: 10),
                Text('「我想成為$identity」', style: text.bodySmall),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: PixelButton(
                  tone: PixelButtonTone.quiet,
                  onPressed: () => TitleAppraisal.start(context, ref),
                  child: Text(hero?.title == null ? '稱號鑑定' : '重新鑑定稱號'),
                ),
              ),
            ],
          ),
        ),
        if (progression != null) ...[
          const SizedBox(height: 12),
          GuildPanel(
            guild: progression.guild,
            commissions: board.entries.length,
            limit: rules.progression.commissionLimit(progression.guild.rank),
            onStartTrial: () => ref.read(gameServiceProvider).startTrial(),
          ),
          const PixelHeading('職業', icon: PixelIcons.shield),
          ClassPanel(
            progression: progression,
            today: board.today,
            onAppraise: () => ClassAppraisal.start(context, ref),
          ),
          const PixelHeading('能力值', icon: PixelIcons.star),
          StatPanel(progression: progression),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                expand: true,
                onPressed: () => _addHabit(context, ref, HabitKind.build),
                child: const Text('＋ 任務'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.arcane,
                expand: true,
                onPressed: () => _addHabit(context, ref, HabitKind.quit),
                child: const Text('＋ 封印'),
              ),
            ),
            const SizedBox(width: 8),
            PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: () => SettingsScreen.open(context),
              child: const Text('設定'),
            ),
          ],
        ),
        const PixelHeading('年度修行', icon: PixelIcons.star),
        PixelFrame(
          style: PixelFrameStyle.panel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: YearHeatmap(
                  levels: dailyCompletion(
                    active: [for (final e in board.entries) e.active],
                    checkIns: checkIns,
                    from: board.today.addDays(-7 * 52),
                    today: board.today,
                  ),
                  today: board.today,
                  weekStartsOn: rules.weekStartsOn,
                ),
              ),
              const SizedBox(height: 6),
              Text('最近一年：越綠代表那天完成越多每日委託，金色是完美的一天。', style: text.bodySmall),
            ],
          ),
        ),
        const PixelHeading('修行紀錄', icon: PixelIcons.flame),
        Text('最近 8 週：綠＝完成、金＝部分、紫＝守住封印、紅＝裂痕', style: text.bodySmall),
        const SizedBox(height: 8),
        for (final e in board.entries)
          _HabitRecord(
            entry: e,
            today: board.today,
            weekStartsOn: rules.weekStartsOn,
            outcomes: {
              for (final c in checkIns)
                if (c.habitId == e.habit.id) c.day: c.outcome,
            },
            onArchive: () => _archive(context, ref, e),
            onEdit: () => _edit(context, ref, e),
          ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, BoardEntry e) async {
    final rules = ref.read(gameRulesProvider);
    final penalty =
        rules.progression.cursePenaltyFactor *
        rules.baseXp(e.active.quest.rank);
    final draft = await HabitForm.show(
      context,
      e.habit.kind,
      initial: e.habit,
      anchorChoices: anchorChoices(
        ref.read(boardProvider).value?.entries ?? const [],
        forHabit: e.habit.id,
      ),
      warning: e.cursed
          ? '這個任務今天已經被詛咒了，再改也不會加重。'
          : '修改是要付出代價的：今天「${e.active.quest.title}」會被詛咒，'
                '一定要${e.isSeal ? '守住封印' : '完整完成'}，'
                '否則明天會失去 $penalty EXP（不會掉級）。'
                '${e.isSeal ? '' : '只改「接在…之後」不用付代價。'}',
    );
    if (draft == null || !context.mounted) return;
    final result = await ref
        .read(gameServiceProvider)
        .editHabit(e.habit.id, draft);
    if (context.mounted) {
      final cursed = result == HabitEditResult.cursed;
      showPixelToast(context, switch (result) {
        HabitEditResult.unchanged => '沒有任何變更',
        HabitEditResult.anchorOnly => '已更新「${e.active.quest.title}」的堆疊',
        HabitEditResult.cursed => '詛咒降臨：今天一定要完成「${e.active.quest.title}」',
      }, icon: cursed ? PixelIcons.skull : PixelIcons.star);
    }
  }

  Future<void> _addHabit(
    BuildContext context,
    WidgetRef ref,
    HabitKind kind,
  ) async {
    final hero = await ref.read(adventurerRepoProvider).get();
    final held = (await ref.read(habitRepoProvider).active()).length;
    final rank = hero?.guildRank ?? QuestRank.f;
    final limit = ref.read(gameRulesProvider).progression.commissionLimit(rank);
    if (!context.mounted) return;
    if (held >= limit) {
      await showMentor(context, [
        '等等！${rank.label} 級冒險者同時最多只能接 $limit 件委託。',
        rank.isTop
            ? '想接新的，就先封存一件吧。'
            : '先把手上的做穩，升上 ${rank.next.label} 就能多接 1 件。不然，也可以先封存一件。',
      ]);
      return;
    }
    if (!context.mounted) return;
    final draft = await HabitForm.show(
      context,
      kind,
      anchorChoices: anchorChoices(
        ref.read(boardProvider).value?.entries ?? const [],
      ),
    );
    if (draft == null || !context.mounted) return;
    final service = ref.read(adventureServiceProvider);
    final config = await ref.read(settingsRepoProvider).storyConfig();
    final request = await service.forgeRequest(
      heroName: hero?.name ?? '冒險者',
      identity: hero?.identity,
      drafts: [draft],
      config: config,
      withPrologue: false,
    );
    if (!context.mounted) return;
    final result = await runAiTask<ForgeResult>(
      context,
      ref,
      title: '鍛造新任務',
      prompt: PromptBuilder.forge(request),
      parse: (raw) => parseForge(raw, request),
      template: () => TemplateWriter.forge(request),
    );
    if (result == null) return;
    await service.addHabits([draft], result);
    if (context.mounted) {
      showPixelToast(
        context,
        '新${kind == HabitKind.quit ? '封印' : '任務'}：${result.quests.single.title}',
        icon: PixelIcons.scroll,
      );
    }
  }

  Future<void> _archive(
    BuildContext context,
    WidgetRef ref,
    BoardEntry e,
  ) async {
    final ok = await showPixelDialog<bool>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '封存「${e.active.quest.title}」？',
            style: Theme.of(ctx).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('紀錄會保留，但不會再出現在任務板上。', style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: 16),
          PixelButton(
            tone: PixelButtonTone.danger,
            expand: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('封存'),
          ),
          const SizedBox(height: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            expand: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(habitRepoProvider)
          .archive(e.habit.id, ref.read(clockProvider).now());
    }
  }
}

class _HabitRecord extends StatelessWidget {
  const _HabitRecord({
    required this.entry,
    required this.today,
    required this.weekStartsOn,
    required this.outcomes,
    required this.onArchive,
    required this.onEdit,
  });

  final BoardEntry entry;
  final LogicalDay today;
  final int weekStartsOn;
  final Map<LogicalDay, CheckInOutcome> outcomes;
  final VoidCallback onArchive;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final q = entry.active.quest;
    final s = entry.streak;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PixelFrame(
        style: PixelFrameStyle.panel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelSpriteView(
                  entry.habit.kind == HabitKind.quit
                      ? PixelIcons.seal
                      : PixelIcons.byId(q.spriteId),
                ),
                const SizedBox(width: 8),
                RankBadge(q.rank),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.tier > 1 ? '${q.title}（第 ${q.tier} 階）' : q.title,
                    style: text.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text('修改', style: text.bodySmall),
                  ),
                ),
                GestureDetector(
                  onTap: onArchive,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text('封存', style: text.bodySmall),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                PixelHeatmap(
                  outcomes: outcomes,
                  today: today,
                  firstDay: entry.habit.firstDay,
                  weekStartsOn: weekStartsOn,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '連續 ${s.length} ${s.slotDays == 7 ? '週' : '天'}',
                        style: text.bodySmall,
                      ),
                      if (entry.isSeal)
                        Text('無裂痕 ${s.clean} 天', style: text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
