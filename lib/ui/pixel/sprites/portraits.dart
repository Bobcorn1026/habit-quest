import '../sprite.dart';
import 'mentor_frames.dart';
import 'portrait_art.dart';

/// 48×48 adventurer portraits, picked from the hero's class name.
abstract final class PixelPortraits {
  static const knight = PortraitArt.knight;

  static const mage = PortraitArt.mage;

  static const ranger = PortraitArt.ranger;

  static const rogue = PortraitArt.rogue;

  static const cleric = PortraitArt.cleric;

  /// 莉娜, the guild receptionist who guides new players. Not an
  /// adventurer portrait, so she is not in [all].
  static const mentor = MentorFrames.idle;

  static const all = [knight, mage, ranger, rogue, cleric];

  static const _byClass = <(List<String>, PixelSprite)>[
    (['賢者', '法師', '魔法', '魔導', '巫', '術士', '學者', '智者', '占星'], mage),
    (['遊俠', '獵人', '弓', '斥候', '探險', '旅人', '森林'], ranger),
    (['盜賊', '刺客', '影', '忍', '怪盜', '密探'], rogue),
    (['僧侶', '牧師', '祭司', '聖', '修士', '修女', '神官', '治癒', '巡禮'], cleric),
  ];

  /// The chosen portrait, or the one that fits the class name.
  static PixelSprite forAdventurer(String? portraitId, String? heroClass) =>
      all.where((p) => p.id == portraitId).firstOrNull ?? forClass(heroClass);

  /// The portrait whose keywords appear in [heroClass]; knights by default.
  static PixelSprite forClass(String? heroClass) {
    final c = heroClass ?? '';
    for (final (keys, sprite) in _byClass) {
      if (keys.any(c.contains)) return sprite;
    }
    return knight;
  }
}
