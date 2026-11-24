import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/habit.dart';

import '../support/app_harness.dart';

void main() {
  Future<void> tapText(WidgetTester tester, AppHarness h, String text) async {
    await tester.tap(find.text(text).last);
    await h.settle(tester);
  }

  /// Lets 莉娜 finish talking.
  Future<void> skipTalk(WidgetTester tester, AppHarness h) async {
    if (find.text('跳過 »').evaluate().isNotEmpty) {
      await tapText(tester, h, '跳過 »');
    }
  }

  testWidgets('莉娜 registers a new player and the bard forges offline', (
    tester,
  ) async {
    final h = AppHarness();
    await h.pump(tester);
    expect(find.textContaining('歡迎來到王都邊境的冒險者公會'), findsOneWidget);
    expect(find.text('冒險者名冊'), findsNothing, reason: 'she talks first');

    await skipTalk(tester, h);
    expect(find.text('冒險者名冊'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, '小夜');
    await tester.pump();
    await tapText(tester, h, '簽名');

    await skipTalk(tester, h);
    expect(find.textContaining('「我是誰」'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, '持續學習的人');
    await tapText(tester, h, '就這樣寫');

    await skipTalk(tester, h);
    expect(find.text('至少要有一件委託，冒險才能開始。'), findsOneWidget);
    await tapText(tester, h, '＋ 任務');
    await tester.enterText(find.byType(EditableText).first, '讀英文');
    await tapText(tester, h, '加入');
    expect(find.text('20 分鐘・每天'), findsOneWidget);
    expect(find.textContaining('「讀英文」，記下了'), findsOneWidget);

    await tapText(tester, h, '＋ 封印');
    await tester.enterText(find.byType(EditableText).first, '十一點後滑手機');
    await tapText(tester, h, '加入');
    expect(
      find.textContaining('新人的委託就先到這裡'),
      findsOneWidget,
      reason: 'an F-rank newcomer takes two commissions',
    );
    await tapText(tester, h, '就這些，交給公會');

    await skipTalk(tester, h);
    await tapText(tester, h, '不使用 AI');
    await tapText(tester, h, '決定了');
    await skipTalk(tester, h);
    await tapText(tester, h, '請吟遊詩人鍛造');
    await skipTalk(tester, h);
    expect(find.text('破譯古代卷軸'), findsOneWidget);
    expect(find.text('深夜手機魔'), findsOneWidget);
    expect(find.textContaining('序章'), findsOneWidget);

    await tapText(tester, h, '踏上冒險');
    expect(find.text('今日任務'), findsOneWidget);
    expect(find.text('小夜'), findsOneWidget);

    final hero = await tester.runAsync(() => AdventurerRepository(h.db).get());
    expect(hero!.identity, '持續學習的人');
    expect(hero.heroClass, '見習冒險者');
    final quests = await tester.runAsync(() => HabitRepository(h.db).active());
    expect(quests!.map((q) => q.habit.kind), [HabitKind.build, HabitKind.quit]);
    final prologue = await tester.runAsync(
      () => StoryRepository(h.db).latest(),
    );
    expect(prologue!.number, 0);
    expect(prologue.period.days, 0);
    await h.dispose(tester);
  });

  testWidgets('a tap shows the whole line, the next moves on', (tester) async {
    final h = AppHarness();
    await h.pump(tester);
    final box = find.textContaining('歡迎來到王都邊境');
    await tester.tap(box);
    await tester.pump();
    await tester.tap(box);
    await tester.pump();
    expect(find.textContaining('我是櫃檯的莉娜'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('first time on the board, 莉娜 explains it once', (tester) async {
    final h = AppHarness()..showTips = true;
    await tester.runAsync(h.seed);
    await h.pump(tester);
    expect(find.textContaining('這裡是任務板'), findsOneWidget);
    await tapText(tester, h, '跳過 »');
    await tester.tap(find.textContaining('別連續錯過兩天'));
    await h.settle(tester);
    expect(find.textContaining('這裡是任務板'), findsNothing);
    await h.dispose(tester);
  });
}
