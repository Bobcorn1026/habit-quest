import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/check_in_repository.dart';
import '../data/economy_repository.dart';
import '../data/habit_repository.dart';
import '../data/settings_repository.dart';
import '../data/story_repository.dart';
import '../domain/adventurer.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/story_config.dart';
import '../domain/upgrade_offer.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import '../game/price_level.dart';
import '../game/blessing.dart';
import '../game/progression.dart';
import '../game/side_quests.dart';
import '../game/promotion.dart';
import '../game/streak.dart';
import '../game/xp.dart';
import 'board.dart';
import 'offer_texts.dart';
import 'price_service.dart';
import 'providers.dart';

enum InnResult {
  booked,
  notFuture,
  tooFar,
  weekFull,
  alreadyBooked,
  notEnoughGold,
}

/// What saving the habit form did.
enum HabitEditResult {
  /// Nothing differed: nothing saved, no curse.
  unchanged,

  /// Only the "do this after" anchor differed: saved, no curse.
  anchorOnly,

  /// The habit itself changed: saved, and today is cursed.
  cursed,
}

@immutable
class CheckInResult {
  const CheckInResult({
    required this.xp,
    required this.before,
    required this.after,
    this.gold = 0,
    this.perfectBonus = 0,
    this.promotedTo,
    this.sideQuestDone,
    this.sideQuestGold = 0,
  });

  /// Title of a side quest this check-in just finished, and the gold it
  /// paid.
  final String? sideQuestDone;
  final int sideQuestGold;

  final int xp;
  final int gold;

  /// Gold for completing a perfect day with this check-in.
  final int perfectBonus;
  final LevelInfo before;
  final LevelInfo after;

  /// Set when this check-in completed a guild promotion trial.
  final QuestRank? promotedTo;

  bool get leveledUp => after.level > before.level;
}

/// Game actions that touch several repositories.
class GameService {
  GameService({
    required this.clock,
    required this.rules,
    required this.habits,
    required this.checkIns,
    required this.story,
    required this.adventurers,
    required this.settings,
    required this.economy,
    required this.prices,
  });

  final Clock clock;
  final GameRules rules;
  final HabitRepository habits;
  final CheckInRepository checkIns;
  final StoryRepository story;
  final AdventurerRepository adventurers;
  final SettingsRepository settings;
  final EconomyRepository economy;
  final PriceService prices;

  LogicalDay get today =>
      LogicalDay.of(clock.now(), dayStartHour: rules.dayStartHour);

  /// Picks done vs partial from the reported amount.
  static CheckInOutcome buildOutcome(Habit habit, double? amount) {
    if (!habit.hasAmount || amount == null) return CheckInOutcome.done;
    return amount >= habit.target!
        ? CheckInOutcome.done
        : CheckInOutcome.partial;
  }

