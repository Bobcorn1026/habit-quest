import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/checks.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/domain/story_config.dart';
import 'package:habit_quest/game/judgement.dart';
import 'package:habit_quest/game/period.dart';

import '../support/builders.dart';

const forgeRequestConfig = StoryConfig();

const forgeRequest = ForgeRequest(
  requestId: 'abc234',
  heroName: '亞倫',
  identity: '每天都在變強的人',
  withPrologue: true,
  config: StoryConfig(),
  habits: [
    ForgeHabit(
      key: 'h1',
      kind: HabitKind.build,
      name: '讀英文',
      unit: '分鐘',
      target: 20,
    ),
    ForgeHabit(key: 'h2', kind: HabitKind.quit, name: '十一點後滑手機'),
  ],
);

const forgeReply = '''
好的！這是你的任務：

```json
{
  "protocol": "hq-1",
  "requestId": "abc234",
  "quests": [
    {"key": "h1", "rank": "C", "title": "破譯古代卷軸", "subtitle": "那些字母在對我低語",
     "flavor": "王立圖書館的卷軸。", "spriteId": "scroll", "attribute": "INT"},
    {"key": "h2", "rank": "B", "title": "深夜手機魔", "subtitle": "～那道藍光～",
     "flavor": "", "spriteId": "nope"}
  ],
  "world": {"summary": "王都邊境。", "npcs": [{"name": "莉娜", "description": "櫃檯小姐"}]},
  "prologue": {"title": "啟程", "body": "你推開公會的門。",
    "choices": [{"label": "收下委託書", "hint": ""}, {"label": "去酒館", "hint": "或許有傳聞"},
                {"label": "回家睡覺", "hint": ""}, {"label": "多出來的", "hint": ""}],
    "recap": "主角登記成為冒險者。"}
}
```
祝冒險順利！''';

final chapterRequest = ChapterRequest(
  requestId: 'zz9xyz',
  number: 3,
  period: Period(monday, 7),
  config: const StoryConfig(),
  heroName: '亞倫',
  heroClass: '見習賢者',
  level: 7,
  checks: const [
    StoryCheck(
      stat: Stat.intel,
      dc: 12,
      roll: 14,
      modifier: 3,
      result: CheckResult.success,
    ),
  ],
  recentRecaps: const ['主角進入霧之圖書館。'],
  lastChoice: '跟著貓頭鷹',
  judgement: Judgement.success,
  score: 0.78,
  habits: const [
    ChapterHabitStats(
      key: 'h1',
      kind: HabitKind.build,
      questTitle: '破譯古代卷軸',
      habitName: '讀英文',
      attribute: Stat.intel,
      unit: '分鐘',
      target: 20,
      scheduled: 7,
      completion: 1,
      done: 7,
      averageAmount: 20,
      notes: ['看完一篇新聞'],
      upgrade: UpgradeReason.surpass,
    ),
    ChapterHabitStats(
      key: 'h2',
      kind: HabitKind.quit,
      questTitle: '深夜手機魔',
      habitName: '十一點後滑手機',
      scheduled: 7,
      completion: 6 / 7,
      resisted: 6,
      relapsed: 1,
    ),
  ],
);

const chapterReply = '''
{"protocol":"hq-1","requestId":"zz9xyz","title":"霧之圖書館","body":"貓頭鷹領著你穿過書架。",
 "choices":[{"label":"推開左門","hint":""},{"label":"追上貓頭鷹","hint":""},{"label":"翻開禁書","hint":"危險"}],
 "recap":"主角在圖書館深處找到線索。","qualityBonus":0.5,
 "upgrades":[{"questKey":"h1","title":"解讀禁忌魔導書","subtitle":"更難的文字","npcLine":"這卷軸對你來說太薄了吧？"},
             {"questKey":"h9","title":"不存在","subtitle":"","npcLine":""}]}''';
