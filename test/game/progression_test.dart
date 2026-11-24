import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/adventurer.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/hero_class.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/progression.dart';

import '../support/builders.dart';

void main() {
  const rules = ProgressionRules();
  final reading = ActiveQuest(buildHabit(), buildQuest());
  final seal = ActiveQuest(
    buildHabit(id: 2, kind: HabitKind.quit),
    buildQuest(habitId: 2),
  );
  final index = <int, QuestInfo>{
    10: (attribute: Stat.intel, rank: QuestRank.c),
    20: (attribute: Stat.spi, rank: QuestRank.c),
  };

  Adventurer hero({
    QuestRank rank = QuestRank.f,
    LogicalDay? rankSince,
    LogicalDay? trialStart,
  }) => Adventurer(
    id: 1,
    name: '亞倫',
    guildRank: rank,
    rankSince: rankSince,
    trialStart: trialStart,
    createdAt: DateTime(2026, 11, 2),
  );

  group('attributes', () {
    test('are guessed from habit names', () {
      expect(guessAttribute('讀英文', HabitKind.build), Stat.intel);
      expect(guessAttribute('重訓', HabitKind.build), Stat.str);
      expect(guessAttribute('晨跑', HabitKind.build), Stat.agi);
      expect(guessAttribute('早睡', HabitKind.build), Stat.vit);
      expect(guessAttribute('打電話給媽媽', HabitKind.build), Stat.cha);
      expect(guessAttribute('深夜滑手機', HabitKind.quit), Stat.spi);
      expect(guessAttribute('不知道', HabitKind.build), Stat.spi);
    });

    test('parse codes, names and labels', () {
      expect(Stat.parse('INT'), Stat.intel);
      expect(Stat.parse('intel'), Stat.intel);
      expect(Stat.parse('智力'), Stat.intel);
      expect(Stat.parse('??'), isNull);
      expect(Stat.parseList('str,spi,nope'), [Stat.str, Stat.spi]);
    });
  });

  group('stats', () {
    test('grow with the XP of matching quests, slower over time', () {
      final small = computeStats(
        xpByQuest: {10: 100},
        questIndex: index,
        perfectDays: 0,
        rules: rules,
      );
      final big = computeStats(
        xpByQuest: {10: 400},
        questIndex: index,
        perfectDays: 0,
        rules: rules,
      );
      expect(small[Stat.intel], 10);
      expect(big[Stat.intel], 15);
      expect(small[Stat.str], 5);
      expect(small.ranked.first, Stat.intel);
    });

    test('a class weighs its stats, more with mastery', () {
      final mage = HeroClass(name: '法師', stats: [Stat.intel], since: monday);
      int intel(int tier) => computeStats(
        xpByQuest: {10: 400},
        questIndex: index,
        perfectDays: 0,
        heroClass: mage,
        masteryTier: tier,
        rules: rules,
      )[Stat.intel];
      expect(intel(0), greaterThan(15));
      expect(intel(5), greaterThan(intel(0)));
    });

    test('luck comes from perfect days', () {
      final s = computeStats(
        xpByQuest: const {},
        questIndex: index,
        perfectDays: 10,
        rules: rules,
      );
      expect(s[Stat.luk], 10);
    });
  });

  group('perfect days', () {
    test('need every daily quest done and every seal held', () {
      final checkIns = [
        checkIn(monday),
        checkIn(monday, habitId: 2, outcome: CheckInOutcome.resisted),
        checkIn(monday.addDays(1)),
        checkIn(monday.addDays(2), outcome: CheckInOutcome.partial),
        checkIn(
          monday.addDays(2),
          habitId: 2,
          outcome: CheckInOutcome.resisted,
        ),
      ];
      expect(
        countPerfectDays(
          active: [reading, seal],
          checkIns: checkIns,
          today: monday.addDays(2),
        ),
        1,
      );
    });
  });

  test('daily completion counts partials half and marks perfect days', () {
    final levels = dailyCompletion(
      active: [reading, seal],
      checkIns: [
        checkIn(monday),
        checkIn(monday, habitId: 2, outcome: CheckInOutcome.resisted),
        checkIn(monday.addDays(1), outcome: CheckInOutcome.partial),
      ],
      from: monday.addDays(-1),
      today: monday.addDays(2),
    );
    expect(levels.containsKey(monday.addDays(-1)), isFalse);
    expect(levels[monday], 1);
    expect(levels[monday.addDays(1)], 0.25);
    expect(levels[monday.addDays(2)], 0);
  });

  group('class', () {
    final mage = HeroClass(name: '法師', stats: [Stat.intel], since: monday);

    test('mastery counts matching commissions since taking it', () {
      final m = computeMastery(
        heroClass: mage,
        checkIns: [
          ...daily(monday.addDays(-3), 25),
          ...daily(monday, 25, habitId: 2, outcome: CheckInOutcome.resisted),
        ],
        questIndex: index,
        rules: rules,
      );
      expect(m.count, 22);
      expect(m.tier, 1);
      expect(m.nextAt, 50);
    });

    test('pays a little more XP for its own stats only', () {
      expect(
        classXpMultiplier(
          heroClass: mage,
          attribute: Stat.intel,
          masteryTier: 2,
          rules: rules,
        ),
        closeTo(1.07, 1e-9),
      );
      expect(
        classXpMultiplier(
          heroClass: mage,
          attribute: Stat.str,
          masteryTier: 2,
          rules: rules,
        ),
        1,
      );
    });
  });

  group('guild rank', () {
    GuildProgress guild(Adventurer a, List<CheckIn> c, {int day = 9}) =>
        computeGuild(
          adventurer: a,
          active: [reading, seal],
          checkIns: c,
          questIndex: index,
          today: monday.addDays(day),
          rules: rules,
        );

    final perfect = [
      for (var i = 0; i < 10; i++) ...[
        checkIn(monday.addDays(i)),
        checkIn(
          monday.addDays(i),
          habitId: 2,
          outcome: CheckInOutcome.resisted,
        ),
      ],
    ];

    test('points by quest rank open the trial', () {
      final few = guild(hero(), perfect.take(6).toList());
      expect(few.points, 24);
      expect(few.state, TrialState.none);
      final enough = guild(hero(), perfect);
      expect(enough.points, 80);
      expect(enough.state, TrialState.available);
      expect(enough.canStartTrial, isTrue);
    });

    test('points restart after a promotion', () {
      final g = guild(
        hero(rank: QuestRank.e, rankSince: monday.addDays(7)),
        perfect,
      );
      expect(g.points, 16);
      expect(g.needed, 200);
    });

    test('a trial passes after enough perfect days in a row', () {
      final g = guild(
        hero(rank: QuestRank.e, trialStart: monday.addDays(8)),
        perfect,
      );
      expect(g.trialDays, 2);
      expect(g.state, TrialState.passed);
    });

    test('today still counts while it is not perfect yet', () {
      final g = guild(
        hero(rank: QuestRank.e, trialStart: monday.addDays(9)),
        perfect.take(19).toList(),
      );
      expect(g.state, TrialState.running);
      expect(g.trialDaysDone, 0);
    });

    test('an imperfect past day fails the trial', () {
      final missing = [...perfect]..removeAt(16);
      final g = guild(
        hero(rank: QuestRank.e, trialStart: monday.addDays(8)),
        missing,
      );
      expect(g.state, TrialState.failed);
      expect(g.canStartTrial, isTrue);
    });

    test('each rank allows one more commission, from two at F', () {
      expect(rules.commissionLimit(QuestRank.f), 2);
      expect(rules.commissionLimit(QuestRank.d), 4);
      expect(rules.commissionLimit(QuestRank.sss), 10);
    });

    test('SSS is the top', () {
      final g = guild(hero(rank: QuestRank.sss), perfect);
      expect(g.needed, isNull);
      expect(g.state, TrialState.none);
    });
  });

  test('a curse is lifted only by fully doing the quest', () {
    expect(judgeCurse(checkIn(monday)), CurseOutcome.lifted);
    expect(
      judgeCurse(checkIn(monday, outcome: CheckInOutcome.partial)),
      CurseOutcome.failed,
    );
    expect(judgeCurse(null), CurseOutcome.failed);
  });
}