  /// Saves today's report for [entry] and awards XP.
  Future<CheckInResult> report(
    BoardEntry entry, {
    required CheckInOutcome outcome,
    double? amount,
    String? note,
  }) async {
    final day = today;
    final habit = entry.habit;
    final quest = entry.active.quest;
    final history = await checkIns.forHabit(habit.id);
    final draft = CheckIn(
      habitId: habit.id,
      questId: quest.id,
      day: day,
      outcome: outcome,
      amount: amount,
      note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      createdAt: clock.now(),
    );
    final streak = computeStreak(
      habit: habit,
      checkIns: [...history.where((c) => c.day != day), draft],
      firstDay: habit.firstDay,
      today: day,
      weekStartsOn: rules.weekStartsOn,
      restDays: await economy.bookedDays(),
    );
    final hero = await adventurers.get();
    final cls = hero?.classInfo;
    // Loaded once; the check-in write below does not change them.
    final index = await habits.questIndex();
    final active = await habits.active();
    final chapters = await story.all();
    final config = await settings.storyConfig();
    final mastery = cls == null
        ? null
        : computeMastery(
            heroClass: cls,
            checkIns: await checkIns.between(cls.since, day),
            questIndex: index,
            rules: rules.progression,
          );
    final blessing = activeBlessing(
      chapters: chapters,
      today: day,
      periodDays: config.periodDays,
    )?.blessing;
    final blessed = blessing?.stat == entry.active.attribute;
    final xp = checkInXp(
      rules: rules,
      rank: quest.rank,
      outcome: outcome,
      amount: amount,
      target: quest.target,
      streakDays: streak.days,
      multiplier:
          classXpMultiplier(
            heroClass: cls,
            attribute: entry.active.attribute,
            masteryTier: mastery?.tier ?? 0,
            rules: rules.progression,
          ) +
          (blessed && blessing!.kind == BlessingKind.xp
              ? rules.progression.blessingXpBonus
              : 0),
    );

    final gold = inflate(
      checkInGold(
            rules: rules.progression,
            rank: quest.rank,
            outcome: outcome,
            streakDays: streak.days,
          ) +
          (blessed && blessing!.kind == BlessingKind.gold && outcome.keepsStreak
              ? rules.progression.blessingGold
              : 0),
      await prices.percentFor(day),
    );

    final before = LevelInfo.fromTotal(await checkIns.totalXp(), rules);
    await checkIns.upsert(
      CheckIn(
        habitId: draft.habitId,
        questId: draft.questId,
        day: draft.day,
        outcome: draft.outcome,
        amount: draft.amount,
        note: draft.note,
        xp: xp,
        gold: gold,
        createdAt: draft.createdAt,
      ),
    );
    final after = LevelInfo.fromTotal(await checkIns.totalXp(), rules);
    final perfectBonus = await _syncPerfectDay(day, active);
    final promotedTo = hero?.trialStart == null
        ? null
        : await _finishTrial(hero!, active, index);
    final side = await _paySideQuest(
      day,
      config: config,
      chapters: chapters,
      active: active,
      index: index,
    );
    return CheckInResult(
      xp: xp,
      gold: gold,
      perfectBonus: perfectBonus,
      before: before,
      after: after,
      promotedTo: promotedTo,
      sideQuestDone: side?.title,
      sideQuestGold: side?.gold ?? 0,
    );
  }

  /// Pays a finished side quest once; returns its title and gold when just
  /// paid.
  Future<({String title, int gold})?> _paySideQuest(
    LogicalDay day, {
    required StoryConfig config,
    required List<Chapter> chapters,
    required List<ActiveQuest> active,
    required Map<int, QuestInfo> index,
  }) async {
    final side = activeSideQuest(
      chapters: chapters,
      today: day,
      periodDays: config.periodDays,
      checkIns: await checkIns.between(day.addDays(-config.periodDays), day),
      active: active,
      questIndex: index,
    );
    if (side == null || !side.done) return null;
    final gold = inflate(
      rules.progression.sideQuestGold,
      await prices.percentFor(day),
    );
    final paid = await economy.reward(
      amount: gold,
      source: 'side',
      ref: side.rewardRef,
      at: clock.now(),
    );
    if (!paid) return null;
    await checkIns.addXpEvent(
      amount: rules.progression.sideQuestXp,
      source: 'side_quest',
      refId: side.chapterId,
      at: clock.now(),
    );
    return (title: side.quest.title, gold: gold);
  }

  /// Pays the perfect-day gold once, and takes it back if an undo spoils
  /// the day. Returns the gold when it was just paid, otherwise 0.
  Future<int> _syncPerfectDay(
    LogicalDay day, [
    List<ActiveQuest>? active,
  ]) async {
    final perfect = isPerfectDay(
      day,
      active ?? await habits.active(),
      indexCheckIns(await checkIns.between(day, day)),
    );
    if (!perfect) {
      await economy.revoke(source: 'perfect', ref: day.toKey());
      return 0;
    }
    final gold = inflate(
      rules.progression.goldPerfectDay,
      await prices.percentFor(day),
    );
    final paid = await economy.reward(
      amount: gold,
      source: 'perfect',
      ref: day.toKey(),
      at: clock.now(),
    );
    return paid ? gold : 0;
  }

