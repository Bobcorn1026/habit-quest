import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/game/shop.dart';
import 'package:habit_quest/ui/pixel/pixel.dart';
import 'package:habit_quest/ui/screens/shop/shop_screen.dart';
import 'package:habit_quest/ui/widgets/pixel_controls.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('rank unlocks items, gold buys them, they are equipped', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const ShopScreen());
    final before = await tester.runAsync(
      () => EconomyRepository(h.db).balance(),
    );
    expect(before, greaterThan(160));
    expect(find.text('未解鎖'), findsWidgets, reason: 'a D-rank cannot buy B+');

    final row = find.ancestor(of: find.text('青銅框'), matching: find.byType(Row));
    await tester.ensureVisible(row.last);
    await tester.tap(find.descendant(of: row.last, matching: find.text('購買')));
    await h.settle(tester);
    final after = await tester.runAsync(
      () => EconomyRepository(h.db).balance(),
    );
    expect(before! - after!, greaterThan(0));
    final raw = await tester.runAsync<Object?>(
      () => SettingsRepository(h.db).read(SettingKeys.equipped),
    );
    final equipped = Equipped.fromJson(raw);
    expect(equipped.frame, isNotNull);
    expect(find.text('使用中'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });

  testWidgets('booking a rest day at the inn costs gold and can be undone', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester, home: const ShopScreen());
    final repo = EconomyRepository(h.db);
    final before = await tester.runAsync(repo.balance);
    expect(find.text('住宿一晚（休息日）'), findsOneWidget);

    await tester.tap(find.text('預約'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    final tomorrow = h.today.addDays(1);
    expect(
      find.text(formatDayLabel(tomorrow.month, tomorrow.day, tomorrow.weekday)),
      findsOneWidget,
    );
    await tester.tap(find.text('預約').at(1));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(await tester.runAsync(repo.bookedDays), {tomorrow});
    // 50 at rank F; the demo adventurer is rank D, where prices are ×1.5.
    expect(find.text('75 金幣'), findsOneWidget);
    expect(await tester.runAsync(repo.balance), before! - 75);
    expect(find.textContaining('已預約'), findsWidgets);

    await tester.tap(find.text('取消'));
    await h.settle(tester);
    expect(await tester.runAsync(repo.bookedDays), isEmpty);
    expect(await tester.runAsync(repo.balance), before);
    await tester.pump(const Duration(seconds: 5));
    await h.dispose(tester);
  });

  testWidgets('the equipped wood reaches every board', (tester) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db)
          .write(SettingKeys.equipped, const Equipped(wood: 'oak').toJson());
    });
    await h.pump(tester);
    final context = tester.element(find.byType(PixelBackdrop).first);
    expect(BoardWoodScope.of(context), BoardWood.oak);
    await h.dispose(tester);
  });
}
