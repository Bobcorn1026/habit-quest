import 'package:flutter/foundation.dart';

import '../game/checks.dart';
import '../game/judgement.dart';
import '../game/period.dart';
import 'side_quest.dart';
import 'stat.dart';

enum ChapterStatus {
  /// The period ended; waiting for the AI (or a pasted reply) to write it.
  pending,
  written,
}

enum BlessingKind { xp, gold, check }

/// What a chapter choice grants during the next period, for quests of one
/// stat: a little more EXP, a coin more per commission, or an easier check.
@immutable
class Blessing {
  const Blessing(this.kind, this.stat);

  static Blessing? fromJson(Object? json) {
    if (json is! Map) return null;
    final kind = BlessingKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    final stat = Stat.parse(json['stat']);
    if (kind == null || stat == null || !stat.isQuestAttribute) return null;
    return Blessing(kind, stat);
  }

  final BlessingKind kind;
  final Stat stat;

  String get label => switch (kind) {
    BlessingKind.xp => '${stat.label}任務 EXP +10%',
    BlessingKind.gold => '${stat.label}任務每件 +1 金幣',
    BlessingKind.check => '${stat.label}檢定比較容易過',
  };

  Map<String, Object?> toJson() => {'kind': kind.name, 'stat': stat.code};

  @override
  bool operator ==(Object other) =>
      other is Blessing && other.kind == kind && other.stat == stat;

  @override
  int get hashCode => Object.hash(kind, stat);
}

@immutable
class StoryChoice {
  const StoryChoice(this.label, {this.hint = '', this.blessing});

  factory StoryChoice.fromJson(Map<String, Object?> json) => StoryChoice(
    (json['label'] as String?) ?? '',
    hint: (json['hint'] as String?) ?? '',
    blessing: Blessing.fromJson(json['blessing']),
  );

  final String label;

  /// Optional flavor about what the choice might lead to.
  final String hint;

  /// Granted for the next period when chosen.
  final Blessing? blessing;

  Map<String, Object?> toJson() => {
    'label': label,
    'hint': hint,
    if (blessing != null) 'blessing': blessing!.toJson(),
  };
}

/// One chapter of the story, covering one period (chapter 0 is the prologue).
@immutable
class Chapter {
  const Chapter({
    required this.id,
    required this.number,
    required this.period,
    required this.status,
    this.title = '',
    this.body = '',
    this.choices = const [],
    this.chosenIndex,
    this.recap = '',
    this.judgement,
    this.score,
    this.checks = const [],
    this.sideQuest,
    required this.createdAt,
  });

  final int id;
  final int number;
  final Period period;
  final ChapterStatus status;
  final String title;
  final String body;
  final List<StoryChoice> choices;
  final int? chosenIndex;

  /// Short memory of this chapter, fed to the next prompt for continuity.
  final String recap;
  final Judgement? judgement;
  final double? score;

  /// Stat checks decided when the period closed.
  final List<StoryCheck> checks;

  /// Handed out for the period after this one.
  final SideQuest? sideQuest;
  final DateTime createdAt;

  StoryChoice? get chosen =>
      chosenIndex != null && chosenIndex! < choices.length
      ? choices[chosenIndex!]
      : null;

  bool get awaitsChoice =>
      status == ChapterStatus.written &&
      choices.isNotEmpty &&
      chosenIndex == null;
}
