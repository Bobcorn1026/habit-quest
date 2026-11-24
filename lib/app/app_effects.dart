import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_providers.dart';
import 'board.dart';
import 'chapter_service.dart';
import 'focus_service.dart';
import 'game_service.dart';
import 'notion_sync.dart';
import 'price_service.dart';
import 'providers.dart';
import 'reminders.dart';
import 'town_service.dart';

/// Work that follows the board whatever screen is showing: upgrade offers,
/// curses whose day ended, the daily reminder, writing a due chapter when an
/// API is set up, and turning the town's weeks over. It sits above the app because Riverpod pauses
/// listeners on covered routes (e.g. the board while settings is open).
class AppEffects extends ConsumerStatefulWidget {
  const AppEffects({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppEffects> createState() => _AppEffectsState();
}

class _AppEffectsState extends ConsumerState<AppEffects> {
  // Back from the background: catch up with the day at once, which also
  // re-plans reminders before the minute timer would.
  late final _lifecycle = AppLifecycleListener(
    // A running focus session waits to see whether the player comes back.
    onHide: () => ref.read(focusProvider.notifier).hidden(),
    onResume: () {
      ref.read(todayProvider.notifier).refresh();
      ref.read(townServiceProvider).rollover();
      ref.read(focusProvider.notifier).returned();
      ref.read(notionSyncProvider).sync();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    // The town's weeks turn over at start-up, on each new day, and once
    // there is an adventurer.
    ref.listenManual(
      townRolloverTriggerProvider,
      (_, _) => ref.read(townServiceProvider).rollover(),
      fireImmediately: true,
    );
    // The Notion ledger catches up at start-up and on each return.
    ref.read(notionSyncProvider).sync();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Chapters already tried in the background this session.
  final _autoTried = <int>{};

  Future<void> _autoWrite(ChapterPlan plan) async {
    if (!_autoTried.add(plan.number)) return;
    final writing = ref.read(autoWritingProvider.notifier);
    writing.set(true);
    try {
      await ref
          .read(chapterServiceProvider)
          .autoWrite(ref.read(aiServiceProvider));
    } finally {
      if (mounted) writing.set(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // With an API set up, a finished period's chapter is written as soon as
    // the app sees it is due.
    // (It starts out null while chapters load, so the first plan arrives
    // as a change.)
    ref.listen(chapterDueProvider, (_, plan) {
      if (plan != null) _autoWrite(plan);
    });
    ref.listen(boardProvider, (prev, next) {
      final entries = next.value?.entries;
      if (entries == null) return;
      final game = ref.read(gameServiceProvider);
      game.syncOffers(entries);
      game.settleCurses(entries);
    });
    ref.watch(reminderSyncProvider);
    // Fixes this week's price level as soon as the app is open in it.
    ref.listen(priceLevelProvider, (_, _) {});
    // The focus timer lives as long as the app: it ends sessions an earlier
    // launch left running, and a break ends wherever the player is.
    ref.listen(focusProvider.select((s) => s.phase), (_, _) {});
    return widget.child;
  }
}
