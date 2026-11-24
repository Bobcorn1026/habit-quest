import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/board.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/game/game_rules.dart';
import 'package:habit_quest/game/stacking.dart';
import 'package:habit_quest/game/xp.dart';

import '../support/builders.dart';

void main() {
  const today = LogicalDay(2026, 11, 9);

  group('anchorWouldCycle', () {
    test('a habit cannot anchor to itself', () {
      expect(anchorWouldCycle(1, 1, const {}), isTrue);
    });

    test('A after B after A is rejected, also through a longer chain', () {
      expect(anchorWouldCycle(1, 2, {2: 1}), isTrue);
      expect(anchorWouldCycle(1, 3, {3: 2, 2: 1}), isTrue);
    });

    test('a plain chain, or an unrelated loop, is fine', () {
      expect(anchorWouldCycle(1, 2, {2: 3, 3: null}), isFalse);
      expect(anchorWouldCycle(1, 2, {2: 3, 3: 2}), isFalse);
    });
  });

  group('board', () {
    ActiveQuest quest(
      int id, {
      int? anchorId,
      String? text,
      HabitKind kind = HabitKind.build,
    }) {
      final h = buildHabit(id: id, kind: kind);
      return ActiveQuest(
        Habit(
          id: id,
          kind: kind,
          name: '習慣$id',
          firstDay: h.firstDay,
          createdAt: h.createdAt,
          anchorHabitId: anchorId,
          anchorText: text,
        ),
        buildQuest(habitId: id, rank: QuestRank.f, target: null),
      );
    }

    BoardEntry entry(ActiveQuest aq, {CheckInOutcome? reported}) => buildEntry(
      active: aq,
      checkIns: [
        if (reported != null)
          checkIn(today, habitId: aq.habit.id, outcome: reported),
      ],
      today: today,
      rules: const GameRules(),
    );

    test('shows the anchor quest title and the 下一步 tag, order unchanged', () {
      final entries = applyStacks([
        entry(quest(1, anchorId: 2)),
        entry(quest(2), reported: CheckInOutcome.done),
      ]);
      expect(entries.map((e) => e.habit.id), [1, 2]);
      expect(entries[0].anchorLabel, '破譯古代卷軸');
      expect(entries[0].nextStep, isTrue);
      expect(entries[1].anchorLabel, isNull);
    });

    test('no 下一步 until the anchor is reported, or once this is too', () {
      var out = applyStacks([entry(quest(1, anchorId: 2)), entry(quest(2))]);
      expect(out[0].anchorLabel, isNotNull);
      expect(out[0].nextStep, isFalse);

      out = applyStacks([
        entry(quest(1, anchorId: 2), reported: CheckInOutcome.done),
        entry(quest(2), reported: CheckInOutcome.done),
      ]);
      expect(out[0].nextStep, isFalse);
    });

    test('a free-text anchor is shown, never a 下一步', () {
      final out = applyStacks([entry(quest(1, text: '刷完牙'))]);
      expect(out.single.anchorLabel, '刷完牙');
      expect(out.single.nextStep, isFalse);
    });

    test('an archived anchor counts as cleared', () {
      // The anchor is simply not on the board any more.
      final out = applyStacks([entry(quest(1, anchorId: 99))]);
      expect(out.single.anchorLabel, isNull);
      expect(out.single.nextStep, isFalse);
      expect(() => anchorChoices(out, forHabit: 1), returnsNormally);
    });

    test('choices leave out the habit itself, seals and cycles', () {
      final entries = [
        entry(quest(1, anchorId: 2)),
        entry(quest(2)),
        entry(quest(3)),
        entry(quest(4, kind: HabitKind.quit)),
      ];
      final ids = anchorChoices(entries, forHabit: 2).map((c) => c.habitId);
      expect(ids, [3], reason: 'not itself, not 1 (anchored to 2), no seals');
      expect(anchorChoices(entries).map((c) => c.habitId), [1, 2, 3]);
    });

    test('the pending stack for the reminder', () {
      BoardState state(List<BoardEntry> e) => BoardState(
        today: today,
        entries: applyStacks(e),
        level: LevelInfo.fromTotal(0, const GameRules()),
      );
      expect(state([entry(quest(1))]).pendingStack, isNull);

      final byHabit = state([
        entry(quest(1, anchorId: 2)),
        entry(quest(2), reported: CheckInOutcome.done),
      ]).pendingStack!;
      expect(byHabit.anchorIsHabit, isTrue);
      expect(byHabit.cue, '破譯古代卷軸');
      expect(byHabit.line, '破譯古代卷軸完成了嗎？接著習慣1吧');

      final byText = state([entry(quest(1, text: '刷完牙'))]).pendingStack!;
      expect(byText.line, '刷完牙了嗎？接著習慣1吧');

      expect(
        state([entry(quest(1, text: '刷完牙'), reported: CheckInOutcome.done)])
            .pendingStack,
        isNull,
      );
    });
  });
}
