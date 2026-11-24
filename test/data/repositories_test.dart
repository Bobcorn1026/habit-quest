import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/domain/story_config.dart';
import 'package:habit_quest/domain/upgrade_offer.dart';
import 'package:habit_quest/game/judgement.dart';
import 'package:habit_quest/game/period.dart';

import '../support/builders.dart';

void main() {
  late AppDatabase db;
  late HabitRepository habits;
  late CheckInRepository checkIns;
  final now = DateTime(2026, 11, 2, 9);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    habits = HabitRepository(db);
    checkIns = CheckInRepository(db);
  });
  tearDown(() => db.close());

  Future<ActiveQuest> addReading() => habits.create(
    const HabitDraft(
      kind: HabitKind.build,
      name: '讀英文',
      unit: '分鐘',
      target: 20,
    ),
    const QuestDraft(
      rank: QuestRank.c,
      title: '破譯古代卷軸',
      subtitle: '～那些字母在對我低語～',
      target: 20,
    ),
    now: now,
    today: monday,
  );

  test('adventurer is created and updated', () async {
    final repo = AdventurerRepository(db);
    expect(await repo.get(), isNull);
    final id = await repo.create(name: '亞倫', identity: '持續學習的人', now: now);
    await repo.updateClassAndTitle(id, heroClass: '見習賢者');
    final a = await repo.get();
    expect(a!.name, '亞倫');
    expect(a.heroClass, '見習賢者');
  });

  group('habits and quests', () {
    test('create stores the habit with its first tier', () async {
      final a = await addReading();
      expect(a.habit.firstDay, monday);
      expect(a.quest.tier, 1);
      expect(a.quest.isCurrent, isTrue);
      expect(await habits.active(), hasLength(1));
    });

    test('quit habits are always daily', () async {
      final a = await habits.create(
        const HabitDraft(kind: HabitKind.quit, name: '深夜滑手機', timesPerWeek: 3),
        const QuestDraft(rank: QuestRank.b, title: '深夜手機魔'),
        now: now,
        today: monday,
      );
      expect(a.habit.timesPerWeek, 7);
    });

    test('upgrade closes the old tier and raises the target', () async {
      final a = await addReading();
      final next = await habits.upgrade(
        a.habit.id,
        const QuestDraft(rank: QuestRank.b, title: '解讀禁忌魔導書', target: 25),
        today: monday.addDays(30),
      );
      expect(next.tier, 2);
      final tiers = await habits.tiers(a.habit.id);
      expect(tiers.first.activeUntil, monday.addDays(29));
      expect((await habits.habit(a.habit.id)).target, 25);
      final active = await habits.active();
      expect(active.single.quest.id, next.id);
    });

    test('archived habits leave the board', () async {
      final a = await addReading();
      await habits.archive(a.habit.id, now);
      expect(await habits.active(), isEmpty);
    });
  });

  group('check-ins', () {
    test('one report per habit per day; later saves replace it', () async {
      final a = await addReading();
      CheckIn c(CheckInOutcome o, double amount, int xp) => CheckIn(
        habitId: a.habit.id,
        questId: a.quest.id,
        day: monday,
        outcome: o,
        amount: amount,
        xp: xp,
        createdAt: now,
      );
      await checkIns.upsert(c(CheckInOutcome.partial, 10, 9));
      await checkIns.upsert(c(CheckInOutcome.done, 25, 22));
      final rows = await checkIns.between(monday, monday);
      expect(rows.single.outcome, CheckInOutcome.done);
      expect(rows.single.amount, 25);
      expect(await checkIns.totalXp(), 22);

      await checkIns.remove(a.habit.id, monday);
      expect(await checkIns.totalXp(), 0);
    });

    test(
      'between is inclusive and ordered; total XP includes events',
      () async {
        final a = await addReading();
        for (var i = 0; i < 5; i++) {
          await checkIns.upsert(
            CheckIn(
              habitId: a.habit.id,
              questId: a.quest.id,
              day: monday.addDays(4 - i),
              outcome: CheckInOutcome.done,
              xp: 10,
              createdAt: now,
            ),
          );
        }
        final mid = await checkIns.between(
          monday.addDays(1),
          monday.addDays(3),
        );
        expect(mid.map((c) => c.day.day), [3, 4, 5]);

        await checkIns.addXpEvent(amount: 15, source: 'chapter_bonus', at: now);
        expect(await checkIns.totalXp(), 65);
      },
    );
  });

  group('story', () {
    test('pending chapter is written and a choice recorded', () async {
      final story = StoryRepository(db);
      final pending = await story.createPending(
        number: 1,
        period: Period(monday, 7),
        judgement: Judgement.success,
        score: 0.8,
        stats: {'habits': []},
        now: now,
      );
      expect(pending.status, ChapterStatus.pending);
      await story.write(
        pending.id,
        const ChapterContent(
          title: '霧之圖書館',
          body: '……',
          choices: [StoryChoice('推開左邊的門'), StoryChoice('跟著貓頭鷹')],
          recap: '主角進入圖書館。',
        ),
        now: now,
      );
      var ch = await story.latest();
      expect(ch!.awaitsChoice, isTrue);
      expect(ch.judgement, Judgement.success);
      await story.choose(ch.id, 1);
      ch = await story.byId(ch.id);
      expect(ch.chosen!.label, '跟著貓頭鷹');
      expect(ch.awaitsChoice, isFalse);
      expect(await story.statsOf(ch.id), {'habits': []});
    });

    test('offers can be resolved', () async {
      final story = StoryRepository(db);
      final a = await addReading();
      final id = await story.addOffer(
        questId: a.quest.id,
        kind: OfferKind.stale,
        proposedTarget: 25,
        proposedTitle: '解讀禁忌魔導書',
        now: now,
      );
      expect(await story.openOffers(), hasLength(1));
      await story.resolveOffer(id, OfferStatus.accepted);
      expect(await story.openOffers(), isEmpty);
    });
  });

  test('settings round-trip story config with defaults', () async {
    final settings = SettingsRepository(db);
    expect((await settings.storyConfig()).periodDays, 7);
    await settings.saveStoryConfig(
      const StoryConfig(periodDays: 3, tone: StoryTone.epic),
    );
    final c = await settings.storyConfig();
    expect(c.periodDays, 3);
    expect(c.tone, StoryTone.epic);
    expect(c.choicesPerChapter, 3);
  });

  test('story config tolerates bad JSON values', () {
    final c = StoryConfig.fromJson({
      'periodDays': 999,
      'choicesPerChapter': 1,
      'tone': 'nope',
      'world': '',
    });
    expect(c.periodDays, 28);
    expect(c.choicesPerChapter, 2);
    expect(c.tone, StoryTone.mixed);
    expect(c.world, '中世紀劍與魔法');
  });

  test('logical days sort as stored keys', () {
    expect(
      const LogicalDay(2026, 9, 30).toKey().compareTo('2026-10-01'),
      lessThan(0),
    );
  });
}
