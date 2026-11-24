import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_tasks.dart';
import '../ai/template_writer.dart';
import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/habit_repository.dart';
import '../data/settings_repository.dart';
import '../data/story_repository.dart';
import '../domain/hero_class.dart';
import '../domain/story_config.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import 'providers.dart';

/// Turns habits typed by the player into saved quests.
class AdventureService {
  AdventureService({
    required this.clock,
    required this.rules,
    required this.adventurers,
    required this.habits,
    required this.story,
    required this.settings,
  });

  final Clock clock;
  final GameRules rules;
  final AdventurerRepository adventurers;
  final HabitRepository habits;
  final StoryRepository story;
  final SettingsRepository settings;

  LogicalDay get today =>
      LogicalDay.of(clock.now(), dayStartHour: rules.dayStartHour);

  /// Keys `h1`, `h2`… in draft order.
  static List<ForgeHabit> forgeHabits(List<HabitDraft> drafts) => [
    for (final (i, d) in drafts.indexed)
      ForgeHabit(
        key: 'h${i + 1}',
        kind: d.kind,
        name: d.name,
        unit: d.unit,
        target: d.target,
        timesPerWeek: d.timesPerWeek,
        intention: d.intention,
      ),
  ];

  Future<WorldBible?> world() async {
    final raw = await settings.read(SettingKeys.worldBible);
    return raw is Map ? WorldBible.fromJson(raw.cast<String, Object?>()) : null;
  }

  Future<ForgeRequest> forgeRequest({
    required String heroName,
    String? identity,
    required List<HabitDraft> drafts,
    required StoryConfig config,
    required bool withPrologue,
  }) async => ForgeRequest(
    requestId: newRequestId(),
    heroName: heroName,
    identity: identity,
    habits: forgeHabits(drafts),
    config: config,
    withPrologue: withPrologue,
    world: withPrologue ? null : await world(),
  );

  QuestDraft _questDraft(HabitDraft d, ForgedQuest? q, ForgeHabit fh) {
    final quest =
        q ??
        TemplateWriter.forge(
          ForgeRequest(
            requestId: '',
            heroName: '',
            habits: [fh],
            config: const StoryConfig(),
          ),
        ).quests.single;
    return QuestDraft(
      rank: quest.rank,
      title: quest.title,
      subtitle: quest.subtitle,
      flavor: quest.flavor,
      spriteId: quest.spriteId,
      target: d.target,
      attribute: quest.attribute,
    );
  }

  /// Saves the new adventurer, their quests, the world and the prologue.
  Future<void> begin({
    required String heroName,
    String? identity,
    required List<HabitDraft> drafts,
    required ForgeResult forged,
  }) async {
    final now = clock.now();
    final day = today;
    final id = await adventurers.create(
      name: heroName,
      identity: identity,
      now: now,
    );
    // The class is appraised in week 2, from what the quests train.
    await adventurers.updateClassAndTitle(id, heroClass: kNoviceClass);
    await _saveHabits(drafts, forged);
    if (forged.world != null) {
      await settings.write(SettingKeys.worldBible, forged.world!.toJson());
    }
    final prologue = forged.prologue;
    if (prologue != null) {
      // A zero-length period: chapter 1 starts on the first day.
      final pending = await story.createPending(
        number: 0,
        period: Period(day, 0),
        judgement: null,
        score: null,
        stats: const {},
        now: now,
      );
      await story.write(pending.id, prologue, now: now);
    }
    await settings.write(SettingKeys.onboarded, true);
  }

  /// Adds habits later in the adventure.
  Future<void> addHabits(List<HabitDraft> drafts, ForgeResult forged) =>
      _saveHabits(drafts, forged);

  Future<void> _saveHabits(List<HabitDraft> drafts, ForgeResult forged) async {
    final keyed = forgeHabits(drafts);
    for (final (i, d) in drafts.indexed) {
      await habits.create(
        d,
        _questDraft(d, forged.questFor(keyed[i].key), keyed[i]),
        now: clock.now(),
        today: today,
      );
    }
  }
}

final adventureServiceProvider = Provider<AdventureService>(
  (ref) => AdventureService(
    clock: ref.watch(clockProvider),
    rules: ref.watch(gameRulesProvider),
    adventurers: ref.watch(adventurerRepoProvider),
    habits: ref.watch(habitRepoProvider),
    story: ref.watch(storyRepoProvider),
    settings: ref.watch(settingsRepoProvider),
  ),
);
