import 'package:flutter/foundation.dart';

import 'stat.dart';

enum SideQuestKind {
  /// Finish one quest this many times.
  questCount,

  /// Have this many perfect days.
  perfectDays,

  /// Hold one seal this many days, with no crack.
  sealClean,

  /// Finish this many commissions of one stat.
  statCount,
}

/// An extra commission handed out by a chapter for the period after it.
@immutable
class SideQuest {
  const SideQuest({
    required this.title,
    this.story = '',
    required this.kind,
    this.habitId,
    this.stat,
    required this.target,
  });

  static SideQuest? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = SideQuestKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    final target = (json['target'] as num?)?.toInt();
    if (kind == null || target == null || target < 1) return null;
    return SideQuest(
      title: (json['title'] as String?) ?? '',
      story: (json['story'] as String?) ?? '',
      kind: kind,
      habitId: (json['habitId'] as num?)?.toInt(),
      stat: Stat.parse(json['stat']),
      target: target,
    );
  }

  final String title;
  final String story;
  final SideQuestKind kind;

  /// The habit for [SideQuestKind.questCount] and [SideQuestKind.sealClean].
  final int? habitId;

  /// The stat for [SideQuestKind.statCount].
  final Stat? stat;
  final int target;

  /// e.g. 「完成『破譯古代卷軸』5 次」; [questTitle] names the habit's quest.
  String goal(String? questTitle) => switch (kind) {
    SideQuestKind.questCount => '完成「${questTitle ?? '指定任務'}」$target 次',
    SideQuestKind.perfectDays => '過 $target 天完美的一天',
    SideQuestKind.sealClean => '「${questTitle ?? '封印'}」守住 $target 天、沒有裂痕',
    SideQuestKind.statCount => '完成 $target 件${stat?.label ?? ''}任務',
  };

  Map<String, Object?> toJson() => {
    'title': title,
    'story': story,
    'kind': kind.name,
    'habitId': ?habitId,
    'stat': ?stat?.code,
    'target': target,
  };
}
