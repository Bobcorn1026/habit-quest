import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/board.dart';
import '../../../app/game_service.dart';
import '../../../app/price_service.dart';
import '../../../app/providers.dart';
import '../../../game/price_level.dart';
import '../../../domain/check_in.dart';
import '../../../app/progression.dart';
import '../../../game/daily_comment.dart';
import '../../../game/progression.dart';
import '../../../game/side_quests.dart';
import '../../pixel/pixel.dart';
import '../../widgets/celebration.dart';
import '../../widgets/mentor.dart';
import '../../widgets/pixel_controls.dart';
import 'check_in_sheet.dart';
import 'hero_header.dart';
import 'offer_dialog.dart';
import 'quest_card.dart';
import 'seal_card.dart';

/// Today's quests and seals.
class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key, this.header});

  /// Shown above the hero header (e.g. a "chapter ready" banner).
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);
    return board.when(
      loading: () => const Center(child: Text('載入中…')),
      error: (e, _) => Center(child: Text('發生錯誤：$e')),
      data: (state) => _Board(state: state, header: header),
    );
  }
}

class _Board extends ConsumerWidget {
  const _Board({required this.state, this.header});

  final BoardState state;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = state.today;
    final rules = ref.watch(gameRulesProvider);
    final quests = state.quests.toList();
    final seals = state.seals.toList();
    final remaining = state.entries.where((e) => !e.reportedToday).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ?header,
        HeroHeader(state: state),
        if (ref.watch(sideQuestProvider) case final side?) ...[
          const SizedBox(height: 8),
          _SideQuestCard(
            side: side,
            questTitle: state.entries
                .where((e) => e.habit.id == side.quest.habitId)
                .firstOrNull
                ?.active
                .quest
                .title,
            rules: ref.watch(gameRulesProvider).progression,
            // What it paid once it is done; until then this week's price.
            gold:
                ref.watch(sideQuestPaidProvider(side.rewardRef)).value ??
                inflate(
                  ref.watch(gameRulesProvider).progression.sideQuestGold,
                  ref.watch(priceLevelProvider).value ?? 100,
                ),
          ),
        ],
        if (ref.watch(blessingProvider) case final b?) ...[
          const SizedBox(height: 8),
          PixelFrame(
            style: PixelFrameStyle.panel,
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Row(
              children: [
                const PixelSpriteView(PixelIcons.star),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '抉擇的加持：${b.blessing.label}（到 ${b.until.month}/${b.until.day}）',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: PixelPalette.tealLight),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state.restToday) ...[
          const SizedBox(height: 8),
          const _RestDayBanner(),
        ],
        if (ref.watch(curseNewsProvider).value case final news?
            when news.isNotEmpty) ...[
          const SizedBox(height: 12),
          _CurseNewsBanner(
            news: news,
            onDismiss: () => ref.read(gameServiceProvider).dismissCurseNews(),
          ),
        ],
        PixelHeading(
          '今日任務',
          icon: PixelIcons.sword,
          trailing: Text(
            formatDayLabel(today.month, today.day, today.weekday),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        if (state.entries.isEmpty)
          const PixelFrame(
            style: PixelFrameStyle.panel,
            child: Text('還沒有任何任務。到「角色」頁新增習慣吧。'),
          )
        else if (remaining == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MentorBox(lines: [dailyComment(_recap(ref))]),
          ),
        for (final e in quests) ...[
          QuestCard(
            key: ValueKey('quest-${e.habit.id}'),
            entry: e,
            onReport: () => _report(context, ref, e),
            onUndo: () => ref.read(gameServiceProvider).undo(e),
            onOffer: () => _offer(context, ref, e),
          ),
          const SizedBox(height: 12),
        ],
        if (seals.isNotEmpty) const PixelHeading('封印', icon: PixelIcons.seal),
        for (final e in seals) ...[
          SealCard(
            key: ValueKey('seal-${e.habit.id}'),
            entry: e,
            sealMasteryDays: rules.promotion.sealMasteryDays,
            onHold: () => _seal(context, ref, e, held: true),
            onCrack: () => _seal(context, ref, e, held: false),
            onUndo: () => ref.read(gameServiceProvider).undo(e),
            onOffer: () => _offer(context, ref, e),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Today as 莉娜 sees it once everything is reported.
  DayRecap _recap(WidgetRef ref) {
    final entries = state.entries;
    final daily = [
      for (final e in entries)
        if (e.habit.isDaily) e,
    ];
    final best = daily.isEmpty
        ? null
        : daily.reduce((a, b) => b.streak.length > a.streak.length ? b : a);
    final guild = ref.watch(progressionProvider).value?.guild;
    return (
      day: state.today,
      perfect: isPerfectDay(state.today, [
        for (final e in entries) e.active,
      ], indexCheckIns([for (final e in entries) ?e.today])),
      done: entries
          .where((e) => e.today?.outcome == CheckInOutcome.done)
          .length,
      partial: entries
          .where((e) => e.today?.outcome == CheckInOutcome.partial)
          .length,
      cracks: entries
          .where((e) => e.today?.outcome == CheckInOutcome.relapsed)
          .length,
      bestStreak: best?.streak.length ?? 0,
      bestQuest: best?.active.quest.title ?? '',
      trial: guild != null && guild.state == TrialState.running
          ? (guild.trialDaysDone, guild.trialDays)
          : null,
    );
  }

  Future<void> _report(
    BuildContext context,
    WidgetRef ref,
    BoardEntry e,
  ) async {
    final input = await CheckInSheet.show(
      context,
      habit: e.habit,
      quest: e.active.quest,
    );
    if (input == null || !context.mounted) return;
    final result = await ref
        .read(gameServiceProvider)
        .report(
          e,
          outcome: GameService.buildOutcome(e.habit, input.amount),
          amount: input.amount,
          note: input.note,
        );
    if (context.mounted) _celebrate(context, ref, result, PixelIcons.star);
  }

  Future<void> _seal(
    BuildContext context,
    WidgetRef ref,
    BoardEntry e, {
    required bool held,
  }) async {
    final service = ref.read(gameServiceProvider);
    if (held) {
      final result = await service.report(e, outcome: CheckInOutcome.resisted);
      if (context.mounted) _celebrate(context, ref, result, PixelIcons.seal);
      return;
    }
    final note = await CrackDialog.show(context, e.active.quest.title);
    if (note == null) return;
    await service.report(e, outcome: CheckInOutcome.relapsed, note: note);
    if (context.mounted) {
      showPixelToast(context, '裂痕已記下。明天再把封印補起來。', icon: PixelIcons.crack);
    }
  }

  Future<void> _celebrate(
    BuildContext context,
    WidgetRef ref,
    CheckInResult r,
    PixelSprite icon,
  ) async {
    showPixelToast(
      context,
      r.perfectBonus > 0
          ? '完美的一天！+${r.xp} EXP・+${r.gold + r.perfectBonus} 金幣'
          : '+${r.xp} EXP・+${r.gold} 金幣',
      icon: r.perfectBonus > 0 ? PixelIcons.coin : icon,
    );
    final name = state.adventurer?.name ?? '勇者';
    if (r.leveledUp) {
      await showCelebration(
        context,
        title: '等級提升！',
        detail: 'Lv.${r.before.level} → Lv.${r.after.level}',
        lines: ['恭喜！$name升到 Lv.${r.after.level} 了！', '大家都跑來幫你慶祝了——今天也辛苦了！'],
      );
    }
    if (r.sideQuestDone case final title? when context.mounted) {
      final rules = ref.read(gameRulesProvider).progression;
      await showCelebration(
        context,
        title: '支線完成！',
        detail: '「$title」',
        lines: [
          '額外的委託也做完了？……好啦，這是說好的獎金。',
          '+${r.sideQuestGold} 金幣、+${rules.sideQuestXp} EXP。下次也拜託你囉。',
        ],
      );
    }
    final rank = r.promotedTo;
    if (rank != null && context.mounted) {
      await showCelebration(
        context,
        title: '晉升考驗通過！',
        detail: '公會 Rank ${rank.label}',
        lines: [
          '考驗通過！從今天起，$name就是 ${rank.label} 級冒險者了。',
          '下一個 Rank 的公會點數要重新累積喔。繼續加油！',
        ],
      );
    }
  }

  Future<void> _offer(BuildContext context, WidgetRef ref, BoardEntry e) async {
    final decision = await OfferDialog.show(context, e);
    if (decision == null) return;
    final service = ref.read(gameServiceProvider);
    final offer = e.offer!;
    switch (decision.answer) {
      case OfferAnswer.accept:
        await service.acceptOffer(
          offer,
          title: decision.title,
          subtitle: decision.subtitle,
          target: decision.target,
        );
        if (context.mounted) {
          showPixelToast(
            context,
            '任務晉階：${decision.title}',
            icon: PixelIcons.crown,
          );
        }
      case OfferAnswer.decline:
        await service.declineOffer(offer);
      case OfferAnswer.retire:
        await service.retireSeal(offer);
        if (context.mounted) {
          showPixelToast(context, '封印已封存為戰利品', icon: PixelIcons.chest);
        }
    }
  }
}

class _RestDayBanner extends StatelessWidget {
  const _RestDayBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.seal,
      child: Row(
        children: [
          const PixelSpriteView(PixelIcons.potion),
          const SizedBox(width: 8),
          Expanded(child: Text('今天在旅店休息：不回報也不會負傷', style: text.bodySmall)),
        ],
      ),
    );
  }
}

class _CurseNewsBanner extends StatelessWidget {
  const _CurseNewsBanner({required this.news, required this.onDismiss});

  final List<CurseNews> news;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PixelFrame(
      style: PixelFrameStyle.seal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final n in news)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  PixelSpriteView(
                    n.lifted ? PixelIcons.star : PixelIcons.skull,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      n.lifted
                          ? '「${n.quest}」的詛咒解除了。'
                          : n.penalty > 0
                          ? '「${n.quest}」的詛咒發作了：失去 ${n.penalty} EXP。'
                          : '「${n.quest}」的詛咒發作了，幸好沒有經驗值可以奪走。',
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: PixelButton(
              tone: PixelButtonTone.quiet,
              onPressed: onDismiss,
              child: const Text('知道了'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideQuestCard extends StatelessWidget {
  const _SideQuestCard({
    required this.side,
    required this.questTitle,
    required this.rules,
    required this.gold,
  });

  final ActiveSideQuest side;
  final String? questTitle;
  final ProgressionRules rules;
  final int gold;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final q = side.quest;
    final status = side.done
        ? '完成！已領取 $gold 金幣、${rules.sideQuestXp} EXP'
        : side.failed
        ? '封印出現裂痕，這次的支線沒能完成。'
        : '${side.progress} / ${q.target}・到 ${side.until.month}/${side.until.day}'
              '・獎勵 $gold 金幣、${rules.sideQuestXp} EXP';
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelIcons.scroll),
              const SizedBox(width: 8),
              Expanded(child: Text('支線委託・${q.title}', style: text.bodyMedium)),
            ],
          ),
          const SizedBox(height: 4),
          Text(q.goal(questTitle), style: text.bodySmall),
          const SizedBox(height: 6),
          PixelBar(
            value: q.target == 0 ? 0 : side.progress / q.target,
            tone: side.failed ? PixelBarTone.danger : PixelBarTone.streak,
            segments: q.target.clamp(1, 14),
            height: 5,
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: text.bodySmall?.copyWith(
              color: side.done ? PixelPalette.goldLight : null,
            ),
          ),
        ],
      ),
    );
  }
}
