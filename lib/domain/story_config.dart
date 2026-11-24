import 'package:flutter/foundation.dart';

enum StoryInteraction {
  /// Each chapter ends with choices that shape the next one.
  choices,

  /// Pure narration, no choices.
  narration,
}

enum StoryTone {
  epic('中二沉浸'),
  playful('會心一笑'),
  mixed('混搭');

  const StoryTone(this.label);
  final String label;
}

/// How the story advances. Persisted, so nothing here is hard-coded in
/// screens or prompts.
@immutable
class StoryConfig {
  const StoryConfig({
    this.periodDays = 7,
    this.choicesPerChapter = 3,
    this.interaction = StoryInteraction.choices,
    this.tone = StoryTone.mixed,
    this.world = '中世紀劍與魔法',
  });

  factory StoryConfig.fromJson(Map<String, Object?> json) {
    const d = StoryConfig();
    T pick<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.where((v) => v.name == raw).firstOrNull ?? fallback;
    return StoryConfig(
      periodDays:
          (json['periodDays'] as num?)?.toInt().clamp(1, 28) ?? d.periodDays,
      choicesPerChapter:
          (json['choicesPerChapter'] as num?)?.toInt().clamp(2, 4) ??
          d.choicesPerChapter,
      interaction: pick(
        StoryInteraction.values,
        json['interaction'],
        d.interaction,
      ),
      tone: pick(StoryTone.values, json['tone'], d.tone),
      world: (json['world'] as String?)?.trim().isNotEmpty == true
          ? json['world'] as String
          : d.world,
    );
  }

  final int periodDays;
  final int choicesPerChapter;
  final StoryInteraction interaction;
  final StoryTone tone;

  /// Free-text world setting fed to the AI.
  final String world;

  Map<String, Object?> toJson() => {
    'periodDays': periodDays,
    'choicesPerChapter': choicesPerChapter,
    'interaction': interaction.name,
    'tone': tone.name,
    'world': world,
  };

  StoryConfig copyWith({
    int? periodDays,
    int? choicesPerChapter,
    StoryInteraction? interaction,
    StoryTone? tone,
    String? world,
  }) => StoryConfig(
    periodDays: periodDays ?? this.periodDays,
    choicesPerChapter: choicesPerChapter ?? this.choicesPerChapter,
    interaction: interaction ?? this.interaction,
    tone: tone ?? this.tone,
    world: world ?? this.world,
  );
}