  /// Promotes the adventurer if their running trial has just passed.
  Future<QuestRank?> _finishTrial(
    Adventurer hero,
    List<ActiveQuest> active,
    Map<int, QuestInfo> index,
  ) async {
    final day = today;
    final guild = computeGuild(
      adventurer: hero,
      active: active,
      checkIns: await checkIns.between(hero.trialStart!, day),
      questIndex: index,
      today: day,
      rules: rules.progression,
      restDays: await economy.bookedDays(),
    );
    if (guild.state != TrialState.passed) return null;
    final next = hero.guildRank.next;
    await adventurers.promote(hero.id, next, day);
    return next;
  }

  /// Books a night at the inn: [day] becomes a rest day.
  Future<InnResult> bookInn(LogicalDay day) async {
    final now = today;
    final p = rules.progression;
    if (!day.isAfter(now)) return InnResult.notFuture;
    if (day.differenceInDays(now) > p.innMaxAheadDays) return InnResult.tooFar;
    final booked = await economy.bookedDays();
    if (booked.contains(day)) return InnResult.alreadyBooked;
    final week = PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn)
        .periodOf(day);
    if (booked.where(week.contains).length >= p.innPerWeek) {
      return InnResult.weekFull;
    }
    // A night costs this week's price, whichever week it is booked for.
    final price = inflate(p.innPrice, await prices.percentFor(now));
    return switch (await economy.bookInn(day, price, clock.now())) {
      InnBookResult.booked => InnResult.booked,
      InnBookResult.alreadyBooked => InnResult.alreadyBooked,
      InnBookResult.notEnoughGold => InnResult.notEnoughGold,
    };
  }

  /// Cancels a booking for a future day and returns the gold refunded: what
  /// was paid for it. Null when there was nothing to cancel.
  Future<int?> cancelInn(LogicalDay day) async =>
      day.isAfter(today) ? economy.cancelInn(day) : null;

  /// Starts (or retries) the guild promotion trial from today.
  Future<void> startTrial() async {
    final hero = await adventurers.get();
    if (hero != null) await adventurers.startTrial(hero.id, today);
  }

  /// Changes a habit. The price: today the quest is cursed, and if it is not
  /// fully done by the end of the day it costs XP.
  ///
  /// Setting, changing or clearing the "do this after" anchor is not an
  /// edit: when that is all that differs, nothing is cursed. Saving with
  /// nothing changed costs nothing either.
  Future<HabitEditResult> editHabit(int habitId, HabitDraft draft) async {
    final h = await habits.habit(habitId);
    final sameThing =
        h.name == draft.name &&
        h.unit == draft.unit &&
        h.target == draft.target &&
        h.timesPerWeek == draft.timesPerWeek &&
        h.intention == draft.intention;
    final sameAnchor =
        h.anchorHabitId == draft.anchorHabitId &&
        (h.anchorText ?? '') == (draft.anchorText?.trim() ?? '');
    if (sameThing && sameAnchor) return HabitEditResult.unchanged;
    if (sameThing) {
      await habits.setAnchor(
        habitId,
        anchorHabitId: draft.anchorHabitId,
        anchorText: draft.anchorText,
      );
      return HabitEditResult.anchorOnly;
    }
    await habits.edit(habitId, draft, cursedOn: today);
    return HabitEditResult.cursed;
  }

  /// Judges curses whose day has ended and keeps the news for the board.
  Future<List<CurseNews>> settleCurses(Iterable<BoardEntry> entries) async {
    // The board emits often; one pass at a time so a curse is judged once.
    if (_settling) return const [];
    _settling = true;
    try {
      return await _settleCurses(entries);
    } finally {
      _settling = false;
    }
  }

  bool _settling = false;

  Future<List<CurseNews>> _settleCurses(Iterable<BoardEntry> entries) async {
    final day = today;
    final news = <CurseNews>[];
    final rest = await economy.bookedDays();
    for (final e in entries) {
      if (e.habit.cursedOn == null) continue;
      // The board may lag behind a pass that just finished; trust the row.
      final cursedOn = (await habits.habit(e.habit.id)).cursedOn;
      if (cursedOn == null || !cursedOn.isBefore(day)) continue;
      final onThatDay = (await checkIns.between(
        cursedOn,
        cursedOn,
      )).where((c) => c.habitId == e.habit.id).firstOrNull;
      var penalty = 0;
      // A rest day at the inn lifts the curse without a penalty.
      final lifted =
          rest.contains(cursedOn) ||
          judgeCurse(onThatDay) == CurseOutcome.lifted;
      if (!lifted) {
        // A curse hurts, but never takes a level away.
        final level = LevelInfo.fromTotal(await checkIns.totalXp(), rules);
        penalty = math.min(
          rules.progression.cursePenaltyFactor *
              rules.baseXp(e.active.quest.rank),
          level.xpIntoLevel,
        );
        if (penalty > 0) {
          await checkIns.addXpEvent(
            amount: -penalty,
            source: 'curse',
            refId: e.habit.id,
            at: clock.now(),
          );
        }
      }
      await habits.clearCurse(e.habit.id);
      news.add((quest: e.active.quest.title, lifted: lifted, penalty: penalty));
    }
    if (news.isNotEmpty) {
      final old = await settings.read(SettingKeys.curseNews);
      await settings.write(SettingKeys.curseNews, [
        if (old is List) ...old,
        for (final n in news)
          {'quest': n.quest, 'lifted': n.lifted, 'penalty': n.penalty},
      ]);
    }
    return news;
  }

  Future<void> dismissCurseNews() => settings.write(SettingKeys.curseNews, []);

  Future<void> undo(BoardEntry entry) async {
    await checkIns.remove(entry.habit.id, today);
    await _syncPerfectDay(today);
  }

  /// Opens an upgrade invitation for every quest whose verdict asks for one
  /// and that has had no invitation in the past week. Uses template lines;
  /// the next chapter may rewrite them.
  Future<void> syncOffers(Iterable<BoardEntry> entries) async {
    final now = clock.now();
    final recent = await story.offersSince(
      now.subtract(const Duration(days: 7)),
    );
    final busy = {
      for (final o in [...recent, ...await story.openOffers()]) o.questId,
    };
    for (final e in entries) {
      final v = e.verdict;
      if (!v.offersUpgrade || busy.contains(e.active.quest.id)) continue;
      final kind = v.sealMastered ? OfferKind.sealMastery : OfferKind.surpass;
      final q = e.active.quest;
      final text = offerTemplate(kind, q);
      await story.addOffer(
        questId: q.id,
        kind: kind,
        proposedTarget: q.target == null
            ? null
            : suggestedUpgradeTarget(q.target!, rules.promotion),
        proposedTitle: text.title,
        proposedSubtitle: text.subtitle,
        npcLine: text.npcLine,
        now: now,
      );
    }
  }

  /// Takes the offer: the quest moves to its next tier from today. The
  /// player may have rewritten the bard's [title], [subtitle] and [target].
  Future<void> acceptOffer(
    UpgradeOffer offer, {
    String? title,
    String? subtitle,
    double? target,
  }) async {
    final q = await habits.quest(offer.questId);
    await habits.upgrade(
      q.habitId,
      QuestDraft(
        rank: q.rank.next,
        title: title ?? offer.proposedTitle,
        subtitle: subtitle ?? offer.proposedSubtitle,
        flavor: q.flavor,
        spriteId: q.spriteId,
        target: target ?? offer.proposedTarget ?? q.target,
        attribute: q.attribute,
      ),
      today: today,
    );
    await story.resolveOffer(offer.id, OfferStatus.accepted);
  }

  Future<void> declineOffer(UpgradeOffer offer) =>
      story.resolveOffer(offer.id, OfferStatus.declined);

  /// Retires a mastered seal as a trophy.
  Future<void> retireSeal(UpgradeOffer offer) async {
    final q = await habits.quest(offer.questId);
    await habits.archive(q.habitId, clock.now());
    await story.resolveOffer(offer.id, OfferStatus.accepted);
  }
}

final gameServiceProvider = Provider<GameService>(
  (ref) => GameService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    habits: ref.watch(habitRepoProvider),
    checkIns: ref.watch(checkInRepoProvider),
    story: ref.watch(storyRepoProvider),
    adventurers: ref.watch(adventurerRepoProvider),
    settings: ref.watch(settingsRepoProvider),
    economy: ref.watch(economyRepoProvider),
    prices: ref.watch(priceServiceProvider),
  ),
);
