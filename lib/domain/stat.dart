import 'habit.dart';

/// Character stats. Every quest trains one of the first six (its
/// attribute); luck comes from perfect days instead.
enum Stat {
  str('力量', 'STR', '重訓、肌力、體力活'),
  agi('敏捷', 'AGI', '跑步、球類、舞蹈、伸展，以及樂器、繪畫、手作等講究身手或手巧的事'),
  vit('體質', 'VIT', '睡眠、飲食、喝水、作息、健康管理'),
  intel('智力', 'INT', '閱讀、學習、語言、課業、程式'),
  spi('精神', 'SPI', '冥想、日記、整理、自律，以及大部分要戒掉的習慣'),
  cha('魅力', 'CHA', '社交、陪伴家人朋友、表達、打扮'),
  luk('幸運', 'LUK', '');

  const Stat(this.label, this.code, this.covers);

  final String label;

  /// Three-letter tag, e.g. `STR`. Also what the AI replies with.
  final String code;

  /// Which habits train it, for prompts and the stat sheet.
  final String covers;

  bool get isQuestAttribute => this != luk;

  static const attributes = [str, agi, vit, intel, spi, cha];

  /// Accepts the code (`STR`), the enum name or the Chinese label.
  static Stat? parse(Object? raw) {
    if (raw is! String) return null;
    final key = raw.trim().toLowerCase();
    for (final s in values) {
      if (s.code.toLowerCase() == key || s.name == key || s.label == key) {
        return s;
      }
    }
    return null;
  }

  static List<Stat> parseList(String? csv) => [
    for (final p in (csv ?? '').split(',')) ?parse(p),
  ];
}

const _attributeKeywords = <(List<String>, Stat)>[
  (['重訓', '伏地挺身', '深蹲', '仰臥', '引體', '健身', '舉重', '肌', '運動'], Stat.str),
  (
    [
      '跑',
      '球',
      '舞',
      '伸展',
      '瑜珈',
      '瑜伽',
      '游泳',
      '騎車',
      '爬山',
      '吉他',
      '鋼琴',
      '樂器',
      '練琴',
      '畫',
      '手作',
      '烹飪',
      '做菜',
    ],
    Stat.agi,
  ),
  (
    [
      '睡',
      '起床',
      '早起',
      '熬夜',
      '水',
      '喝',
      '吃',
      '蔬菜',
      '零食',
      '甜',
      '飲料',
      '宵夜',
      '炸',
      '維他命',
      '走路',
      '菸',
      '煙',
      '酒',
    ],
    Stat.vit,
  ),
  (
    [
      '讀',
      '書',
      '英文',
      '日文',
      '韓文',
      '語言',
      '單字',
      '學',
      '課',
      '考',
      '程式',
      'coding',
      'code',
      '論文',
    ],
    Stat.intel,
  ),
  (['朋友', '家人', '爸', '媽', '打電話', '聊天', '社交', '感謝', '保養', '穿搭'], Stat.cha),
  (['冥想', '靜坐', '日記', '整理', '打掃', '收拾', '記帳', '手機', '滑', '拖延'], Stat.spi),
];

/// Picks a quest attribute from a habit's name, for the template writer and
/// for quests saved before attributes existed.
Stat guessAttribute(String habitName, HabitKind kind) {
  final name = habitName.toLowerCase();
  for (final (keys, stat) in _attributeKeywords) {
    if (keys.any((k) => name.contains(k.toLowerCase()))) return stat;
  }
  return Stat.spi;
}
