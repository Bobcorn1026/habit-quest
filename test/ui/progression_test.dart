import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/ai/ai_config.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/domain/quest_rank.dart';

import 'package:habit_quest/ui/pixel/pixel.dart';

import '../support/app_harness.dart';

void main() {
  Future<AppHarness> start(WidgetTester tester) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.aiConfig,
        const AiConfig(mode: AiMode.offline).toJson(),
      );
    });
    await h.pump(tester);
    return h;
  }

  Future<void> openHero(WidgetTester tester, AppHarness h) async {
    await tester.tap(find.text('角色').last);
    await h.settle(tester);
  }

  testWidgets('the hero tab shows guild rank, class mastery and stats', (
    tester,
  ) async {
    final h = await start(tester);
    await openHero(tester, h);
    expect(find.text('公會 Rank'), findsOneWidget);
    expect(find.text('見習賢者'), findsWidgets);
    expect(find.textContaining('專精'), findsWidgets);
    expect(find.text('智力 INT'), findsOneWidget);
    expect(find.text('幸運 LUK'), findsOneWidget);
    expect(find.text('接受晉升考驗'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a promotion trial passes on its last perfect day', (
    tester,
  ) async {
    final h = await start(tester);
    // An F-rank hero with enough points: the trial to E is a single day.
    await tester.runAsync(() async {
      final repo = AdventurerRepository(h.db);
      await repo.promote(
        (await repo.get())!.id,
        QuestRank.f,
        h.today.addDays(-12),
      );
    });
    await h.settle(tester);
    await openHero(tester, h);
    await tester.tap(find.text('接受晉升考驗'));
    await h.settle(tester);
    expect(find.textContaining('晉升考驗中：0 / 1'), findsOneWidget);

    // Report every daily commission on the board.
    await tester.tap(find.text('任務板').last);
    await h.settle(tester);
    await tester.tap(find.text('守住了'));
    await h.settle(tester);
    while (find.text('完成').evaluate().isNotEmpty) {
      await tester.tap(find.text('完成').first);
      await h.settle(tester);
      await tester.tap(find.text('回報冒險成果'));
      await h.settle(tester);
    }
    final hero = await tester.runAsync(() => AdventurerRepository(h.db).get());
    expect(hero!.guildRank, QuestRank.e);
    expect(hero.trialStart, isNull);
    final perfect = await tester.runAsync(
      () => h.db.select(h.db.goldEvents).get(),
    );
    expect(perfect!.single.ref, h.today.toKey(), reason: 'perfect-day gold');
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });

  testWidgets('setting an anchor in the form shows on the board, no curse', (
    tester,
  ) async {
    final h = await start(tester);
    await openHero(tester, h);
    await tester.tap(find.text('修改').first);
    await h.settle(tester);
    expect(find.text('接在…之後（選填）'), findsOneWidget);
    await tester.tap(find.widgetWithText(PixelButton, '鍛鍊騎士之軀'));
    await tester.pump();
    await tester.tap(find.text('付出代價並修改'));
    await h.settle(tester);

    final habit = (await tester.runAsync(() => HabitRepository(h.db).active()))!
        .first
        .habit;
    expect(habit.anchorHabitId, isNotNull);
    expect(habit.cursedOn, isNull);

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('任務板').last);
    await h.settle(tester);
    expect(find.text('接在『鍛鍊騎士之軀』之後'), findsOneWidget);
    expect(find.textContaining('詛咒：'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('saving the form unchanged curses nothing', (tester) async {
    final h = await start(tester);
    await openHero(tester, h);
    final edits = find.text('修改').evaluate().length;
    expect(edits, greaterThan(1), reason: 'quests and a seal to try');
    for (var i = 0; i < edits; i++) {
      await tester.ensureVisible(find.text('修改').at(i));
      await tester.tap(find.text('修改').at(i));
      await h.settle(tester);
      await tester.tap(find.text('付出代價並修改'));
      await h.settle(tester);
      expect(find.text('沒有任何變更'), findsOneWidget, reason: 'habit #$i');
      await tester.pump(const Duration(seconds: 3));
    }
    final habits = (await tester.runAsync(
      () => HabitRepository(h.db).active(),
    ))!;
    for (final e in habits) {
      expect(e.habit.cursedOn, isNull, reason: e.habit.name);
    }
    await h.dispose(tester);
  });

  testWidgets('editing a habit curses it; a failed curse costs XP', (
    tester,
  ) async {
    final h = await start(tester);
    await openHero(tester, h);
    await tester.tap(find.text('修改').first);
    await h.settle(tester);
    expect(find.textContaining('修改是要付出代價的'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).at(1), '15');
    await tester.tap(find.text('付出代價並修改'));
    await h.settle(tester);
    final habit = (await tester.runAsync(() => HabitRepository(h.db).active()))!
        .first
        .habit;
    expect(habit.target, 15);
    expect(habit.cursedOn, h.today);

    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.text('任務板').last);
    await h.settle(tester);
    expect(find.textContaining('詛咒：今天一定要完整完成'), findsOneWidget);

    final before = await tester.runAsync(
      () => CheckInRepository(h.db).totalXp(),
    );
    h.clock.advance(const Duration(days: 1));
    // The minute timer would roll the day over; nudge it now.
    ProviderScope.containerOf(tester.element(find.byType(HabitQuestApp)))
        .read(todayProvider.notifier)
        .refresh();
    await h.settle(tester);
    final after = await tester.runAsync(
      () => CheckInRepository(h.db).totalXp(),
    );
    expect(after, lessThan(before!));
    expect(find.textContaining('的詛咒發作了'), findsOneWidget);
    await tester.tap(find.text('知道了'));
    await h.settle(tester);
    expect(find.textContaining('的詛咒發作了'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('a full guild card stops new commissions', (tester) async {
    final h = await start(tester);
    await openHero(tester, h);
    await tester.tap(find.text('＋ 任務'));
    await h.settle(tester);
    expect(find.textContaining('最多只能接 4 件委託'), findsOneWidget);
    expect(find.text('想養成的習慣'), findsNothing, reason: 'no form opens');
    await h.dispose(tester);
  });

  testWidgets('a class kept long enough can be changed', (tester) async {
    final h = await start(tester);
    await openHero(tester, h);
    await tester.tap(find.text('轉職'));
    await h.settle(tester);
    expect(find.textContaining('專精會從頭累積'), findsOneWidget);
    await tester.tap(find.text('轉職').last);
    await h.settle(tester);
    final hero = await tester.runAsync(() => AdventurerRepository(h.db).get());
    expect(hero!.classInfo!.since, h.today);
    expect(hero.portraitId, isNotNull);
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });

  testWidgets('the guild grants a title from the record', (tester) async {
    final h = await start(tester);
    await openHero(tester, h);
    await tester.tap(find.text('稱號鑑定'));
    await h.settle(tester);
    expect(find.text('接受稱號'), findsOneWidget);
    await tester.tap(find.text('接受稱號'));
    await h.settle(tester);
    final hero = await tester.runAsync(() => AdventurerRepository(h.db).get());
    expect(hero!.title, isNotNull);
    expect(find.text('獲得稱號'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });
}
