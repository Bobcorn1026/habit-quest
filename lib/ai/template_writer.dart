import '../data/story_repository.dart';
import '../domain/chapter.dart';
import '../domain/habit.dart';
import '../domain/quest_rank.dart';
import '../domain/side_quest.dart';
import '../domain/sprite_ids.dart';
import '../domain/stat.dart';
import '../game/class_catalog.dart';
import '../game/judgement.dart';
import 'ai_tasks.dart';

/// Writes quests and chapters from built-in templates, so the game works
/// with no AI at all (and as a fallback when one fails).
abstract final class TemplateWriter {
  static const _buildThemes = <(List<String>, String, String, String)>[
    (['英文', '日文', '韓文', '語言', '單字', '外語'], '破譯古代卷軸', '～那些字母在對我低語～', 'scroll'),
    (['讀', '書', '閱讀'], '探索禁書庫', '～知識是最鋒利的劍～', 'book'),
    (
      ['跑', '運動', '健身', '重訓', '游泳', '瑜珈', '走路', '騎車'],
      '鍛鍊騎士之軀',
      '～肌肉痠痛是力量的證明～',
      'sword',
    ),
    (['寫', '日記', '筆記', '部落格'], '記錄冒險日誌', '～今天的我也很努力（大概）～', 'quill'),
    (['早起', '早睡', '睡'], '與晨曦訂約', '～太陽升起前，勇者已經醒了～', 'star'),
    (['水', '喝'], '汲取聖泉', '～補充 HP 是基本功～', 'potion'),
    (['冥想', '靜坐', '呼吸'], '靜心祈禱', '～讓心中的湖面平靜下來～', 'd20'),
    (['存錢', '記帳', '理財'], '守護寶庫', '～每一枚金幣都有它的使命～', 'chest'),
    (['程式', 'coding', '寫code', '練習'], '修習古代魔法', '～咒文錯一個字就會爆炸～', 'book'),
    (['打掃', '整理', '收拾'], '淨化據點', '～整齊的據點是勇者的尊嚴～', 'shield'),
  ];

  static const _quitThemes = <(List<String>, String, String)>[
    (['手機', '滑', 'IG', 'Threads', '社群', '短影音'], '深夜手機魔', '～那道藍光正在吞噬你的睡眠～'),
    (['熬夜', '晚睡'], '夜梟魔', '～牠總說「再一下就好」～'),
    (['零食', '甜', '飲料', '宵夜', '炸'], '甜蜜誘惑魔', '～香氣是牠最強的魔法～'),
    (['遊戲', '電動'], '無盡迷宮魔', '～再一場、再一場……～'),
    (['菸', '酒'], '煙霧魔', '～牠躲在每個「只抽一根」裡～'),
    (['拖延', '拖'], '明日魔', '～「明天再說」是牠的咒語～'),
  ];

  static (String, String, String) _themeFor(ForgeHabit h) {
    if (h.kind == HabitKind.quit) {
      for (final (keys, title, sub) in _quitThemes) {
        if (keys.any(h.name.contains)) {
          return (title, sub, guessMonster(h.name));
        }
      }
      return ('${h.name}魔', '～封印牠，奪回你的時間～', guessMonster(h.name));
    }
    for (final (keys, title, sub, sprite) in _buildThemes) {
      if (keys.any((k) => h.name.toLowerCase().contains(k))) {
        return (title, sub, sprite);
      }
    }
    return ('${h.name}的試煉', '～每天一步，傳說就此開始～', 'scroll');
  }

  /// A rough difficulty guess from the daily target.
  static QuestRank rankFor(ForgeHabit h) {
    if (h.kind == HabitKind.quit) return QuestRank.c;
    final t = h.target;
    if (t == null) return h.timesPerWeek >= 7 ? QuestRank.e : QuestRank.f;
    final unit = h.unit ?? '';
    final minutes = unit.contains('小時') ? t * 60 : t;
    final effort = unit.contains('分') || unit.contains('小時')
        ? minutes
        : t * 5; // pages, reps…: treat each as ~5 minutes of effort
    final weekly = effort * h.timesPerWeek / 7;
    if (weekly < 5) return QuestRank.f;
    if (weekly < 10) return QuestRank.e;
    if (weekly < 20) return QuestRank.d;
    if (weekly < 40) return QuestRank.c;
    if (weekly < 60) return QuestRank.b;
    if (weekly < 120) return QuestRank.a;
    if (weekly < 240) return QuestRank.s;
    if (weekly < 480) return QuestRank.ss;
    return QuestRank.sss;
  }

