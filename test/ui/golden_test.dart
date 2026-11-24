import 'package:habit_quest/domain/check_in.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/app/bank_service.dart';
import 'package:habit_quest/app/town_service.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/ui/screens/bank/bank_screen.dart';
import 'package:habit_quest/ui/screens/casino/casino_games.dart';
import 'package:habit_quest/ui/screens/casino/casino_screen.dart';
import 'package:habit_quest/ui/screens/dev/kit_gallery.dart';
import 'package:habit_quest/ui/screens/shop/shop_screen.dart';
import 'package:habit_quest/ui/widgets/celebration.dart';

import '../support/app_harness.dart';

/// Screen regressions for the approved pixel style. Only refresh these with
/// `flutter test --update-goldens` after the new look has been approved.
void main() {
  const phone = Size(1206, 2622);

  Future<void> matches(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );

  testWidgets('board, seals, check-in sheet and hero tab', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    tester.view.physicalSize = phone;
    await tester.pump();
    await matches('board');

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1300));
    await tester.pump();
    await matches('board_seals');

    await tester.tap(find.text('完成').first);
    await h.settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await matches('check_in_sheet');
    await tester.tapAt(const Offset(200, 100));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('角色'));
    await h.settle(tester);
    await matches('hero');
    await h.dispose(tester);
  });

  testWidgets('habit stacking on the board', (tester) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      final habits = HabitRepository(h.db);
      final active = await habits.active();
      ActiveQuest named(String n) =>
          active.firstWhere((a) => a.habit.name == n);
      final english = named('讀英文');
      await habits.setAnchor(
        named('寫日記').habit.id,
        anchorHabitId: english.habit.id,
      );
      await habits.setAnchor(named('運動').habit.id, anchorText: '下班回家');
      await CheckInRepository(h.db).upsert(
        CheckIn(
          habitId: english.habit.id,
          questId: english.quest.id,
          day: h.today,
          outcome: CheckInOutcome.done,
          createdAt: DateTime(2026, 11, 9, 8),
        ),
      );
    });
    await h.pump(tester);
    tester.view.physicalSize = phone;
    await tester.pump();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pump();
    await matches('board_stacking');
    await h.dispose(tester);
  });

  testWidgets('guild shop', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const ShopScreen());
    tester.view.physicalSize = phone;
    await tester.pump();
    await matches('shop');
    await h.dispose(tester);
  });

  testWidgets('town tab and idle training ground', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    tester.view.physicalSize = phone;
    await tester.pump();
    await tester.tap(find.text('城鎮').last);
    await h.settle(tester);
    await matches('town');

    await tester.tap(find.text('修練場'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    await matches('focus');
    await h.dispose(tester);
  });

  testWidgets('bank and its expense sheet', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const BankScreen());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HabitQuestApp)),
    );
    await tester.runAsync(() => container.read(bankServiceProvider).openDemo());
    await h.settle(tester);
    tester.view.physicalSize = phone;
    await tester.pump();
    await matches('bank');

    await tester.tap(find.text('記支出'));
    await h.settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await matches('bank_expense_sheet');
    await h.dispose(tester);
  });

  testWidgets('casino lobby, slots result and chests', (tester) async {
    // The reels land and the chests open at once; the effects stay still.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      final c = ProviderContainer(overrides: h.overrides);
      await c.read(bankServiceProvider).open(balance: 20000);
      await EconomyRepository(
        h.db,
      ).reward(amount: 2000, source: 'test', ref: 'purse', at: h.clock.now());
      await c.read(townServiceProvider).rollover();
      c.dispose();
    });
    Future<void> open(Widget page) async {
      await h.pump(tester, home: page);
      tester.view.physicalSize = phone;
      await h.settle(tester);
    }

    await open(const CasinoScreen());
    await matches('casino');

    await open(const SlotsScreen());
    await tester.tap(find.textContaining('拉一次（'));
    await h.settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await matches('casino_slots');

    await open(const ChestScreen());
    await tester.tap(find.byType(ChestTile).first);
    await h.settle(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await matches('casino_chest');
    await h.dispose(tester);
  });

  testWidgets('kit gallery', (tester) async {
    final h = AppHarness();
    await h.pump(tester, home: const KitGallery());
    tester.view.physicalSize = phone;
    await tester.pump();
    await matches('kit');
    await h.dispose(tester);
  });

  testWidgets('onboarding greeting, mentor tip and celebration', (
    tester,
  ) async {
    final h = AppHarness();
    await h.pump(tester);
    tester.view.physicalSize = phone;
    await tester.tap(find.text('跳過 »'));
    await h.settle(tester);
    await matches('onboarding');

    await tester.pumpWidget(const SizedBox());
    final t = AppHarness()..showTips = true;
    await tester.runAsync(t.seed);
    await t.pump(tester);
    tester.view.physicalSize = phone;
    await tester.tap(find.text('跳過 »'));
    await t.settle(tester);
    await matches('mentor_tip');
    await tester.pumpWidget(const SizedBox());
    await t.dispose(tester);

    final c = AppHarness();
    await tester.runAsync(c.seed);
    await c.pump(tester);
    tester.view.physicalSize = phone;
    await tester.pump();
    showCelebration(
      tester.element(find.byType(Scaffold).first),
      title: '等級提升！',
      detail: 'Lv.9 → Lv.10',
      lines: const ['恭喜！亞倫 升到 Lv.10 了！'],
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await matches('celebration');
    await tester.pumpWidget(const SizedBox());
    await c.dispose(tester);
    await h.dispose(tester);
  });
}
