import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_tasks.dart';
import '../ai/complete.dart';
import '../ai/prompts.dart';
import '../ai/response_parser.dart';
import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/check_in_repository.dart';
import '../data/economy_repository.dart';
import '../data/habit_repository.dart';
import '../data/settings_repository.dart';
import '../data/story_repository.dart';
import '../domain/chapter.dart';
import '../domain/hero_class.dart';
import '../domain/story_config.dart';
import '../domain/upgrade_offer.dart';
import '../domain/quest_rank.dart';
import '../domain/side_quest.dart';
import '../domain/stat.dart';
import '../game/blessing.dart';
import '../game/checks.dart';
import '../game/game_rules.dart';
import '../game/habit_stats.dart';
import '../game/judgement.dart';
import '../game/period.dart';
import '../game/progression.dart';
import '../game/xp.dart';
import 'adventure_service.dart';
import 'ai_providers.dart';
import 'providers.dart';

/// The next chapter to write.
@immutable
class ChapterPlan {
  const ChapterPlan({required this.number, required this.period, this.pending});

  final int number;
  final Period period;

  /// Set when a chapter row already exists but was never written.
  final Chapter? pending;

  /// Covers more than one regular period (the player was away).
  bool isLong(StoryConfig config) => period.days > config.periodDays + 6;
}

/// Decides when chapters are due and turns a period into a chapter.
class ChapterService {
  ChapterService({
    required this.clock,
    required this.rules,
    required this.adventurers,
    required this.habits,
    required this.checkIns,
    required this.story,
    required this.settings,
    required this.adventure,
    this.economy,
  });

  final Clock clock;
  final GameRules rules;
  final AdventurerRepository adventurers;
  final HabitRepository habits;
  final CheckInRepository checkIns;
  final StoryRepository story;
  final SettingsRepository settings;
  final AdventureService adventure;
  final EconomyRepository? economy;

  LogicalDay get today =>
      LogicalDay.of(clock.now(), dayStartHour: rules.dayStartHour);

  /// Null while the current period is still running.
  static ChapterPlan? planFor({
    required List<Chapter> chapters,
    required StoryConfig config,
    required LogicalDay today,
    required int weekStartsOn,
  }) {
    if (chapters.isEmpty) return null;
    final latest = chapters.reduce((a, b) => a.number > b.number ? a : b);
    if (latest.status == ChapterStatus.pending) {
      return ChapterPlan(
        number: latest.number,
        period: latest.period,
        pending: latest,
      );
    }
    final weeks = PeriodCalendar.weeks(weekStartsOn: weekStartsOn);
    LogicalDay endAfter(LogicalDay s) => config.periodDays == 7
        ? weeks.periodOf(s).endExclusive
        : s.addDays(config.periodDays);

    final start = latest.period.endExclusive;
    var end = endAfter(start);
    // Too short a first chapter (joined on a Sunday): run into next period.
    if (latest.number == 0 && end.differenceInDays(start) < 3) {
      end = endAfter(end);
    }
    if (today.isBefore(end)) return null;
    // Away for several periods: one chapter covers them all.
    while (!today.isBefore(endAfter(end))) {
      end = endAfter(end);
    }
    return ChapterPlan(
      number: latest.number + 1,
      period: Period(start, end.differenceInDays(start)),
    );
  }

  Future<ChapterPlan?> due() async => planFor(
    chapters: await story.all(),
    config: await settings.storyConfig(),
    today: today,
    weekStartsOn: rules.weekStartsOn,
  );

