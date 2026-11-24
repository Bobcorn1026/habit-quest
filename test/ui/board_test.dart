import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/check_in_repository.dart';
import 'package:habit_quest/data/economy_repository.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/ai/ai_config.dart';
import 'package:habit_quest/domain/check_in.dart';

import 'package:habit_quest/ui/widgets/mentor.dart';

import '../support/app_harness.dart';

void main() {
  testWidgets('new players see the welcome screen', (tester) async {
    final h = AppHarness();
    await h.pump(tester);
    expect(find.text('勇者日課'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('board shows quests, seals, streaks and the upgrade offer', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);

    expect(find.text('亞倫'), findsOneWidget);
    expect(find.text('破譯古代卷軸'), findsOneWidget);
    expect(find.text('深夜手機魔'), findsOneWidget);
    expect(find.text('負傷中：今天別再錯過！'), findsOneWidget);
    expect(find.textContaining('晉階邀請'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a rest day shows the inn banner and no injury warning', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await EconomyRepository(h.db).bookInn(h.today, 50, h.clock.now());
    });
    await h.pump(tester);

    expect(find.text('今天在旅店休息：不回報也不會負傷'), findsOneWidget);
    expect(find.text('負傷中：今天別再錯過！'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('reporting a quest awards XP and can be undone', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    final repo = CheckInRepository(h.db);
    final economy = EconomyRepository(h.db);
    final goldBefore = await tester.runAsync(economy.balance);

    await tester.tap(find.text('完成').first);
    await h.settle(tester);
    expect(find.text('回報冒險成果'), findsOneWidget);
    await tester.tap(find.text('×1.5'));
    await tester.pump();
    expect(find.text('30'), findsOneWidget);
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);

    expect(find.text('已完成'), findsOneWidget);
    expect(find.textContaining('金幣'), findsWidgets);
    final saved = await tester.runAsync(() => repo.between(h.today, h.today));
    final reading = saved!.firstWhere((c) => c.amount == 30);
    expect(reading.outcome, CheckInOutcome.done);
    expect(reading.xp, greaterThan(0));
    expect(reading.gold, greaterThan(0));
    expect(await tester.runAsync(economy.balance), goldBefore! + reading.gold);

    await tester.tap(find.text('撤回').first);
    await h.settle(tester);
    expect(find.text('已完成'), findsNothing);
    // Undoing takes the commission's gold back.
    expect(await tester.runAsync(economy.balance), goldBefore);
    await h.dispose(tester);
  });

  testWidgets('seals record holds and cracks', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);

    await tester.tap(find.text('有裂痕'));
    await h.settle(tester);
    await tester.enterText(find.byType(EditableText).last, '又追劇了');
    await tester.tap(find.text('記下裂痕'));
    await h.settle(tester);
    expect(find.text('出現裂痕'), findsOneWidget);

    await tester.tap(find.text('撤回').last);
    await h.settle(tester);
    await tester.tap(find.text('守住了'));
    await h.settle(tester);
    expect(find.text('出現裂痕'), findsNothing);
    expect(find.textContaining('EXP'), findsWidgets);
    await h.dispose(tester);
  });

  testWidgets('accepting the offer upgrades the quest', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);

    await tester.tap(find.text('查看'));
    await h.settle(tester);
    expect(find.text('每日目標（原本 20 分鐘）'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    await tester.tap(find.text('接受晉階'));
    await h.settle(tester);
    expect(find.text('破譯古代卷軸・精通'), findsOneWidget);
    expect(find.textContaining('晉階邀請'), findsNothing);
    await h.dispose(tester);
  });

  testWidgets('the bard proposes and the player edits the next tier', (
    tester,
  ) async {
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.aiConfig,
        const AiConfig(mode: AiMode.offline).toJson(),
      );
    });
    await h.pump(tester);

    await tester.tap(find.text('查看'));
    await h.settle(tester);
    await tester.tap(find.text('請吟遊詩人重新提案'));
    await h.settle(tester);
    await tester.enterText(find.byType(EditableText).first, '解讀星辰之書');
    await tester.enterText(find.byType(EditableText).last, '30');
    await tester.tap(find.text('接受晉階'));
    await h.settle(tester);

    final quest = (await tester.runAsync(() => HabitRepository(h.db).active()))!
        .firstWhere((a) => a.habit.name == '讀英文')
        .quest;
    expect(quest.title, '解讀星辰之書');
    expect(quest.target, 30);
    expect(quest.tier, 2);
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });

  testWidgets('莉娜 comments once every commission is reported', (tester) async {
    final h = AppHarness();
    await tester.runAsync(h.seed);
    await h.pump(tester);
    expect(find.byType(MentorBox), findsNothing);

    await tester.tap(find.text('守住了'));
    await h.settle(tester);
    while (find.text('完成').evaluate().isNotEmpty) {
      await tester.tap(find.text('完成').first);
      await h.settle(tester);
      await tester.tap(find.text('回報冒險成果'));
      await h.settle(tester);
    }
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(MentorBox), findsOneWidget);
    await h.dispose(tester);
  });
}
