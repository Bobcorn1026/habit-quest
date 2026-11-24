import 'package:flutter/material.dart';

import '../../../data/database.dart';
import '../../../domain/casino.dart';
import '../../pixel/pixel.dart';

/// The name of a prize tier on the board, one-ban-kuji style.
String tierName(PrizeTier? tier) => switch (tier) {
  PrizeTier.top => 'A賞',
  PrizeTier.high => 'B賞',
  PrizeTier.mid => 'C賞',
  PrizeTier.low => 'D賞',
  null => '退費',
};

/// The color a tier is written in.
Color tierColor(PrizeTier? tier) => switch (tier) {
  PrizeTier.top => PixelPalette.goldLight,
  PrizeTier.high => PixelPalette.violetLight,
  PrizeTier.mid => PixelPalette.tealLight,
  PrizeTier.low => PixelPalette.parchment,
  null => PixelPalette.steelLight,
};

/// The symbol of a tier on the slot reels and in the chests: a crown for
/// the top prize, and a die for a refund (roll again).
PixelSprite tierSymbol(PrizeTier? tier) => switch (tier) {
  PrizeTier.top => PixelArt.crown,
  PrizeTier.high => PixelArt.star,
  PrizeTier.mid => PixelArt.flame,
  PrizeTier.low => PixelArt.potion,
  null => PixelArt.d20,
};

/// All symbols, in reel order.
const kReelSymbols = [
  PixelArt.crown,
  PixelArt.star,
  PixelArt.flame,
  PixelArt.potion,
  PixelArt.d20,
];

PrizeTier? ticketTier(CasinoTicketRow t) =>
    t.kind == TicketKind.refund ? null : t.tier;

/// What a game is called in the lobby, and its one-line pitch.
(String name, String pitch) gameText(CasinoGame game) => switch (game) {
  CasinoGame.slots => ('拉霸', '三個一樣就中，轉轉看'),
  CasinoGame.grid => ('格子抽獎', '從板子上挑一格掀開'),
  CasinoGame.scratch => ('刮刮樂', '用手指刮開銀漆'),
  CasinoGame.chest => ('寶箱三選一', '三個寶箱挑一個開'),
};

/// The icon of a game's card.
PixelSprite gameIcon(CasinoGame game) => switch (game) {
  CasinoGame.slots => PixelIcons.crown,
  CasinoGame.grid => PixelIcons.scroll,
  CasinoGame.scratch => PixelIcons.coin,
  CasinoGame.chest => PixelIcons.chest,
};