  /// Builds the AI request; a pending chapter keeps its request id so a
  /// reply pasted later still matches.
  Future<ChapterRequest> buildRequest(ChapterPlan plan) async {
    final config = await settings.storyConfig();
    final hero = await adventurers.get();
    final chapters = await story.all();
    final written = chapters
        .where((c) => c.status == ChapterStatus.written)
        .toList();
    final period = plan.period;
    final active = await habits.active();
    final history = await checkIns.between(period.start, period.last);
    final offers = {for (final o in await story.openOffers()) o.questId: o};

    final restDays = await economy?.bookedDays() ?? const <LogicalDay>{};
    final stats = <ChapterHabitStats>[];
    final perHabit = <HabitPeriodStats>[];
    final byStat = <Stat, (int, double)>{};
    for (final aq in active) {
      final s = computePeriodStats(
        habit: aq.habit,
        target: aq.quest.target,
        period: period,
        checkIns: history,
        firstDay: aq.habit.firstDay,
        asOf: period.last,
        restDays: restDays,
      );
      if (s.scheduled == 0) continue;
      perHabit.add(s);
      final (n, sum) = byStat[aq.attribute] ?? (0, 0.0);
      byStat[aq.attribute] = (
        n + s.scheduled,
        sum + s.completion * s.scheduled,
      );
      stats.add(
        ChapterHabitStats(
          key: 'q${aq.quest.id}',
          kind: aq.habit.kind,
          questTitle: aq.quest.title,
          habitName: aq.habit.name,
          attribute: aq.attribute,
          unit: aq.habit.unit,
          target: aq.quest.target,
          scheduled: s.scheduled,
          completion: s.completion,
          done: s.done,
          partial: s.partial,
          resisted: s.resisted,
          relapsed: s.relapsed,
          averageAmount: s.averageAmount,
          notes: s.notes.reversed.take(3).toList(),
          upgrade: switch (offers[aq.quest.id]?.kind) {
            OfferKind.stale || OfferKind.surpass => UpgradeReason.surpass,
            OfferKind.sealMastery => UpgradeReason.sealMastery,
            null => null,
          },
        ),
      );
    }
    final score = performanceScore(perHabit);
    // A blessing from the last chapter's choice makes its stat's check
    // easier this period.
    final blessing = activeBlessing(
      chapters: chapters,
      today: period.start,
      periodDays: config.periodDays,
    )?.blessing;
    final stored = plan.pending?.checks ?? const [];
    final checks = stored.isNotEmpty
        ? stored
        : rollChecks(
            completion: [
              for (final e
                  in byStat.entries.toList()
                    ..sort((a, b) => b.value.$1.compareTo(a.value.$1)))
                (
                  e.key,
                  e.value.$2 / e.value.$1 +
                      (blessing?.kind == BlessingKind.check &&
                              blessing?.stat == e.key
                          ? rules.progression.blessingCheckEase
                          : 0),
                ),
            ],
            statValues: (await _statSheet(hero?.classInfo, active)).values,
            seed: plan.number,
          );

    final pendingId = plan.pending == null
        ? null
        : (await story.statsOf(plan.pending!.id))['requestId'];

    return ChapterRequest(
      requestId: pendingId is String ? pendingId : newRequestId(),
      number: plan.number,
      period: period,
      config: config,
      heroName: hero?.name ?? '冒險者',
      heroClass: hero?.heroClass,
      level: LevelInfo.fromTotal(await checkIns.totalXp(), rules).level,
      guildRank: hero?.guildRank ?? QuestRank.f,
      checks: checks,
      world: await adventure.world(),
      recentRecaps: [
        for (final c in written.reversed.take(2).toList().reversed)
          if (c.recap.isNotEmpty) c.recap,
      ],
      lastChoice: written.lastOrNull?.chosen?.label,
      judgement: judge(score, rules.judgement),
      score: score,
      habits: stats,
    );
  }

  Future<StatSheet> _statSheet(
    HeroClass? heroClass,
    List<ActiveQuest> active,
  ) async {
    final day = today;
    return computeStats(
      xpByQuest: await checkIns.watchXpByQuest().first,
      questIndex: await habits.questIndex(),
      perfectDays: countPerfectDays(
        active: active,
        checkIns: await checkIns.between(day.addDays(-kHistoryDays), day),
        today: day,
      ),
      heroClass: heroClass,
      rules: rules.progression,
    );
  }

