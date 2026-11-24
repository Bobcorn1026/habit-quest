import 'package:flutter/foundation.dart';

import '../core/logical_day.dart';
import '../data/habit_repository.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/side_quest.dart';
import 'progression.dart';

/// The side quest from the latest chapter that has one, with its window
/// (the period after that chapter) and progress so far.
@immutable
class ActiveSideQuest {
  const ActiveSideQuest({
    required this.quest,
    required this.chapterId,
    required this.from,
    required this.until,
    required this.progress,
    this.failed = false,
  });

  final SideQuest quest;
  final int chapterId;
  final LogicalDay from;

  /// Last day to finish it.
  final LogicalDay until;
  final int progress;

  /// A seal cracked, so this one can't be finished any more.
  final bool failed;

  bool get done => progress >= quest.target;

  /// Key for its one-time reward.
  String get rewardRef => 'chapter-$chapterId';
}

ActiveSideQuest? activeSideQuest({
  required List<Chapter> chapters,
  required LogicalDay today,
  required int periodDays,
  required List<CheckIn> checkIns,
  required List<ActiveQuest> active,
  required Map<int, QuestInfo> questIndex,
}) {
  final withQuest =
      chapters
          .where(
            (c) => c.status == ChapterStatus.written && c.sideQuest != null,
          )
          .toList()
        ..sort((a, b) => b.number.compareTo(a.number));
  final latest = withQuest.firstOrNull;
  if (latest == null) return null;
  final from = latest.period.endExclusive;
  final until = from.addDays(periodDays - 1);
  if (today.isBefore(from) || today.isAfter(until)) return null;

  final q = latest.sideQuest!;
  final inWindow = checkIns
      .where((c) => !c.day.isBefore(from) && !c.day.isAfter(until))
      .toList();
  var failed = false;
  final progress = switch (q.kind) {
    SideQuestKind.questCount =>
      inWindow.where((c) => c.habitId == q.habitId && counts(c)).length,
    SideQuestKind.statCount =>
      inWindow
          .where((c) => counts(c) && questIndex[c.questId]?.attribute == q.stat)
          .length,
    SideQuestKind.perfectDays => () {
      final index = indexCheckIns(inWindow);
      var n = 0;
      for (var d = from; !d.isAfter(today); d = d.addDays(1)) {
        if (isPerfectDay(d, active, index)) n++;
      }
      return n;
    }(),
    SideQuestKind.sealClean => () {
      final mine = inWindow.where((c) => c.habitId == q.habitId);
      failed = mine.any((c) => c.outcome == CheckInOutcome.relapsed);
      return failed
          ? 0
          : mine.where((c) => c.outcome == CheckInOutcome.resisted).length;
    }(),
  };
  return ActiveSideQuest(
    quest: q,
    chapterId: latest.id,
    from: from,
    until: until,
    progress: progress,
    failed: failed,
  );
}
