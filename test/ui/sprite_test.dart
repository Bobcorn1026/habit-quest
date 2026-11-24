import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ui/pixel/palette.dart';
import 'package:habit_quest/domain/sprite_ids.dart';
import 'package:habit_quest/ui/pixel/sprite.dart';
import 'package:habit_quest/ui/pixel/sprites/buildings.dart';
import 'package:habit_quest/ui/pixel/sprites/icons.dart';
import 'package:habit_quest/ui/pixel/sprites/large_icons.dart';
import 'package:habit_quest/ui/pixel/sprites/mentor_frames.dart';
import 'package:habit_quest/ui/pixel/sprites/monsters.dart';
import 'package:habit_quest/ui/pixel/sprites/portraits.dart';

void expectGrid(PixelSprite sprite, int size) {
  expect(sprite.height, size, reason: 'row count of ${sprite.id}');
  for (final (i, row) in sprite.rows.indexed) {
    expect(row.length, size, reason: 'row $i of ${sprite.id}');
    for (final ch in row.split('')) {
      expect(
        ch == '.' || PixelPalette.byKey.containsKey(ch),
        isTrue,
        reason: 'unknown key "$ch" in row $i of ${sprite.id}',
      );
    }
  }
}

void main() {
  test('runs are parsed once per sprite', () {
    const sprite = PixelSprite('t', ['rr.', '.rr']);
    expect(identical(sprite.runs, sprite.runs), isTrue);
    expect(sprite.runs, hasLength(2));
  });

  group('PixelIcons', () {
    for (final sprite in PixelIcons.all) {
      test('${sprite.id} is a 16×16 grid of known palette keys', () {
        expectGrid(sprite, 16);
      });
    }

    test('ids are unique', () {
      final ids = PixelIcons.all.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId falls back to the scroll', () {
      expect(PixelIcons.byId('flame'), same(PixelIcons.flame));
      expect(PixelIcons.byId('nope'), same(PixelIcons.scroll));
    });
  });

  group('PixelArt', () {
    for (final sprite in [...PixelArt.all, ...PixelMonsters.all]) {
      test('${sprite.id} is a 32×32 grid of known palette keys', () {
        expectGrid(sprite, 32);
      });
    }

    for (final sprite in [
      ...PixelPortraits.all,
      MentorFrames.idle,
      MentorFrames.blink,
      MentorFrames.yawnStart,
      MentorFrames.yawn,
    ]) {
      test('portrait ${sprite.id} is a 48×48 grid of known palette keys', () {
        expectGrid(sprite, 48);
      });
    }

    test('every quest sprite id has both sizes', () {
      expect(PixelArt.all.map((s) => s.id), kQuestSpriteIds);
      expect(PixelIcons.all.map((s) => s.id), kQuestSpriteIds);
      expect(PixelArt.byId('nope'), same(PixelArt.scroll));
    });
  });

  test('runs merge same-colored neighbours', () {
    final runs = PixelIcons.scroll.runs.where((r) => r.y == 1).toList();
    expect(runs, hasLength(1));
    expect(runs.single.length, 14);
  });

  group('town art', () {
    for (final sprite in const [
      PixelBuildings.dojo,
      PixelBuildings.bank,
      PixelBuildings.casino,
      PixelBuildings.guild,
    ]) {
      test('${sprite.id} is a 32×32 grid of known palette keys', () {
        expectGrid(sprite, 32);
      });
    }

    test('the town tab icon is 16×16 and not a quest icon', () {
      expectGrid(kTownIcon, 16);
      expect(PixelIcons.all.map((s) => s.id), isNot(contains('town')));
    });
  });
}