  /// Freezes the period as a pending chapter (shown as "being written").
  Future<Chapter> ensurePending(
    ChapterPlan plan,
    ChapterRequest request,
  ) async {
    if (plan.pending != null) return plan.pending!;
    return story.createPending(
      number: plan.number,
      period: plan.period,
      judgement: request.judgement,
      score: request.score,
      stats: {
        'requestId': request.requestId,
        'checks': [for (final c in request.checks) c.toJson()],
      },
      now: clock.now(),
    );
  }

  /// Writes the due chapter without asking when an API is set up, e.g. on
  /// the Monday a week ends. Returns the chapter id, or null when nothing
  /// was due or anything failed; the banner then offers the usual way.
  Future<int?> autoWrite(AiService ai) async {
    try {
      final config = await ai.config();
      if (!config.usesApi) return null;
      final client = await ai.clientFor(config);
      if (client == null) return null;
      final plan = await due();
      if (plan == null) return null;
      final request = await buildRequest(plan);
      final pending = await ensurePending(plan, request);
      final result = await completeWithRepair(
        client,
        PromptBuilder.chapter(request),
        (raw) => parseChapter(raw, request),
      );
      await apply(pending, result);
      return pending.id;
    } on Exception catch (e) {
      debugPrint('auto chapter: $e');
      return null;
    }
  }

  /// Saves the chapter, the clamped quality bonus and the NPC upgrade lines.
  /// Returns the bonus XP awarded.
  Future<int> apply(Chapter pending, ChapterResult result) async {
    final now = clock.now();
    await story.write(pending.id, result.content, now: now);

    final periodXp = (await checkIns.between(
      pending.period.start,
      pending.period.last,
    )).fold<int>(0, (sum, c) => sum + c.xp);
    final bonus = qualityBonusXp(
      rules: rules,
      weekXp: periodXp,
      requestedFraction: result.qualityBonus,
    );
    if (bonus > 0) {
      await checkIns.addXpEvent(
        amount: bonus,
        source: 'chapter_bonus',
        refId: pending.id,
        at: now,
      );
    }

    if (result.sideQuest case final s?) {
      final questId = s.questKey == null
          ? null
          : int.tryParse(s.questKey!.substring(1));
      final habitId = questId == null
          ? null
          : (await habits.quest(questId)).habitId;
      await story.mergeStats(pending.id, {
        'sideQuest': SideQuest(
          title: s.title,
          story: s.story,
          kind: s.kind,
          habitId: habitId,
          stat: s.stat,
          target: s.target,
        ).toJson(),
      });
    }

    final offers = await story.openOffers();
    for (final u in result.upgrades) {
      final questId = int.tryParse(u.questKey.substring(1));
      final offer = offers.where((o) => o.questId == questId).firstOrNull;
      if (offer == null) continue;
      await story.updateOfferText(
        offer.id,
        title: u.title,
        subtitle: u.subtitle,
        npcLine: u.npcLine,
        chapterId: pending.id,
      );
    }
    return bonus;
  }
}

final chapterServiceProvider = Provider<ChapterService>(
  (ref) => ChapterService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    adventurers: ref.watch(adventurerRepoProvider),
    habits: ref.watch(habitRepoProvider),
    checkIns: ref.watch(checkInRepoProvider),
    story: ref.watch(storyRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    adventure: ref.watch(adventureServiceProvider),
    economy: ref.watch(economyRepoProvider),
  ),
);

/// True while a chapter is being written in the background.
final autoWritingProvider = NotifierProvider<AutoWriting, bool>(
  AutoWriting.new,
);

class AutoWriting extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// The chapter waiting to be written, recomputed when chapters, settings or
/// the day change.
final chapterDueProvider = Provider<ChapterPlan?>((ref) {
  final chapters = ref.watch(chaptersProvider).value;
  final config = ref.watch(storyConfigProvider).value;
  if (chapters == null || config == null) return null;
  return ChapterService.planFor(
    chapters: chapters,
    config: config,
    today: ref.watch(todayProvider),
    weekStartsOn: ref.watch(gameRulesProvider).weekStartsOn,
  );
});
