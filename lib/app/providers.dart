import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/bank_repository.dart';
import '../data/casino_repository.dart';
import '../data/check_in_repository.dart';
import '../data/database.dart';
import '../data/economy_repository.dart';
import '../data/focus_repository.dart';
import '../data/habit_repository.dart';
import '../data/price_repository.dart';
import '../data/settings_repository.dart';
import '../data/story_repository.dart';
import '../domain/adventurer.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/story_config.dart';
import '../domain/upgrade_offer.dart';
import '../game/blessing.dart';
import '../game/game_rules.dart';
import '../game/progression.dart';
import '../game/side_quests.dart';
import '../game/shop.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});

/// The time; a debug build can move it forward from the settings page.
final clockProvider = Provider<Clock>(
  (ref) => kDebugMode ? AdjustableClock() : const SystemClock(),
);

/// Chance in the town (the casino later); tests pin the seed.
final randomProvider = Provider<math.Random>((ref) => math.Random());
final gameRulesProvider = Provider<GameRules>((ref) => const GameRules());

final adventurerRepoProvider = Provider(
  (ref) => AdventurerRepository(ref.watch(databaseProvider)),
);
final habitRepoProvider = Provider(
  (ref) => HabitRepository(ref.watch(databaseProvider)),
);
final checkInRepoProvider = Provider(
  (ref) => CheckInRepository(ref.watch(databaseProvider)),
);
final storyRepoProvider = Provider(
  (ref) => StoryRepository(ref.watch(databaseProvider)),
);
final economyRepoProvider = Provider(
  (ref) => EconomyRepository(ref.watch(databaseProvider)),
);
final settingsRepoProvider = Provider(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);
final priceRepoProvider = Provider(
  (ref) => PriceRepository(ref.watch(databaseProvider)),
);
final focusRepoProvider = Provider(
  (ref) => FocusRepository(ref.watch(databaseProvider)),
);
final bankRepoProvider = Provider(
  (ref) => BankRepository(ref.watch(databaseProvider)),
);
final casinoRepoProvider = Provider(
  (ref) => CasinoRepository(ref.watch(databaseProvider)),
);

/// The current logical day; re-checked every minute so the board rolls over
/// at the day-start hour while the app stays open.
final todayProvider = NotifierProvider<TodayNotifier, LogicalDay>(
  TodayNotifier.new,
);

class TodayNotifier extends Notifier<LogicalDay> {
  @override
  LogicalDay build() {
    final timer = Timer.periodic(const Duration(minutes: 1), (_) => refresh());
    ref.onDispose(timer.cancel);
    return _compute();
  }

  LogicalDay _compute() => LogicalDay.of(
    ref.read(clockProvider).now(),
    dayStartHour: ref.read(gameRulesProvider).dayStartHour,
  );

  void refresh() {
    final next = _compute();
    if (next != state) state = next;
  }
}

final adventurerProvider = StreamProvider<Adventurer?>(
  (ref) => ref.watch(adventurerRepoProvider).watch(),
);

final activeQuestsProvider = StreamProvider<List<ActiveQuest>>(
  (ref) => ref.watch(habitRepoProvider).watchActive(),
);

/// How far back the board looks for streaks and staleness.
const kHistoryDays = 400;

final recentCheckInsProvider = StreamProvider<List<CheckIn>>((ref) {
  final today = ref.watch(todayProvider);
  return ref
      .watch(checkInRepoProvider)
      .watchBetween(today.addDays(-kHistoryDays), today);
});

/// Every quest tier's stat and rank, archived habits included.
final questIndexProvider = StreamProvider<Map<int, QuestInfo>>(
  (ref) => ref.watch(habitRepoProvider).watchQuestIndex(),
);

/// Lifetime check-in XP per quest tier.
final xpByQuestProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(checkInRepoProvider).watchXpByQuest(),
);

final goldProvider = StreamProvider<int>(
  (ref) => ref.watch(economyRepoProvider).watchBalance(),
);

/// Shop items bought so far.
final ownedProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(economyRepoProvider).watchOwned(),
);

/// Days booked at the inn (rest days), past and future.
final restDaysProvider = StreamProvider<Set<LogicalDay>>(
  (ref) => ref.watch(economyRepoProvider).watchBookedDays(),
);

final totalXpProvider = StreamProvider<int>(
  (ref) => ref.watch(checkInRepoProvider).watchTotalXp(),
);

final chaptersProvider = StreamProvider<List<Chapter>>(
  (ref) => ref.watch(storyRepoProvider).watchAll(),
);

final openOffersProvider = StreamProvider<List<UpgradeOffer>>(
  (ref) => ref.watch(storyRepoProvider).watchOpenOffers(),
);

/// The chapter-choice blessing in force today, if any.
final blessingProvider = Provider<ActiveBlessing?>((ref) {
  final chapters = ref.watch(chaptersProvider).value;
  final config = ref.watch(storyConfigProvider).value;
  if (chapters == null || config == null) return null;
  return activeBlessing(
    chapters: chapters,
    today: ref.watch(todayProvider),
    periodDays: config.periodDays,
  );
});

/// This period's side quest from the last chapter, with its progress.
final sideQuestProvider = Provider<ActiveSideQuest?>((ref) {
  final chapters = ref.watch(chaptersProvider).value;
  final config = ref.watch(storyConfigProvider).value;
  final checkIns = ref.watch(recentCheckInsProvider).value;
  final active = ref.watch(activeQuestsProvider).value;
  final index = ref.watch(questIndexProvider).value;
  if (chapters == null ||
      config == null ||
      checkIns == null ||
      active == null ||
      index == null) {
    return null;
  }
  return activeSideQuest(
    chapters: chapters,
    today: ref.watch(todayProvider),
    periodDays: config.periodDays,
    checkIns: checkIns,
    active: active,
    questIndex: index,
  );
});

final storyConfigProvider = StreamProvider<StoryConfig>(
  (ref) => ref.watch(settingsRepoProvider).watchStoryConfig(),
);

/// Curses judged since the board last showed them.
final curseNewsProvider = StreamProvider<List<CurseNews>>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.curseNews)
      .map(
        (v) => [
          for (final n in v is List ? v : const [])
            if (n is Map)
              (
                quest: '${n['quest'] ?? ''}',
                lifted: n['lifted'] == true,
                penalty: (n['penalty'] as num?)?.toInt() ?? 0,
              ),
        ],
      ),
);

final equippedProvider = StreamProvider<Equipped>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.equipped)
      .map(Equipped.fromJson),
);

final onboardedProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.onboarded)
      .map((v) => v == true),
);

/// Story pages in the pixel font (default) or the system font.
final storyPixelFontProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.storyFont)
      .map((v) => v != 'system'),
);
