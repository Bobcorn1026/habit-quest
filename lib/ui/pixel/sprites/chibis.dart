import '../sprite.dart';

/// 16×16 chibi adventurers cheering with their arms up, for celebrations.
abstract final class PixelChibis {
  static const knight = PixelSprite('chibi_knight', [
    '................',
    '.......rr.......',
    '.....kkkRkk.....',
    '....keeeeeEk....',
    '...keeeeeeEak...',
    '...keEEEEEEak...',
    'kk.kEsssssSak.kk',
    'ksk.kskssksk.ksk',
    '.ksksshsshSSksk.',
    '..kskssssSSksk..',
    '...kkkSSSSkkk...',
    '....keeeEEak....',
    '....keeGEEak....',
    '....keEEEaak....',
    '.....kkk.kkk....',
    '................',
  ]);

  static const mage = PixelSprite('chibi_mage', [
    '.........k......',
    '........vVk.....',
    '.....kkkkkk.....',
    '....kvvvvvVk....',
    '...kvvvvvvVik...',
    '...kvVVVVVVik...',
    'kk.kVsssssSik.kk',
    'ksk.kskssksk.ksk',
    '.ksksshsshSSksk.',
    '..kskssssSSksk..',
    '...kkkSSSSkkk...',
    '....kvvvVVik....',
    '....kvvGVVik....',
    '....kvVVViik....',
    '.....kkk.kkk....',
    '................',
  ]);

  static const cleric = PixelSprite('chibi_cleric', [
    '................',
    '................',
    '.....kkkkkk.....',
    '....kwwwwwek....',
    '...kwwwGGweEk...',
    '...kweeeeeeEk...',
    'kk.kesssssSEk.kk',
    'ksk.kskssksk.ksk',
    '.ksksshsshSSksk.',
    '..kskssssSSksk..',
    '...kkkSSSSkkk...',
    '....kwwweeTk....',
    '....kwwGeeTk....',
    '....kweeeTTk....',
    '.....kkk.kkk....',
    '................',
  ]);

  static const mentor = PixelSprite('chibi_mentor', [
    '........kk......',
    '.......kfk......',
    '...kTkkkfkk.....',
    '..ktkggfffRk....',
    '..kkgfffffRRk...',
    '...kfRffRfRRk...',
    'kk.kfRsssRSRk.kk',
    'ksk.kskssksk.ksk',
    '.kskshTssThSksk.',
    '..kskssxsSSksk..',
    '...kfkSSSSkRk...',
    '....ktwwwwuk....',
    '....kttGTTuk....',
    '....ktTTTuuk....',
    '.....kkk.kkk....',
    '................',
  ]);

  static const ranger = PixelSprite('chibi_ranger', [
    '................',
    '................',
    '.....kkkkkk.....',
    '....knnnnnNk....',
    '...knnnnnnNlk...',
    '...knNNNNNNlk...',
    'kk.kNsssssSlk.kk',
    'ksk.kskssksk.ksk',
    '.ksksshsshSSksk.',
    '..kskssssSSksk..',
    '...kkkSSSSkkk...',
    '....knnnNNlk....',
    '....knnGNNlk....',
    '....knNNNllk....',
    '.....kkk.kkk....',
    '................',
  ]);

  static const all = [knight, mage, cleric, mentor, ranger];
}
