import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/chapter.dart';
import 'package:habit_quest/domain/stat.dart';
import 'package:habit_quest/game/blessing.dart';
import 'package:habit_quest/game/period.dart';

import '../support/builders.dart';

void main() {
  const bless = Blessing(BlessingKind.xp, Stat.intel);
  Chapter chapter(int n, Period p, {int? chosen = 0}) => Chapter(
    id: n,
    number: n,
    period: p,
    status: ChapterStatus.written,
    choices: const [
      StoryChoice('去圖書館', blessing: bless),
      StoryChoice('睡覺'),
    ],
    chosenIndex: chosen,
    createdAt: DateTime(2026, 11, 1),
  );

  test('a chosen blessing lasts for the period after its chapter', () {
    final ch = [chapter(1, Period(monday, 7))];
    ActiveBlessing? at(int day) =>
        activeBlessing(chapters: ch, today: monday.addDays(day), periodDays: 7);
    expect(at(6), isNull, reason: 'its own period is over before it counts');
    expect(at(7)!.blessing, bless);
    expect(at(13)!.until, monday.addDays(13));
    expect(at(14), isNull);
  });

  test('no choice, no blessing; the newest chapter wins', () {
    expect(
      activeBlessing(
        chapters: [chapter(1, Period(monday, 7), chosen: null)],
        today: monday.addDays(8),
        periodDays: 7,
      ),
      isNull,
    );
    expect(
      activeBlessing(
        chapters: [
          chapter(1, Period(monday, 7), chosen: 1),
          chapter(2, Period(monday.addDays(7), 7)),
        ],
        today: monday.addDays(15),
        periodDays: 7,
      )!.blessing,
      bless,
    );
  });

  test('choices keep their blessing through JSON', () {
    final back = StoryChoice.fromJson(
      const StoryChoice('去圖書館', blessing: bless).toJson(),
    );
    expect(back.blessing, bless);
    expect(Blessing.fromJson({'kind': 'xp', 'stat': 'LUK'}), isNull);
  });
}
