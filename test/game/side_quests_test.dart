import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/domain/side_quest.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/period.dart';
import 'package:habit_quest/game/side_quests.dart';

import '../support/builders.dart';

void main() {
  final reading = ActiveQuest(buildHabit(), buildQuest());
  final seal = ActiveQuest(
    buildHabit(id: 2, kind: HabitKind.quit),
    buildQuest(habitId: 2),
  );
  final index = <int, QuestInfo>{
    10: (attribute: Stat.intel, rank: QuestRank.c),
    20: (attribute: Stat.spi, rank: QuestRank.c),
  };

  ActiveSideQuest? side(SideQuest q, List<CheckIn> c, {int today = 10}) =>
      activeSideQuest(
        chapters: [
          Chapter(
            id: 5,
            number: 1,
            period: Period(monday, 7),
            status: ChapterStatus.written,
            sideQuest: q,
            createdAt: DateTime(2026, 11, 9),
          ),
        ],
        today: monday.addDays(today),
        periodDays: 7,
        checkIns: c,
        active: [reading, seal],
        questIndex: index,
      );

  final week2 = [
    ...daily(monday.addDays(7), 4),
    ...daily(
      monday.addDays(7),
      4,
      habitId: 2,
      outcome: CheckInOutcome.resisted,
    ),
  ];

  test('counts only inside the period after the chapter', () {
    const q = SideQuest(
      title: '加練',
      kind: SideQuestKind.questCount,
      habitId: 1,
      target: 3,
    );
    final s = side(q, [...daily(monday, 7), ...week2])!;
    expect(s.progress, 4);
    expect(s.done, isTrue);
    expect(s.rewardRef, 'chapter-5');
    expect(side(q, week2, today: 14), isNull, reason: 'window is over');
    expect(side(q, week2, today: 6), isNull, reason: 'not started yet');
  });

  test('perfect days, stat counts and clean seals', () {
    expect(
      side(
        const SideQuest(title: '', kind: SideQuestKind.perfectDays, target: 5),
        week2,
      )!.progress,
      4,
    );
    expect(
      side(
        const SideQuest(
          title: '',
          kind: SideQuestKind.statCount,
          stat: Stat.spi,
          target: 5,
        ),
        week2,
      )!.progress,
      4,
    );
    final cracked = side(
      const SideQuest(
        title: '',
        kind: SideQuestKind.sealClean,
        habitId: 2,
        target: 7,
      ),
      [
        ...week2,
        checkIn(
          monday.addDays(11),
          habitId: 2,
          outcome: CheckInOutcome.relapsed,
        ),
      ],
      today: 11,
    )!;
    expect(cracked.failed, isTrue);
    expect(cracked.done, isFalse);
  });
}
