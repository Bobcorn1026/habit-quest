import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/casino_service.dart';
import '../../../app/town_service.dart';
import '../../../domain/casino.dart';
import '../../pixel/pixel.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import '../bank/bank_format.dart';
import 'casino_format.dart';
import 'casino_games.dart';
import 'casino_widgets.dart';

/// The casino's lobby: this week's price, the prize board and the games.
class CasinoScreen extends ConsumerStatefulWidget {
  const CasinoScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CasinoScreen()));

  @override
  ConsumerState<CasinoScreen> createState() => _CasinoScreenState();
}

class _CasinoScreenState extends ConsumerState<CasinoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The week may not be open yet when the bank opened since the town
      // last turned over.
      ref.read(townServiceProvider).rollover();
      if (mounted) showMentorTip(context, ref, MentorTip.casino);
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final view = ref.watch(casinoViewProvider).value;
    return PixelPage(
      title: '賭場',
      children: [
        if (view == null)
          Text('……', style: text.bodyMedium)
        else if (!view.open)
          CasinoClosedNotice(view: view)
        else ...[
          CasinoHeader(view: view),
          const SizedBox(height: 12),
          const PixelHeading('籤板', icon: PixelIcons.scroll),
          PrizeBoard(view: view),
          const SizedBox(height: 12),
          const PixelHeading('遊戲', icon: PixelIcons.coin),
          Text('四種遊戲抽的是同一副籤，挑喜歡的玩就好。', style: text.bodySmall),
          const SizedBox(height: 8),
          for (final game in CasinoGame.values) _GameCard(game: game),
          const SizedBox(height: 4),
          Text(
            '每張籤都有獎，抽到「退費」不收金幣。週日過完，沒抽完的獎金一半進投資帳戶、一半留在獎池分給之後的週。',
            style: text.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// What is left in the deck, tier by tier, like the board at a one-ban-kuji
/// counter.
class PrizeBoard extends StatelessWidget {
  const PrizeBoard({super.key, required this.view});

  final CasinoView view;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (topLeft, _) = view.count(PrizeTier.top);
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            topLeft > 0 ? '大獎還在！' : '大獎已經被抽走了',
            style: text.titleMedium?.copyWith(
              color: topLeft > 0 ? PixelPalette.goldLight : PixelPalette.steel,
            ),
          ),
          const SizedBox(height: 8),
          for (final tier in [...PrizeTier.values, null]) _row(context, tier),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, PrizeTier? tier) {
    final text = Theme.of(context).textTheme;
    final tickets = [
      for (final t in view.tickets)
        if (ticketTier(t) == tier) t,
    ];
    if (tickets.isEmpty) return const SizedBox.shrink();
    final left = tickets.where((t) => t.drawnAt == null).length;
    final amounts = tickets.map((t) => t.amount).toList()..sort();
    final money = tier == null
        ? '不收金幣'
        : amounts.first == amounts.last
        ? '${formatNtd(amounts.first)} 元'
        : '${formatNtd(amounts.first)}–${formatNtd(amounts.last)} 元';
    final gone = left == 0;
    return Opacity(
      opacity: gone ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            PixelSpriteView(gameTierIcon(tier)),
            const SizedBox(width: 8),
            SizedBox(
              width: 52,
              child: Text(
                tierName(tier),
                style: text.bodyLarge?.copyWith(color: tierColor(tier)),
              ),
            ),
            Expanded(child: Text(money, style: text.bodyMedium)),
            Text(
              '剩 $left／${tickets.length}',
              style: text.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final CasinoGame game;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (name, pitch) = gameText(game);
    void open() => openCasinoGame(context, game);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: open,
        child: PixelFrame(
          style: PixelFrameStyle.panel,
          child: Row(
            children: [
              PixelSpriteView(gameIcon(game)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.bodyLarge),
                    Text(pitch, style: text.bodySmall),
                  ],
                ),
              ),
              PixelButton(
                tone: PixelButtonTone.quiet,
                onPressed: open,
                child: const Text('玩'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
