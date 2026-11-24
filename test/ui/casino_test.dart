import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/ui/screens/casino/casino_games.dart';
import 'package:habit_quest/ui/screens/casino/casino_screen.dart';

import '../support/app_harness.dart';

void main() {
  /// Demo data, an open bank, 2,000 gold and this week's deck, all before
  /// the first frame.
  Future<void> prepare(AppHarness h) async {
    await h.seed();
    final c = ProviderContainer(overrides: h.overrides);
    await c.read(bankServiceProvider).open(balance: 20000);
    await EconomyRepository(h.db)
        .reward(amount: 2000, source: 'test', ref: 'purse', at: h.clock.now());
    await c.read(townServiceProvider).rollover();
    c.dispose();
  }

  testWidgets('the lobby, then a draw in each of the four games', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const CasinoScreen());
    final c = ProviderScope.containerOf(
      tester.element(find.byType(HabitQuestApp)),
    );
    Future<List<CasinoTicketRow>> drawn() async => [
      for (final t in (await tester.runAsync(
        () => c.read(casinoRepoProvider).tickets(h.today),
      ))!)
        if (t.drawnAt != null) t,
    ];
    Future<void> open(String game) async {
      await tester.tap(find.text(game));
      await h.settle(tester);
      await tester.pump(const Duration(seconds: 1));
    }

    Future<void> back() async {
      await tester.tap(find.text('←'));
      await h.settle(tester);
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.text('大獎還在！'), findsOneWidget);
    expect(find.text('A賞'), findsOneWidget);
    expect(find.text('退費'), findsOneWidget);
    expect(find.textContaining('剩 4／4'), findsOneWidget);
    expect(find.textContaining('一抽 '), findsOneWidget);

    // Slots: one pull, written before the reels stop.
    await open('拉霸');
    await tester.tap(find.textContaining('拉一次'));
    await h.settle(tester);
    var done = await drawn();
    expect(done.single.game, CasinoGame.slots);
    expect(find.textContaining(RegExp('[A-D]賞！|退費！')), findsOneWidget);
    await back();

    // Grid: a square picked draws that square's ticket.
    await open('格子抽獎');
    await tester.tap(find.text('?').first);
    await h.settle(tester);
    done = await drawn();
    expect(done, hasLength(2));
    expect(done.where((t) => t.game == CasinoGame.grid), hasLength(1));
    expect(find.textContaining(RegExp('[A-D]賞！|退費！')), findsOneWidget);

    // Five at once, listed in a dialog.
    await tester.tap(find.text('連抽 5'));
    await h.settle(tester);
    expect(find.text('連抽 5 次'), findsOneWidget);
    expect(await drawn(), hasLength(7));
    await tester.tap(find.text('收下'));
    await h.settle(tester);
    await back();

    // Scratch card: bought, then scratched off in one go.
    await open('刮刮樂');
    await tester.tap(find.textContaining('買一張（'));
    await h.settle(tester);
    expect(find.text('一口氣刮開'), findsOneWidget);
    // The button that just changed under the finger waits a moment.
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('一口氣刮開'));
    await h.settle(tester);
    expect(find.textContaining(RegExp('[A-D]賞！|退費！')), findsOneWidget);
    expect(
      (await drawn()).where((t) => t.game == CasinoGame.scratch),
      hasLength(1),
    );
    await back();

    // Chests: the one picked is drawn; the other two stay in the deck.
    await open('寶箱三選一');
    expect(find.text('？'), findsNWidgets(3));
    await tester.tap(find.text('？').first);
    await h.settle(tester);
    expect(
      (await drawn()).where((t) => t.game == CasinoGame.chest),
      hasLength(1),
    );
    expect(await drawn(), hasLength(9));
    expect(find.text('其他寶箱裡裝的是……'), findsOneWidget);
    await tester.tap(find.text('再挑一次'));
    await h.settle(tester);
    expect(find.text('？'), findsNWidgets(3));
    await back();

    // The board counts what is gone.
    final left = (await tester.runAsync(
      () => c.read(casinoRepoProvider).tickets(h.today),
    ))!.where((t) => t.drawnAt == null).length;
    expect(left, greaterThan(0));
    await h.dispose(tester);
  });

  testWidgets('scratching the card does not drag the page', (tester) async {
    // iOS lets a page that fits on screen be dragged and bounce back.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const ScratchScreen());
    await tester.tap(find.textContaining('買一張（'));
    await h.settle(tester);
    final hint = tester.getTopLeft(find.textContaining('用手指刮開銀漆'));
    final scroll = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;

    // Down the middle of the card, then back up.
    final gesture = await tester.startGesture(Offset(200, hint.dy - 170));
    for (final dy in const <double>[20, 20, 20, 20, -40, -40]) {
      await gesture.moveBy(Offset(0, dy));
      await tester.pump(const Duration(milliseconds: 16));
      expect(scroll.pixels, 0, reason: 'the page stays put');
    }
    await gesture.up();
    await h.settle(tester);
    expect(scroll.pixels, 0);
    // The strokes scratched: a few more open the whole card.
    for (final x in const <double>[60, 120, 180, 240, 300, 340]) {
      await tester.timedDragFrom(
        Offset(x, hint.dy - 200),
        const Offset(0, 180),
        const Duration(milliseconds: 300),
      );
      await tester.pump();
    }
    await h.settle(tester);
    expect(find.text('一口氣刮開'), findsNothing);
    expect(find.textContaining(RegExp('[A-D]賞！|退費！')), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
    await h.dispose(tester);
  });

  testWidgets('without a bank the casino points there', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const CasinoScreen());
    expect(find.text('還沒有獎池'), findsOneWidget);
    expect(find.text('去銀行'), findsOneWidget);
    await h.dispose(tester);
  });
}
