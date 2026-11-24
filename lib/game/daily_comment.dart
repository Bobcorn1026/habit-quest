import '../core/logical_day.dart';

/// What happened today, for 莉娜's comment once everything is reported.
typedef DayRecap = ({
  LogicalDay day,
  bool perfect,
  int done,
  int partial,
  int cracks,

  /// The longest current streak among today's quests, and its quest.
  int bestStreak,
  String bestQuest,

  /// A running guild trial: days passed so far and days needed.
  (int, int)? trial,
});

const _perfect = [
  '全部完成！……呼啊，害我也不好意思偷懶了。',
  '完美的一天。登記簿上又多了一個金色的勾。',
  '今天的委託一件不漏。你這樣我會很難摸魚耶。',
  '全部交齊了？好，那我可以安心打個盹了。',
  '漂亮。這種日子累積起來，就是傳說喔。',
];

const _mixed = [
  '有幾件只做了一部分，不過有做就是有做。',
  '今天辛苦了。差一點點的部分，明天再補上就好。',
  '嗯……不完美，但很踏實。我喜歡這種一天。',
];

const _weekend = ['週末還這麼認真……你是不是忘了「休假」這兩個字？', '假日也來交委託，公會應該給你發加班費才對。'];

/// 莉娜's line for a finished day. The same day always gets the same line.
String dailyComment(DayRecap r) {
  final seed = r.day.differenceInDays(const LogicalDay(2026, 1, 1));
  String pick(List<String> lines) => lines[seed % lines.length];

  if (r.trial case (final passed, final needed) when passed < needed) {
    return '考驗第 $passed 天，過關了。還剩 ${needed - passed} 天，撐住喔。';
  }
  if (r.cracks > 0) {
    return '封印出現了裂痕……沒關係，明天把它補起來就好。今天還是辛苦了。';
  }
  const milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365];
  if (milestones.contains(r.bestStreak)) {
    return '「${r.bestQuest}」連續 ${r.bestStreak} 天了耶。我偷偷記在登記簿上了。';
  }
  if (!r.perfect && r.partial > 0) return pick(_mixed);
  if (r.day.weekday >= DateTime.saturday && seed.isEven) return pick(_weekend);
  return pick(_perfect);
}
