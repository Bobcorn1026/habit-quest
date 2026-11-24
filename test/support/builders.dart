import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest.dart';
import 'package:habit_quest/domain/quest_rank.dart';

/// 2026-11-02 is a Monday.
const monday = LogicalDay(2026, 11, 2);

Habit buildHabit({
  int id = 1,
  HabitKind kind = HabitKind.build,
  double? target = 20,
  String? unit = '分鐘',
  int timesPerWeek = 7,
}) => Habit(
  id: id,
  kind: kind,
  name: kind == HabitKind.build ? '讀英文' : '深夜滑手機',
  unit: kind == HabitKind.build ? unit : null,
  target: kind == HabitKind.build ? target : null,
  timesPerWeek: timesPerWeek,
  firstDay: monday,
  createdAt: DateTime(2026, 11, 2, 9),
);

Quest buildQuest({
  int habitId = 1,
  QuestRank rank = QuestRank.c,
  double? target = 20,
  LogicalDay? activeFrom,
}) => Quest(
  id: habitId * 10,
  habitId: habitId,
  tier: 1,
  rank: rank,
  title: '破譯古代卷軸',
  subtitle: '～那些字母在對我低語～',
  target: target,
  activeFrom: activeFrom ?? monday,
);

CheckIn checkIn(
  LogicalDay day, {
  int habitId = 1,
  CheckInOutcome outcome = CheckInOutcome.done,
  double? amount,
  String? note,
}) => CheckIn(
  habitId: habitId,
  questId: habitId * 10,
  day: day,
  outcome: outcome,
  amount: amount,
  note: note,
  createdAt: day.startsAt(),
);

/// Check-ins on [count] consecutive days starting at [from].
List<CheckIn> daily(
  LogicalDay from,
  int count, {
  int habitId = 1,
  CheckInOutcome outcome = CheckInOutcome.done,
  double? amount,
}) => [
  for (var i = 0; i < count; i++)
    checkIn(
      from.addDays(i),
      habitId: habitId,
      outcome: outcome,
      amount: amount,
    ),
];
