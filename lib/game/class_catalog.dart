import '../domain/stat.dart';

typedef ClassTemplate = ({
  String name,
  String flavor,
  String portraitId,
  List<Stat> stats,
});

const _single = <Stat, (String, String, String)>{
  Stat.str: ('見習戰士', '用汗水鍛出鋼鐵之軀，正面迎擊每一道難關。', 'knight'),
  Stat.agi: ('見習遊俠', '身手俐落、手腳靈巧，總是比別人快一步。', 'ranger'),
  Stat.vit: ('守護騎士', '規律的作息就是最堅固的鎧甲。', 'knight'),
  Stat.intel: ('見習法師', '每天解讀一點咒文，知識就是魔力。', 'mage'),
  Stat.spi: ('見習僧侶', '在靜默與自律之中，鍛鍊不動搖的心。', 'cleric'),
  Stat.cha: ('吟遊詩人', '用言語與歌聲連結人心，走到哪裡都有朋友。', 'rogue'),
};

const _pairs = <(Stat, Stat), (String, String, String)>{
  (Stat.str, Stat.agi): ('劍舞者', '力量與速度兼具，劍光如舞。', 'rogue'),
  (Stat.str, Stat.vit): ('重裝騎士', '扛得住一切的鐵壁。', 'knight'),
  (Stat.str, Stat.intel): ('魔劍士', '一手持劍、一手詠唱。', 'knight'),
  (Stat.str, Stat.spi): ('聖騎士', '以堅定的意志揮動聖劍。', 'knight'),
  (Stat.str, Stat.cha): ('傭兵隊長', '帶著夥伴衝鋒陷陣的人。', 'knight'),
  (Stat.agi, Stat.vit): ('獵人', '在山野間奔走，從不疲倦。', 'ranger'),
  (Stat.agi, Stat.intel): ('鍊金術師', '靈巧的雙手調出知識的結晶。', 'mage'),
  (Stat.agi, Stat.spi): ('武僧', '身體與心靈一同修行。', 'cleric'),
  (Stat.agi, Stat.cha): ('義賊', '身手矯健，人緣更好。', 'rogue'),
  (Stat.vit, Stat.intel): ('藥師', '照顧身體也研究藥草。', 'cleric'),
  (Stat.vit, Stat.spi): ('修道士', '規律與自律就是他的修行。', 'cleric'),
  (Stat.vit, Stat.cha): ('旅店老闆', '讓每位旅人都吃飽睡好。', 'rogue'),
  (Stat.intel, Stat.spi): ('見習賢者', '在書頁與靜默之間尋找力量的人。', 'mage'),
  (Stat.intel, Stat.cha): ('軍師', '以智謀與口才指揮戰局。', 'mage'),
  (Stat.spi, Stat.cha): ('祭司', '安撫人心、傳遞希望。', 'cleric'),
};

/// A class from the strongest attributes, for when no AI is set up. Two
/// close attributes make a hybrid class.
ClassTemplate classFor(List<(Stat, int)> ranked) {
  final attrs = [
    for (final r in ranked)
      if (r.$1.isQuestAttribute) r,
  ];
  final top = attrs.first;
  if (attrs.length > 1) {
    final second = attrs[1];
    final close = second.$2 >= top.$2 * 0.8 && second.$2 > 5;
    final key = top.$1.index < second.$1.index
        ? (top.$1, second.$1)
        : (second.$1, top.$1);
    final pair = close ? _pairs[key] : null;
    if (pair != null) {
      return (
        name: pair.$1,
        flavor: pair.$2,
        portraitId: pair.$3,
        stats: [key.$1, key.$2],
      );
    }
  }
  final (name, flavor, portrait) = _single[top.$1]!;
  return (name: name, flavor: flavor, portraitId: portrait, stats: [top.$1]);
}
