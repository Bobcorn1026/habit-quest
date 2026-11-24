import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_config.dart';
import 'package:habit_quest/data/adventurer_repository.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/quest_rank.dart';
import 'package:habit_quest/data/settings_repository.dart';
import 'package:habit_quest/data/story_repository.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/game/period.dart';
import 'package:habit_quest/game/judgement.dart';
import 'package:habit_quest/domain/side_quest.dart';

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

  testWidgets('a due chapter is written, read and its choice recorded', (
    tester,
  ) async {
    final h = await start(tester);
    expect(find.text('第 1 章的命運等待揭曉'), findsOneWidget);
    expect(
      find.textContaining('離開了一段時間'),
      findsOneWidget,
      reason: 'the demo has five unwritten weeks',
    );

    await tester.tap(find.text('揭曉命運'));
    await h.settle(tester);
    expect(find.textContaining('判定：'), findsOneWidget);
    expect(
      find.textContaining('檢定 DC 12：擲出'),
      findsWidgets,
      reason: 'stat checks are shown with the verdict',
    );
    expect(find.text('你的抉擇是？'), findsOneWidget);

    await tester.tap(find.text('接下最難的委託'));
    await h.settle(tester);
    expect(find.text('你的抉擇'), findsOneWidget);
    final ch = await tester.runAsync(() => StoryRepository(h.db).latest());
    expect(ch!.status, ChapterStatus.written);
    expect(ch.chosen!.label, '接下最難的委託');

    await tester.tap(find.text('←'));
    await h.settle(tester);
    expect(find.text('第 1 章的命運等待揭曉'), findsNothing);
    expect(
      find.textContaining('抉擇的加持'),
      findsOneWidget,
      reason: 'the choice blesses the week that just began',
    );

    await tester.pump(const Duration(seconds: 2)); // let the toast leave
    await tester.tap(find.text('冒險日誌').last);
    await h.settle(tester);
    expect(find.textContaining('第 1 章'), findsWidgets);
    expect(find.textContaining('選擇：接下最難的委託'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('hero tab shows records and adds a habit offline', (
    tester,
  ) async {
    final h = await start(tester);
    // Rank C holds five commissions; the demo has four.
    await tester.runAsync(() async {
      final repo = AdventurerRepository(h.db);
      await repo.promote((await repo.get())!.id, QuestRank.c, h.today);
    });
    await tester.tap(find.text('角色').last);
    await h.settle(tester);
    expect(find.text('修行紀錄'), findsOneWidget);
    expect(find.text('「我想成為每天進步一點的人」'), findsOneWidget);

    await tester.tap(find.text('＋ 任務'));
    await h.settle(tester);
    await tester.enterText(find.byType(EditableText).first, '冥想');
    await tester.tap(find.text('加入'));
    await h.settle(tester);
    final active = await tester.runAsync(() => HabitRepository(h.db).active());
    expect(active!.map((a) => a.quest.title), contains('靜心祈禱'));
    await tester.pump(const Duration(seconds: 2));
    await h.dispose(tester);
  });

  testWidgets('finishing a side quest pays once and celebrates', (
    tester,
  ) async {
    // All writes before the first pump: several in a row inside runAsync
    // while the board listens can deadlock drift.
    final h = AppHarness();
    await tester.runAsync(() async {
      await h.seed();
      await SettingsRepository(h.db).write(
        SettingKeys.aiConfig,
        const AiConfig(mode: AiMode.offline).toJson(),
      );
      final story = StoryRepository(h.db);
      final reading = (await HabitRepository(
        h.db,
      ).active()).firstWhere((a) => a.habit.name == '讀英文');
      final ch = await story.createPending(
        number: 1,
        period: Period(h.today.addDays(-7), 7),
        judgement: Judgement.success,
        score: 0.8,
        stats: const {},
        now: testNow,
      );
      await story.write(
        ch.id,
        const ChapterContent(title: '測試', body: '……'),
        now: testNow,
      );
      await story.mergeStats(ch.id, {
        'sideQuest': SideQuest(
          title: '圖書館的委託',
          kind: SideQuestKind.questCount,
          habitId: reading.habit.id,
          target: 1,
        ).toJson(),
      });
    });
    await h.pump(tester);
    expect(find.text('支線委託・圖書館的委託'), findsOneWidget);

    await tester.tap(find.text('完成').first);
    await h.settle(tester);
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);
    expect(find.text('支線完成！'), findsOneWidget);
    final events = await tester.runAsync(
      () => h.db.select(h.db.goldEvents).get(),
    );
    expect(events!.where((e) => e.source == 'side'), hasLength(1));
    await tester.pump(const Duration(seconds: 3));
    await h.dispose(tester);
  });
}
