import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/domain/story_config.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/ai/ai_tasks.dart';
import 'package:habit_quest/ai/response_parser.dart';
import 'package:habit_quest/domain/quest_rank.dart';

import 'fixtures.dart';

void main() {
  group('extractJson', () {
    test('reads a fenced block surrounded by chatter', () {
      expect(extractJson('嗨\n```json\n{"a":1}\n```\n掰'), {'a': 1});
    });

    test('reads bare JSON and JSON with prose around it', () {
      expect(extractJson('{"a":1}'), {'a': 1});
      expect(extractJson('這是結果：{"a":{"b":2}} 以上'), {
        'a': {'b': 2},
      });
    });

    test('returns null for non-JSON', () {
      expect(extractJson('我不知道你在說什麼'), isNull);
      expect(extractJson('{壞掉的 json'), isNull);
    });
  });

  group('parseForge', () {
    test('accepts a chatty reply and repairs small issues', () {
      final out = parseForge(forgeReply, forgeRequest);
      expect(out, isA<Parsed<ForgeResult>>());
      final r = (out as Parsed<ForgeResult>).value;
      expect(r.questFor('h1')!.rank, QuestRank.c);
      expect(r.questFor('h1')!.subtitle, '～那些字母在對我低語～');
      expect(
        r.questFor('h2')!.spriteId,
        'imp',
        reason: 'an unknown seal sprite falls back to a monster from its name',
      );
      expect(r.questFor('h1')!.attribute, Stat.intel, reason: 'from the reply');
      expect(
        r.questFor('h2')!.attribute,
        Stat.spi,
        reason: 'missing attribute is guessed from the habit',
      );
      expect(r.world!.npcs.single.name, '莉娜');
      expect(r.prologue!.choices, hasLength(3), reason: 'clamped to config');
    });

    test('keeps sprites only where they fit the habit kind', () {
      final reply = forgeReply
          .replaceFirst('"spriteId": "scroll"', '"spriteId": "owl"')
          .replaceFirst('"spriteId": "nope"', '"spriteId": "ghost"');
      final r = (parseForge(reply, forgeRequest) as Parsed<ForgeResult>).value;
      expect(
        r.questFor('h1')!.spriteId,
        'scroll',
        reason: 'monsters are for seals',
      );
      expect(r.questFor('h2')!.spriteId, 'ghost');
    });

    test('rejects a reply for another request', () {
      final out = parseForge(
        forgeReply.replaceAll('abc234', 'other1'),
        forgeRequest,
      );
      expect(out, isA<ParseFailed<ForgeResult>>());
      expect((out as ParseFailed).problems.single, contains('另一次請求'));
    });

    test('reports missing quests by key and habit name', () {
      final out = parseForge(
        '{"quests":[{"key":"h1","title":"x"}],"prologue":{"body":"y"}}',
        forgeRequest,
      );
      final problems = (out as ParseFailed).problems;
      expect(problems.single, contains('h2'));
      expect(problems.single, contains('十一點後滑手機'));
    });

    test('a missing prologue is a problem only when one was asked for', () {
      const reply =
          '{"quests":[{"key":"h1","title":"a"},{"key":"h2","title":"b"}]}';
      expect(parseForge(reply, forgeRequest), isA<ParseFailed>());
      const noPrologue = ForgeRequest(
        requestId: 'abc234',
        heroName: '亞倫',
        habits: [...[]],
        config: forgeRequestConfig,
      );
      expect(parseForge('{"quests":[]}', noPrologue), isA<Parsed>());
    });

    test('garbage is a single clear problem', () {
      final out = parseForge('抱歉，我無法協助', forgeRequest);
      expect((out as ParseFailed).problems.single, contains('JSON'));
    });
  });

  group('parseChapter', () {
    test('keeps wanted upgrades and clamps the bonus to 0–1', () {
      final out = parseChapter(chapterReply, chapterRequest);
      final r = (out as Parsed<ChapterResult>).value;
      expect(r.content.title, '霧之圖書館');
      expect(r.content.choices, hasLength(3));
      expect(r.qualityBonus, 0.5);
      expect(r.upgrades.single.questKey, 'h1');
      expect(r.upgrades.single.subtitle, '～更難的文字～');
    });

    test('requires choices when the story asks for them', () {
      final out = parseChapter(
        '{"title":"t","body":"b","choices":[],"recap":"r","qualityBonus":0}',
        chapterRequest,
      );
      expect((out as ParseFailed).problems.single, contains('choices'));
    });

    test('fills a missing recap and non-numeric bonus with warnings', () {
      final out = parseChapter(
        '{"title":"t","body":"很長的本文","choices":[{"label":"走"}],'
        '"qualityBonus":"高"}',
        chapterRequest,
      );
      final parsed = out as Parsed<ChapterResult>;
      expect(parsed.value.content.recap, '很長的本文');
      expect(parsed.value.qualityBonus, 0);
      expect(parsed.warnings, hasLength(3));
    });
  });

  test('upgrade proposals keep the target within the allowed range', () {
    const request = UpgradeRequest(
      requestId: 'up2345',
      config: StoryConfig(),
      reason: UpgradeReason.surpass,
      questTitle: '破譯古代卷軸',
      habitName: '讀英文',
      unit: '分鐘',
      currentTarget: 20,
      suggestedTarget: 25,
      minTarget: 22,
      maxTarget: 40,
      nextRank: QuestRank.b,
    );
    final out = parseUpgrade(
      '{"protocol":"hq-1","requestId":"up2345","title":"解讀星辰之書",'
      '"subtitle":"星星在說話","npcLine":"呼啊……你又超標了。","target":90}',
      request,
    );
    final p = (out as Parsed<UpgradeProposal>).value;
    expect(p.title, '解讀星辰之書');
    expect(p.subtitle, '～星星在說話～');
    expect(p.target, 40);
  });

  test('every chapter choice ends up with a blessing for a quest stat', () {
    final out = parseChapter(
      '{"protocol":"hq-1","requestId":"zz9xyz","title":"霧之門","body":"……",'
      '"choices":[{"label":"去圖書館查古籍","hint":"","blessing":{"kind":"xp","stat":"INT"}},'
      '{"label":"去酒館打聽","hint":"","blessing":{"kind":"gold","stat":"CHA"}},'
      '{"label":"睡一覺","hint":""}],'
      '"recap":"……","qualityBonus":0.1,"upgrades":[]}',
      chapterRequest,
    );
    final choices = (out as Parsed<ChapterResult>).value.content.choices;
    final stats = {for (final h in chapterRequest.habits) h.attribute};
    expect(choices.first.blessing, const Blessing(BlessingKind.xp, Stat.intel));
    for (final c in choices) {
      expect(stats, contains(c.blessing!.stat));
    }
  });

  test('a side quest must point at something the app can track', () {
    String reply(String side) =>
        '{"protocol":"hq-1","requestId":"zz9xyz","title":"霧之門","body":"……",'
        '"choices":[{"label":"前進","hint":""}],"recap":"……",'
        '"qualityBonus":0,"upgrades":[],"sideQuest":$side}';
    ChapterResult parse(String side) => (parseChapter(
      reply(side),
      chapterRequest,
    ) as Parsed<ChapterResult>).value;

    final ok = parse(
      '{"title":"圖書館的委託","story":"……","kind":"questCount",'
      '"questKey":"h1","stat":null,"target":99}',
    ).sideQuest!;
    expect(ok.questKey, 'h1');
    expect(ok.target, 7, reason: 'clamped to the period');

    expect(
      parse(
        '{"title":"x","story":"","kind":"sealClean","questKey":"h1",'
        '"stat":null,"target":3}',
      ).sideQuest,
      isNull,
      reason: 'h1 is not a seal',
    );
  });
}
