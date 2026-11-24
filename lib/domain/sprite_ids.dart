/// Icon ids the AI may assign to quests; must match `PixelIcons.all`.
const kQuestSpriteIds = [
  'scroll',
  'sword',
  'shield',
  'seal',
  'crack',
  'potion',
  'book',
  'crown',
  'star',
  'flame',
  'chest',
  'd20',
  'skull',
  'quill',
];

/// Monster ids for quit-habit seals; must match `PixelMonsters.all`.
const kMonsterSpriteIds = ['imp', 'owl', 'slime', 'mimic', 'wisp', 'ghost'];

const _monsterKeywords = <(List<String>, String)>[
  (['手機', '滑', 'IG', 'Threads', '社群', '短影音', '網路', 'YouTube'], 'imp'),
  (['熬夜', '晚睡', '夜'], 'owl'),
  (['零食', '甜', '飲料', '宵夜', '炸', '糖', '暴食'], 'slime'),
  (['遊戲', '電動', '購物', '網購', '花錢', '抽卡'], 'mimic'),
  (['菸', '煙', '酒'], 'wisp'),
  (['拖延', '拖', '賴床', '懶'], 'ghost'),
];

/// Picks a seal monster from a habit's name. Unknown habits still get a
/// stable monster, so the same habit always shows the same one.
String guessMonster(String habitName) {
  final name = habitName.toLowerCase();
  for (final (keys, id) in _monsterKeywords) {
    if (keys.any((k) => name.contains(k.toLowerCase()))) return id;
  }
  final hash = habitName.codeUnits.fold(0, (h, c) => (h * 31 + c) & 0xffffff);
  return kMonsterSpriteIds[hash % kMonsterSpriteIds.length];
}