  static ForgeResult forge(ForgeRequest r) {
    final quests = <ForgedQuest>[];
    final used = <String>{};
    for (final h in r.habits) {
      var (title, subtitle, sprite) = _themeFor(h);
      if (!used.add(title)) title = '$title・${h.name}';
      quests.add(
        ForgedQuest(
          key: h.key,
          rank: rankFor(h),
          title: title,
          subtitle: subtitle,
          spriteId: sprite,
          attribute: guessAttribute(h.name, h.kind),
        ),
      );
    }
    return ForgeResult(
      quests: quests,
      world: r.withPrologue
          ? const WorldBible(
              summary: '王都邊境的冒險者公會，是所有新人勇者的起點。',
              npcs: [
                (name: '莉娜', description: '公會櫃檯小姐，總是一邊打哈欠一邊發委託。'),
                (name: '老貓頭鷹', description: '公會長的使魔，看穿一切偷懶。'),
              ],
            )
          : null,
      prologue: r.withPrologue
          ? ChapterContent(
              title: '啟程',
              body:
                  '王都邊境的冒險者公會裡，櫃檯的莉娜把一疊委託書推到${r.heroName}面前：'
                  '「新人？先從這幾件開始吧。」委託書上寫著：'
                  '${quests.map((q) => '「${q.title}」').join('、')}。'
                  '公會長的老貓頭鷹在樑上眨了眨眼，好像在說：「別想偷懶喔。」',
              choices: [
                StoryChoice(
                  '收下委託書',
                  blessing: Blessing(BlessingKind.xp, quests.first.attribute),
                ),
                StoryChoice(
                  '先去酒館打聽消息',
                  blessing: Blessing(BlessingKind.gold, quests.last.attribute),
                ),
              ],
              recap: '${r.heroName}在冒險者公會登記，接下第一批委託。',
            )
          : null,
    );
  }

