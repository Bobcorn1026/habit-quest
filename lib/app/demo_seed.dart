import '../core/logical_day.dart';
import '../data/adventurer_repository.dart';
import '../data/check_in_repository.dart';
import '../data/habit_repository.dart';
import '../data/settings_repository.dart';
import '../data/story_repository.dart';
import '../domain/chapter.dart';
import '../domain/check_in.dart';
import '../domain/habit.dart';
import '../domain/hero_class.dart';
import '../domain/quest_rank.dart';
import '../domain/stat.dart';
import '../game/game_rules.dart';
import '../game/progression.dart';
import '../game/period.dart';
import '../game/xp.dart';

/// Fills an empty database with five weeks of believable history, for
/// development and screenshots. Never called in release builds.
/// The demo adventurer when the local profile doesn't name one.
const kDemoHeroName = '亞倫';
const kDemoIdentity = '每天進步一點的人';

Future<void> seedDemo({
  required AdventurerRepository adventurers,
  required HabitRepository habits,
  required CheckInRepository checkIns,
  required StoryRepository story,
  required SettingsRepository settings,
  required GameRules rules,
  required LogicalDay today,
  String heroName = kDemoHeroName,
  String identity = kDemoIdentity,
}) async {
  final start = today.addDays(-40);
  final at = start.startsAt(dayStartHour: rules.dayStartHour);

  final id = await adventurers.create(
    name: heroName,
    identity: identity,
    now: at,
  );
  await adventurers.setClass(
    id,
    HeroClass(
      name: '見習賢者',
      stats: const [Stat.intel, Stat.spi],
      since: start.addDays(8),
      flavor: '在書頁與靜默之間尋找力量的人。',
    ),
  );
  await adventurers.promote(id, QuestRank.d, today.addDays(-32));

  final reading = await habits.create(
    const HabitDraft(
      kind: HabitKind.build,
      name: '讀英文',
      unit: '分鐘',
      target: 20,
    ),
    const QuestDraft(
      rank: QuestRank.c,
      title: '破譯古代卷軸',
      subtitle: '～那些字母在對我低語～',
      spriteId: 'scroll',
      target: 20,
      attribute: Stat.intel,
    ),
    now: at,
    today: start,
  );
  final workout = await habits.create(
    const HabitDraft(
      kind: HabitKind.build,
      name: '運動',
      unit: '分鐘',
      target: 30,
      timesPerWeek: 3,
    ),
    const QuestDraft(
      rank: QuestRank.b,
      title: '鍛鍊騎士之軀',
      subtitle: '～肌肉痠痛是力量的證明～',
      spriteId: 'sword',
      target: 30,
      attribute: Stat.str,
    ),
    now: at,
    today: start,
  );
  final journal = await habits.create(
    const HabitDraft(kind: HabitKind.build, name: '寫日記'),
    const QuestDraft(
      rank: QuestRank.e,
      title: '記錄冒險日誌',
      subtitle: '～今天的我也很努力（大概）～',
      spriteId: 'quill',
      attribute: Stat.spi,
    ),
    now: at,
    today: start,
  );
  final phone = await habits.create(
    const HabitDraft(kind: HabitKind.quit, name: '十一點後滑手機'),
    const QuestDraft(
      rank: QuestRank.b,
      title: '深夜手機魔',
      subtitle: '～那道藍光正在吞噬你的睡眠～',
      spriteId: 'imp',
      attribute: Stat.spi,
    ),
    now: at,
    today: start,
  );

  Future<void> log(
    ActiveQuest aq,
    LogicalDay day,
    CheckInOutcome outcome, {
    double? amount,
    String? note,
  }) => checkIns.upsert(
    CheckIn(
      habitId: aq.habit.id,
      questId: aq.quest.id,
      day: day,
      outcome: outcome,
      amount: amount,
      note: note,
      xp: checkInXp(
        rules: rules,
        rank: aq.quest.rank,
        outcome: outcome,
        amount: amount,
        target: aq.quest.target,
      ),
      gold: checkInGold(
        rules: rules.progression,
        rank: aq.quest.rank,
        outcome: outcome,
        streakDays: 0,
      ),
      createdAt: day.startsAt(dayStartHour: 21),
    ),
  );

  for (var d = start; d.isBefore(today); d = d.addDays(1)) {
    final i = d.differenceInDays(start);
    // Reading: well past the target every day, so it earns an upgrade.
    await log(
      reading,
      d,
      CheckInOutcome.done,
      amount: 30.0 + (i % 2) * 5,
      note: i == 38 ? '看完一篇 BBC 新聞' : null,
    );
    if (d.weekday == DateTime.monday ||
        d.weekday == DateTime.wednesday ||
        d.weekday == DateTime.saturday) {
      await log(workout, d, CheckInOutcome.done, amount: 30.0 + (i % 3) * 5);
    }
    // Journal: missed yesterday, so today it is wounded.
    if (i % 9 != 4 && d != today.addDays(-1)) {
      await log(journal, d, CheckInOutcome.done);
    }
    await log(
      phone,
      d,
      i == 30 ? CheckInOutcome.relapsed : CheckInOutcome.resisted,
      note: i == 30 ? '追劇追到兩點' : null,
    );
  }

  final prologue = await story.createPending(
    number: 0,
    period: Period(start, 1),
    judgement: null,
    score: null,
    stats: const {},
    now: at,
  );
  await story.write(
    prologue.id,
    ChapterContent(
      title: '啟程',
      body:
          '王都邊境的冒險者公會，櫃檯小姐把一疊委託書推到你面前：'
          '「新人？先從這幾件開始吧。對了，城北的深夜手機魔最近很猖狂，'
          '如果你能封印牠，公會長會很高興的。」',
      choices: [StoryChoice('收下委託書'), StoryChoice('先去酒館打聽消息')],
      recap: '$heroName 在王都邊境的冒險者公會登記，接下第一批委託。',
    ),
    now: at,
  );
  await story.choose(prologue.id, 0);
  await settings.write(SettingKeys.onboarded, true);
}
