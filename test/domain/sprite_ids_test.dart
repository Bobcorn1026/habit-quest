import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/domain/sprite_ids.dart';
import 'package:habit_quest/ui/pixel/sprites/monsters.dart';
import 'package:habit_quest/ui/pixel/sprites/portraits.dart';

void main() {
  group('guessMonster', () {
    test('matches common bad habits', () {
      expect(guessMonster('十一點後滑手機'), 'imp');
      expect(guessMonster('熬夜'), 'owl');
      expect(guessMonster('睡前吃零食'), 'slime');
      expect(guessMonster('亂網購'), 'mimic');
      expect(guessMonster('抽菸'), 'wisp');
      expect(guessMonster('拖延作業'), 'ghost');
      expect(guessMonster('Threads 刷不停'), 'imp');
    });

    test('unknown habits get a stable monster', () {
      final a = guessMonster('咬指甲');
      expect(kMonsterSpriteIds, contains(a));
      expect(guessMonster('咬指甲'), a);
    });
  });

  test('older seals saved as `seal` still show a monster', () {
    expect(PixelMonsters.forSeal('seal', '十一點後滑手機').id, 'imp');
    expect(PixelMonsters.forSeal('ghost', '十一點後滑手機').id, 'ghost');
  });

  test('portraits follow the class name', () {
    expect(PixelPortraits.forClass('見習賢者'), same(PixelPortraits.mage));
    expect(PixelPortraits.forClass('森林遊俠'), same(PixelPortraits.ranger));
    expect(PixelPortraits.forClass('暗影盜賊'), same(PixelPortraits.rogue));
    expect(PixelPortraits.forClass('巡禮僧侶'), same(PixelPortraits.cleric));
    expect(PixelPortraits.forClass('流浪劍士'), same(PixelPortraits.knight));
    expect(PixelPortraits.forClass(null), same(PixelPortraits.knight));
  });
}
