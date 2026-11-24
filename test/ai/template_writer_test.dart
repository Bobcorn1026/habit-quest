import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/ai/template_writer.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/quest_rank.dart';

import 'fixtures.dart';

void main() {
  test('forges themed quests with attributes, a world and a prologue', () {
    final r = TemplateWriter.forge(forgeRequest);
    expect(r.questFor('h1')!.title, '破譯古代卷軸');
    expect(r.questFor('h2')!.title, '深夜手機魔');
    expect(r.questFor('h2')!.spriteId, 'imp', reason: 'phone → screen imp');
    expect(r.questFor('h1')!.attribute, Stat.intel);
    expect(r.prologue!.body, contains('破譯古代卷軸'));
  });

  test('duplicate themes get distinct titles', () {
    const req = ForgeRequest(
      requestId: 'x',
      heroName: 'a',
      config: forgeRequestConfig,
      habits: [
        ForgeHabit(key: 'h1', kind: HabitKind.build, name: '跑步'),
        ForgeHabit(key: 'h2', kind: HabitKind.build, name: '重訓'),
      ],
    );
    final r = TemplateWriter.forge(req);
    expect(r.questFor('h1')!.title, isNot(r.questFor('h2')!.title));
  });

  test('rank grows with the weekly effort', () {
    ForgeHabit h(double target, {String unit = '分鐘', int times = 7}) =>
        ForgeHabit(
          key: 'h',
          kind: HabitKind.build,
          name: 'x',
          unit: unit,
          target: target,
          timesPerWeek: times,
        );
    expect(TemplateWriter.rankFor(h(1)), QuestRank.f);
    expect(TemplateWriter.rankFor(h(20)), QuestRank.c);
    expect(TemplateWriter.rankFor(h(90)), QuestRank.a);
    expect(TemplateWriter.rankFor(h(2, unit: '小時')), QuestRank.s);
    expect(TemplateWriter.rankFor(h(30, times: 3)), QuestRank.d);
    // 4 a week sits between 3 and 5.
    expect(TemplateWriter.rankFor(h(60, times: 4)), QuestRank.c);
    expect(TemplateWriter.rankFor(h(60, times: 3)), QuestRank.c);
    expect(TemplateWriter.rankFor(h(60, times: 7)), QuestRank.a);
  });

  test('writes a chapter that mentions cracks and offers choices', () {
    final r = TemplateWriter.chapter(chapterRequest);
    expect(r.content.body, contains('裂痕'));
    expect(r.content.body, contains('跟著貓頭鷹'));
    expect(r.content.choices, hasLength(3));
  });
}