  static ChapterResult chapter(ChapterRequest r) {
    final opening = switch (r.judgement) {
      Judgement.triumph =>
        '這段日子，${r.heroName}的名號在公會裡傳開了。每一件委託都完成得漂漂亮亮，連老貓頭鷹都忍不住點頭。',
      Judgement.success => '${r.heroName}穩穩地推進著委託。雖然偶有疏漏，但公會的評價越來越好。',
      Judgement.struggle => '這段旅程並不輕鬆。${r.heroName}有幾天累得倒頭就睡，委託書在桌上積了灰。',
      Judgement.setback => '風暴來襲，${r.heroName}被困在旅店好幾天。不過，勇者的故事從不在低谷結束。',
    };
    final quests = r.habits
        .where((h) => h.kind == HabitKind.build && h.done + h.partial > 0)
        .map((h) => '「${h.questTitle}」')
        .join('、');
    final seals = r.habits.where(
      (h) => h.kind == HabitKind.quit && h.relapsed > 0,
    );
    final body = [
      opening,
      if (r.lastChoice != null) '上一次，${r.heroName}決定「${r.lastChoice}」。',
      if (quests.isNotEmpty) '這段期間，$quests都有了進展。',
      for (final c in r.checks)
        '${c.stat.label}的考驗擋在路上——${c.line}。'
            '${c.result.passed ? '${r.heroName}漂亮地闖了過去。' : '${r.heroName}狼狽地摔了一跤，只好繞遠路。'}',
      for (final s in seals)
        '「${s.questTitle}」的封印出現了 ${s.relapsed} 道裂痕，魔物的低語在夜裡迴盪。',
      '莉娜遞來新的委託書：「下一站，就看你的了。」',
    ].join('\n\n');
    final stats = [for (final h in r.habits) h.attribute];
    Stat at(int i, Stat fallback) =>
        stats.isEmpty ? fallback : stats[i % stats.length];
    final choices = [
      StoryChoice(
        '接下最難的委託',
        blessing: Blessing(BlessingKind.xp, at(0, Stat.str)),
      ),
      StoryChoice(
        '先回旅店休整',
        blessing: Blessing(BlessingKind.check, at(1, Stat.vit)),
      ),
      StoryChoice(
        '去酒館打聽傳聞',
        blessing: Blessing(BlessingKind.gold, at(2, Stat.cha)),
      ),
    ].take(r.choiceCount).toList();
    // Extra practice on the quest that went worst, a little above this
    // period's count.
    final builds = r.habits.where((h) => h.kind == HabitKind.build).toList()
      ..sort((a, b) => a.completion.compareTo(b.completion));
    final weakest = builds.firstOrNull;
    final side = weakest == null
        ? null
        : SideQuestDraft(
            title: '「${weakest.questTitle}」加練',
            story: '莉娜從櫃檯下抽出一張皺巴巴的紙：「這是額外的委託，做完有獎金喔……我先睡一下。」',
            kind: SideQuestKind.questCount,
            questKey: weakest.key,
            target: (weakest.done + 1).clamp(1, r.config.periodDays),
          );
    return ChapterResult(
      sideQuest: side,
      content: ChapterContent(
        title: switch (r.judgement) {
          Judgement.triumph => '名聲遠播',
          Judgement.success => '穩步前行',
          Judgement.struggle => '泥濘之路',
          Judgement.setback => '風暴之中',
        },
        body: body,
        choices: choices,
        recap: '${r.heroName}經歷了第 ${r.number} 章（${r.judgement.label}）。',
      ),
    );
  }

  static ClassResult heroClass(ClassRequest r) {
    final c = classFor(r.stats);
    final best = [...r.habits]
      ..sort((a, b) => b.finished.compareTo(a.finished));
    final quest = best.isEmpty ? '委託' : '「${best.first.questTitle}」';
    return ClassResult(
      name: c.name,
      stats: c.stats,
      flavor: c.flavor,
      portraitId: c.portraitId,
      ceremony:
          '莉娜翻開登記簿，指著密密麻麻的紀錄：「你最常交回來的是$quest。'
          '公會決定認定你為「${c.name}」。從今天起，就照這條路繼續前進吧！」',
    );
  }

  static const _titleAdjectives = {
    'STR': '剛力的',
    'AGI': '疾風的',
    'VIT': '不倒的',
    'INT': '博學的',
    'SPI': '靜心的',
    'CHA': '人望的',
  };

  /// A title from the strongest stat and the longest run.
  static TitleResult title(TitleRequest r) {
    final hero = (r.record['hero'] as Map?) ?? const {};
    final stats = (hero['stats'] as Map?)?.keys.toList() ?? const [];
    final top = stats.isEmpty ? null : Stat.parse(stats.first);
    final quests =
        [
          for (final q in (r.record['quests'] as List?) ?? const [])
            if (q is Map) q,
        ]..sort(
          (a, b) => ((b['longestRun'] as int?) ?? 0).compareTo(
            (a['longestRun'] as int?) ?? 0,
          ),
        );
    final best = quests.firstOrNull;
    final run = (best?['longestRun'] as int?) ?? 0;
    final noun = run >= 100
        ? '傳說'
        : run >= 30
        ? '守護者'
        : run >= 7
        ? '行者'
        : '新星';
    final title = '${_titleAdjectives[top?.code] ?? '見習的'}$noun';
    return TitleResult(
      title: title,
      reason: best == null
          ? '莉娜笑著說：「冒險才剛開始，這個稱號先借你用！」'
          : '莉娜翻著紀錄：「『${best['quest']}』最長連續了 $run 天，'
                '${top == null ? '' : '${top.label}也是你最高的能力值，'}這個稱號你當之無愧。」',
    );
  }
}
