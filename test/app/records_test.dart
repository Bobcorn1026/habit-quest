import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/ai/response_parser.dart';
import 'package:habit_quest/ai/template_writer.dart';
import 'package:habit_quest/app/records.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/domain/story_config.dart';

import '../support/builders.dart';

void main() {
  final record = AdventureRecord(
    heroName: '亞倫',
    heroClass: '見習賢者',
    level: 10,
    totalXp: 2800,
    guildRank: 'E',
    adventureDays: 41,
    perfectDays: 34,
    stats: const [(Stat.spi, 26), (Stat.intel, 24), (Stat.luk, 14)],
    quests: [
      QuestRecord(
        questTitle: '破譯古代卷軸',
        habitName: '讀英文',
        kind: HabitKind.build,
        attribute: Stat.intel,
        rank: 'C',
        since: monday,
        finished: 40,
        cracks: 0,
        longestRun: 40,
        currentRun: 40,
        notes: const ['看完一篇 BBC 新聞'],
      ),
    ],
    chapters: const [(0, '啟程', '主角在公會登記。')],
  );

  test('the longest run counts consecutive days only', () {
    expect(longestRun([monday, monday.addDays(1), monday.addDays(3)]), 2);
    expect(longestRun(const []), 0);
  });

  test('a record reads as Markdown and as JSON for the AI', () {
    final md = record.toMarkdown();
    expect(md, contains('# 亞倫 的冒險紀錄'));
    expect(md, contains('最長連續 40 天'));
    expect(md, contains('「看完一篇 BBC 新聞」'));
    expect(md, contains('序章・啟程'));
    final json = record.toJson();
    expect((json['hero'] as Map)['perfectDays'], 34);
  });

  test('titles come from the AI or from the strongest stat', () {
    final request = TitleRequest(
      requestId: 'abc234',
      config: const StoryConfig(),
      record: record.toJson(),
    );
    final t = TemplateWriter.title(request);
    expect(t.title, '靜心的守護者');
    expect(t.reason, contains('40 天'));

    final parsed = parseTitle(
      '```json\n{"protocol":"hq-1","requestId":"abc234",'
      '"title":"「不眠的破譯者」","reason":"連續四十天。"}\n```',
      request,
    );
    expect((parsed as Parsed<TitleResult>).value.title, '不眠的破譯者');
    expect(
      parseTitle('{"requestId":"zzz","title":"x"}', request),
      isA<ParseFailed<TitleResult>>(),
    );
  });
}
