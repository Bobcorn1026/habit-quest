import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/app/adventure_service.dart';
import 'package:habit_quest/app/chapter_service.dart';
import 'package:habit_quest/app/demo_seed.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/domain/story_config.dart';
import 'package:habit_quest/domain/upgrade_offer.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/game/period.dart';

void main() {
  /// 2026-11-04 is a Wednesday.
  const wed = LogicalDay(2026, 11, 4);

  Chapter prologue(LogicalDay day) => Chapter(
    id: 1,
    number: 0,
    period: Period(day, 0),
    status: ChapterStatus.written,
    createdAt: DateTime(2026),
  );

  ChapterPlan? plan(
    List<Chapter> chapters,
    LogicalDay today, {
    StoryConfig config = const StoryConfig(),
  }) => ChapterService.planFor(
    chapters: chapters,
    config: config,
    today: today,
    weekStartsOn: DateTime.monday,
  );

  group('planFor', () {
    test('first chapter runs from joining day to the end of that week', () {
      expect(plan([prologue(wed)], wed.addDays(4)), isNull, reason: 'Sunday');
      final p = plan([prologue(wed)], wed.addDays(5))!; // next Monday
      expect(p.number, 1);
      expect(p.period, Period(wed, 5));
    });

    test('joining on a Sunday folds into the next week', () {
      const sun = LogicalDay(2026, 11, 8);
      expect(plan([prologue(sun)], sun.addDays(1)), isNull);
      expect(plan([prologue(sun)], sun.addDays(8))!.period, Period(sun, 8));
    });

    test('missed weeks merge into one long chapter', () {
      final p = plan([prologue(wed)], wed.addDays(5 + 14 + 3))!;
      expect(p.period, Period(wed, 19));
      expect(p.isLong(const StoryConfig()), isTrue);
    });

    test('custom period lengths count from the last chapter', () {
      final p = plan(
        [prologue(wed)],
        wed.addDays(3),
        config: const StoryConfig(periodDays: 3),
      )!;
      expect(p.period, Period(wed, 3));
    });

    test(
      'any period length from 1 to 28 days counts from the last chapter',
      () {
        final first = Chapter(
          id: 2,
          number: 1,
          period: Period(wed, 7),
          status: ChapterStatus.written,
          createdAt: DateTime(2026),
        );
        final end = first.period.endExclusive;
        for (final days in [1, 2, 5, 10, 21, 28]) {
          final config = StoryConfig(periodDays: days);
          expect(
            plan([prologue(wed), first], end.addDays(days - 1), config: config),
            isNull,
            reason: '$days days: still running on the last day',
          );
          final next = plan(
            [prologue(wed), first],
            end.addDays(days),
            config: config,
          )!;
          expect(next.number, 2);
          expect(next.period, Period(end, days), reason: '$days days');
        }
      },
    );

    test('a pending chapter is offered again as is', () {
      final pending = Chapter(
        id: 2,
        number: 1,
        period: Period(wed, 5),
        status: ChapterStatus.pending,
        createdAt: DateTime(2026),
      );
      final p = plan([prologue(wed), pending], wed.addDays(30))!;
      expect(p.pending, same(pending));
      expect(p.period, Period(wed, 5));
    });

    test('nothing before onboarding', () {
      expect(plan([], wed), isNull);
    });
  });

  group('request and apply', () {
    late AppDatabase db;
    late ChapterService service;
    late StoryRepository story;
    late CheckInRepository checkIns;
    final clock = FixedClock(DateTime(2026, 11, 9, 10)); // Monday

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      db = AppDatabase(NativeDatabase.memory());
      story = StoryRepository(db);
      checkIns = CheckInRepository(db);
      final settings = SettingsRepository(db);
      final habits = HabitRepository(db);
      final adventurers = AdventurerRepository(db);
      await seedDemo(
        adventurers: adventurers,
        habits: habits,
        checkIns: checkIns,
        story: story,
        settings: settings,
        rules: const GameRules(),
        today: LogicalDay.of(clock.now()),
      );
      service = ChapterService(
        clock: clock,
        rules: const GameRules(),
        adventurers: adventurers,
        habits: habits,
        checkIns: checkIns,
        story: story,
        settings: settings,
        adventure: AdventureService(
          clock: clock,
          rules: const GameRules(),
          adventurers: adventurers,
          habits: habits,
          story: story,
          settings: settings,
        ),
      );
    });
    tearDown(() => db.close());

    test(
      'builds stats, recaps and the last choice from the database',
      () async {
        final p = (await service.due())!;
        expect(p.number, 1);
        final r = await service.buildRequest(p);
        expect(r.heroName, '亞倫');
        expect(r.lastChoice, '收下委託書');
        expect(r.recentRecaps.single, contains('冒險者公會'));
        expect(r.habits, hasLength(4));
        expect(r.habits.first.key, startsWith('q'));
        expect(r.score, greaterThan(0.7));
      },
    );

    test(
      'apply writes the chapter, clamps the bonus, updates offers',
      () async {
        // The stale reading quest gets an open offer first.
        final active = await HabitRepository(db).active();
        final reading = active.first.quest;
        await story.addOffer(
          questId: reading.id,
          kind: OfferKind.stale,
          proposedTitle: '模板標題',
          now: clock.now(),
        );

        final p = (await service.due())!;
        final r = await service.buildRequest(p);
        expect(r.upgradeCandidates.single.key, 'q${reading.id}');
        final pending = await service.ensurePending(p, r);
        expect((await service.due())!.pending!.id, pending.id);

        final xpBefore = await checkIns.totalXp();
        final bonus = await service.apply(
          pending,
          ChapterResult(
            content: const ChapterContent(
              title: '新章',
              body: '……',
              choices: [StoryChoice('前進')],
              recap: '摘要',
            ),
            qualityBonus: 0.9,
            upgrades: [
              UpgradeText(
                questKey: 'q${reading.id}',
                title: '解讀禁忌魔導書',
                subtitle: '～更深的黑暗～',
                npcLine: '這卷軸太薄了吧？',
              ),
            ],
          ),
        );
        expect(bonus, greaterThan(0));
        expect(await checkIns.totalXp(), xpBefore + bonus);
        final latest = (await story.latest())!;
        expect(latest.status, ChapterStatus.written);
        expect(latest.awaitsChoice, isTrue);
        final offer = (await story.openOffers()).single;
        expect(offer.proposedTitle, '解讀禁忌魔導書');
        expect(offer.chapterId, pending.id);
        expect(await service.due(), isNull);
      },
    );
  });
}
