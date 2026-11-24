import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/casino_service.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/data/database.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/domain/casino.dart';
import 'package:habit_quest/ui/pixel/pixel.dart';
import 'package:habit_quest/ui/screens/casino/casino_games.dart';
import 'package:habit_quest/ui/screens/casino/casino_widgets.dart';
import 'package:habit_quest/ui/widgets/casino_fx.dart';

import '../support/app_harness.dart';

/// Bugs found in review of the casino screens, each pinned by a test.
void main() {
  Future<void> prepare(AppHarness h) async {
    await h.seed();
    final c = ProviderContainer(overrides: h.overrides);
    await c.read(bankServiceProvider).open(balance: 20000);
    await EconomyRepository(h.db)
        .reward(amount: 2000, source: 'test', ref: 'purse', at: h.clock.now());
    await c.read(townServiceProvider).rollover();
    c.dispose();
  }

  Future<List<CasinoTicketRow>> tickets(AppHarness h) =>
      h.db.select(h.db.casinoTickets).get();

  /// Marks every ticket drawn except those [keep] says.
  Future<void> leaveOnly(
    AppHarness h,
    bool Function(CasinoTicketRow t) keep,
  ) async {
    for (final t in await tickets(h)) {
      if (keep(t)) continue;
      await (h.db.update(h.db.casinoTickets)..where((r) => r.id.equals(t.id)))
          .write(CasinoTicketsCompanion(drawnAt: Value(h.clock.now())));
    }
  }

  final reveal = find.textContaining(RegExp('[A-D]賞！|退費！'));
  final burst = find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter is CoinBurstPainter,
  );

  Future<void> run(WidgetTester tester, Duration total) async {
    for (
      var t = Duration.zero;
      t < total;
      t += const Duration(milliseconds: 50)
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  test('several at once show the best: a refund comes last', () {
    CasinoTicketRow t(int id, PrizeTier? tier, int amount) => CasinoTicketRow(
      id: id,
      weekStart: const LogicalDay(2026, 11, 16),
      kind: tier == null ? TicketKind.refund : TicketKind.prize,
      tier: tier,
      amount: amount,
    );
    expect(
      bestOf([t(1, null, 0), t(2, PrizeTier.low, 5), t(3, PrizeTier.low, 10)])
          .id,
      3,
    );
    expect(
      bestOf([t(1, PrizeTier.low, 5), t(2, PrizeTier.high, 25), t(3, null, 0)])
          .id,
      2,
    );
    expect(bestOf([t(1, null, 0)]).id, 1);
  });

  testWidgets('slots: a top prize after a small one spins, lands and shows', (
    tester,
  ) async {
    final h = AppHarness();
    late int top;
    await tester.runAsync(() async {
      await prepare(h);
      final all = await tickets(h);
      top = all.firstWhere((t) => t.tier == PrizeTier.top).id;
      final low = all.firstWhere((t) => t.tier == PrizeTier.low).id;
      await leaveOnly(h, (t) => t.id == low);
    });
    await h.pump(tester, home: const SlotsScreen());

    await tester.tap(find.textContaining('拉一次（'));
    await h.settle(tester);
    await run(tester, const Duration(seconds: 2));
    expect(find.text('D賞！'), findsOneWidget);

    // The top prize back in the deck, alone.
    await tester.runAsync(
      () => (h.db.update(h.db.casinoTickets)..where((r) => r.id.equals(top)))
          .write(const CasinoTicketsCompanion(drawnAt: Value(null))),
    );
    await h.settle(tester);
    await tester.tap(find.textContaining('拉一次（'));
    await h.settle(tester);
    // While the reels spin, nothing gives the prize away.
    expect(burst, findsNothing, reason: 'no coins before the reels stop');
    await run(tester, const Duration(seconds: 2));
    expect(find.text('A賞！'), findsOneWidget, reason: 'the reels landed');
    await run(tester, const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('slots: iOS reduce motion shows the result at once', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const SlotsScreen());
    await tester.tap(find.textContaining('拉一次（'));
    await h.settle(tester);
    expect(reveal, findsOneWidget);
    expect(burst, findsNothing);
    await h.dispose(tester);
  });

  testWidgets('grid: the result is scrolled into view on a small phone', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const GridScreen());
    // iPhone SE: 375×667 pt.
    tester.view.physicalSize = const Size(1125, 2001);
    await h.settle(tester);

    await tester.tap(find.text('?').first);
    await h.settle(tester);
    await run(tester, const Duration(milliseconds: 500));
    final bottomBar = tester.getTopLeft(find.textContaining('隨機掀一格')).dy;
    final money = find.textContaining(RegExp(r'^\+\d+ 元$|這一抽不收金幣'));
    expect(money, findsOneWidget);
    expect(tester.getBottomLeft(money).dy, lessThan(bottomBar));
    await h.dispose(tester);
  });

  testWidgets('a game page waits while the new week opens', (tester) async {
    final h = AppHarness();
    h.extraOverrides = [
      casinoViewProvider.overrideWith(
        (ref) => Stream.value(
          CasinoView(today: h.today, closed: CasinoClosed.notOpen),
        ),
      ),
    ];
    await tester.runAsync(h.seed);
    for (final page in const [
      GridScreen(),
      SlotsScreen(),
      ScratchScreen(),
      ChestScreen(),
    ]) {
      await h.pump(tester, home: page);
      expect(tester.takeException(), isNull);
      expect(find.text('準備中'), findsOneWidget);
    }
    await h.dispose(tester);
  });

  group('slots: the week turning over mid-pull', () {
    // Stands in for Monday 04:00: the game page shows "準備中" while
    // [closed] is set, then the real view again.
    late ValueNotifier<bool> closed;

    AppHarness harness() {
      closed = ValueNotifier(false);
      final h = AppHarness();
      h.extraOverrides = [
        casinoViewProvider.overrideWith((ref) {
          void poke() => ref.invalidateSelf();
          closed.addListener(poke);
          ref.onDispose(() => closed.removeListener(poke));
          return closed.value
              ? Stream.value(
                  CasinoView(today: h.today, closed: CasinoClosed.notOpen),
                )
              : ref.watch(casinoServiceProvider).watchView();
        }),
      ];
      return h;
    }

    final pull = find.ancestor(
      of: find.textContaining('拉一次（'),
      matching: find.byType(PixelButton),
    );
    bool canPull(WidgetTester tester) =>
        tester.widget<PixelButton>(pull).onPressed != null;

    Future<void> reopen(WidgetTester tester, AppHarness h) async {
      closed.value = false;
      await h.settle(tester);
      await run(tester, const Duration(seconds: 2));
      expect(find.text('準備中'), findsNothing);
      expect(canPull(tester), isTrue, reason: 'the new week can be played');
      expect(reveal, findsOneWidget, reason: 'the paid pull is shown');
    }

    testWidgets('while the reels spin', (tester) async {
      final h = harness();
      await tester.runAsync(() => prepare(h));
      await h.pump(tester, home: const SlotsScreen());
      await tester.tap(pull);
      await h.settle(tester);
      expect(canPull(tester), isFalse, reason: 'spinning');

      closed.value = true;
      await h.settle(tester);
      expect(find.text('準備中'), findsOneWidget);
      await reopen(tester, h);
      await h.dispose(tester);
    });

    testWidgets('before the draw comes back', (tester) async {
      final h = harness();
      await tester.runAsync(() => prepare(h));
      await h.pump(tester, home: const SlotsScreen());
      await tester.tap(pull);
      closed.value = true;
      await tester.pump();
      await h.settle(tester);
      expect(find.text('準備中'), findsOneWidget);
      await reopen(tester, h);
      await h.dispose(tester);
    });
  });

  testWidgets('scratch: a quick double tap opens the card, not a new one', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const ScratchScreen());
    await tester.tap(find.textContaining('買一張（'));
    await h.settle(tester);
    await run(tester, const Duration(seconds: 1));

    final button = tester.getCenter(find.text('一口氣刮開'));
    await tester.tapAt(button);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tapAt(button);
    await h.settle(tester);
    final scratched = (await tester.runAsync(() => tickets(h)))!
        .where((t) => t.game == CasinoGame.scratch);
    expect(scratched, hasLength(1), reason: 'the second tap bought nothing');

    // And the other way round: a double tap on 再買一張 doesn't open the
    // new card unscratched.
    await run(tester, const Duration(seconds: 1));
    final buy = tester.getCenter(find.textContaining('再買一張（'));
    await tester.tapAt(buy);
    await h.settle(tester);
    await tester.tapAt(buy);
    await h.settle(tester);
    expect(find.text('一口氣刮開'), findsOneWidget, reason: 'still covered');
    await run(tester, const Duration(seconds: 1));
    await h.dispose(tester);
  });

  testWidgets('chests: chests that are gone are dealt again', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() => prepare(h));
    await h.pump(tester, home: const ChestScreen());
    Set<int> dealt() => {
      for (final c in tester.widgetList<ChestTile>(find.byType(ChestTile)))
        c.ticket.id,
    };
    final first = dealt();
    expect(first, hasLength(3));

    // The three are drawn elsewhere meanwhile (another game, or the week
    // turned over and they belong to last week's deck).
    await tester.runAsync(() => leaveOnly(h, (t) => !first.contains(t.id)));
    await h.settle(tester);
    await tester.tap(find.byType(ChestTile).first);
    await h.settle(tester);
    expect(find.textContaining('抽完了'), findsNothing);
    final again = dealt();
    expect(again, hasLength(3));
    expect(again.intersection(first), isEmpty);
    expect(
      (await tester.runAsync(() => tickets(h)))!
          .where((t) => t.game == CasinoGame.chest),
      isEmpty,
    );
    await h.dispose(tester);
  });

  String header(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(CasinoHeader),
          matching: find.byType(Text),
        ),
      )
      .map((t) => t.data)
      .join(' | ');

  testWidgets('slots: the header gives nothing away while the reels spin', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await prepare(h);
      await leaveOnly(h, (t) => t.tier == PrizeTier.top);
    });
    await h.pump(tester, home: const SlotsScreen());
    final before = header(tester);
    await tester.tap(find.textContaining('拉一次（'));
    await h.settle(tester);
    expect(header(tester), before, reason: 'gold and prize money still');
    await run(tester, const Duration(seconds: 2));
    expect(find.text('A賞！'), findsOneWidget);
    expect(header(tester), isNot(before), reason: 'landed: the live figures');
    await run(tester, const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('scratch: the header gives nothing away under the foil', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await prepare(h);
      await leaveOnly(h, (t) => t.tier == PrizeTier.top);
    });
    await h.pump(tester, home: const ScratchScreen());
    final before = header(tester);
    await tester.tap(find.textContaining('買一張（'));
    await h.settle(tester);
    await run(tester, const Duration(milliseconds: 600));
    expect(find.text('一口氣刮開'), findsOneWidget);
    expect(header(tester), before, reason: 'gold and prize money still');
    await tester.tap(find.text('一口氣刮開'));
    await h.settle(tester);
    expect(find.text('A賞！'), findsOneWidget);
    expect(header(tester), isNot(before), reason: 'open: the live figures');
    await run(tester, const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('win effects never rebuild the game inside them', (tester) async {
    Widget fx(int shot, FxSize size) => MaterialApp(
      home: WinFx(shot: shot, size: size, child: const _Probe()),
    );
    await tester.pumpWidget(fx(0, FxSize.none));
    final game = tester.state(find.byType(_Probe));
    // A small win, then the top prize: coins, then flash and shake.
    for (final (shot, size) in [(1, FxSize.small), (2, FxSize.jackpot)]) {
      await tester.pumpWidget(fx(shot, size));
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(
          tester.state(find.byType(_Probe)),
          same(game),
          reason: 'shot $shot after ${i * 50} ms',
        );
      }
    }
  });

  testWidgets('chests: a new week deals chests even after none were left', (
    tester,
  ) async {
    final h = AppHarness();
    final start = h.clock.value;
    await tester.runAsync(() async {
      await prepare(h);
      await leaveOnly(h, (_) => false);
      // Next week's deck, dealt now: the page must not write to the
      // database while it watches it.
      h.clock.advance(const Duration(days: 7));
      final c = ProviderContainer(overrides: h.overrides);
      await c.read(townServiceProvider).rollover();
      c.dispose();
      h.clock.value = start;
    });
    await h.pump(tester, home: const ChestScreen());
    await h.settle(tester);
    expect(find.byType(ChestTile), findsNothing);

    // Monday 04:00 with the page open: the day ticks over to the new week.
    h.clock.advance(const Duration(days: 7));
    await tester.pump(const Duration(minutes: 1));
    await h.settle(tester);
    expect(find.byType(ChestTile), findsNWidgets(3));
    await h.dispose(tester);
  }, timeout: const Timeout(Duration(seconds: 60)));
}

class _Probe extends StatefulWidget {
  const _Probe();

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) => const SizedBox(height: 40);
}
