import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/casino_service.dart';
import '../../../app/providers.dart';
import '../../../data/database.dart';
import '../../../domain/casino.dart';
import '../../pixel/pixel.dart';
import '../../pixel/sprites/bank_icons.dart';
import '../../widgets/casino_fx.dart';
import '../../widgets/pixel_controls.dart';
import '../bank/bank_format.dart';
import '../bank/bank_screen.dart';
import 'casino_format.dart';

/// How loud a ticket's reveal is.
FxSize fxSizeOf(CasinoTicketRow? t) =>
    switch (t == null ? null : ticketTier(t)) {
      PrizeTier.top => FxSize.jackpot,
      PrizeTier.high => FxSize.big,
      PrizeTier.mid => FxSize.small,
      _ => FxSize.none,
    };

/// The loudest reveal among [tickets].
FxSize loudest(Iterable<CasinoTicketRow> tickets) => tickets
    .map(fxSizeOf)
    .fold(FxSize.none, (a, b) => b.index > a.index ? b : a);

/// Best ticket first: by tier, a refund last, then by money.
int compareTickets(CasinoTicketRow a, CasinoTicketRow b) {
  final ta = ticketTier(a)?.index ?? 9, tb = ticketTier(b)?.index ?? 9;
  return ta != tb ? ta.compareTo(tb) : b.amount.compareTo(a.amount);
}

/// The best of [tickets] (not empty).
CasinoTicketRow bestOf(Iterable<CasinoTicketRow> tickets) =>
    tickets.reduce((a, b) => compareTickets(b, a) < 0 ? b : a);

/// The price, the player's gold and the money still in the deck.
class CasinoHeader extends ConsumerWidget {
  const CasinoHeader({super.key, required this.view, this.gold});

  final CasinoView view;

  /// Shown instead of the player's gold, while a result is still hidden.
  final int? gold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final live = ref.watch(goldProvider).value ?? 0;
    final gold = this.gold ?? live;
    final week = view.week;
    final released = week?.released ?? 0;
    return PixelFrame(
      style: PixelFrameStyle.ornate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const PixelSpriteView(PixelIcons.coin),
              const SizedBox(width: 8),
              Expanded(child: Text('$gold 金幣', style: text.titleLarge)),
              Text(
                '一抽 ${view.price} 金幣',
                style: text.titleMedium?.copyWith(
                  color: PixelPalette.goldLight,
                ),
              ),
            ],
          ),
          if (released > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('本週獎金還剩', style: text.bodySmall)),
                Text(
                  '${formatNtd(view.moneyLeft)}／${formatNtd(released)} 元',
                  style: text.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            PixelBar(
              value: view.moneyLeft / released,
              segments: view.tickets.length,
            ),
          ],
        ],
      ),
    );
  }
}

/// What a ticket turned out to be, counting the money up.
class PrizeReveal extends StatelessWidget {
  const PrizeReveal({super.key, required this.ticket, required this.view});

  final CasinoTicketRow ticket;
  final CasinoView view;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tier = ticketTier(ticket);
    final account = view.accounts[ticket.accountId];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelSpriteView(tierSymbol(tier)),
        const SizedBox(height: 8),
        Text(
          tier == null ? '退費！' : '${tierName(tier)}！',
          style: text.displaySmall?.copyWith(color: tierColor(tier)),
        ),
        const SizedBox(height: 4),
        if (tier == null)
          Text('這一抽不收金幣，再抽一次吧', style: text.bodyMedium)
        else ...[
          CountUpText(
            ticket.amount,
            prefix: '+',
            suffix: ' 元',
            style: text.titleLarge,
          ),
          if (account != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('放進', style: text.bodySmall),
                const SizedBox(width: 4),
                PixelSpriteView(PixelBankIcons.byId(account.icon)),
                const SizedBox(width: 4),
                Text(account.name, style: text.bodySmall),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

/// A short line for a draw that stopped early; null when there is nothing
/// to say.
String? stopMessage(DrawStop stop, int price) => switch (stop) {
  DrawStop.done => null,
  DrawStop.notEnoughGold => '金幣不夠：一抽要 $price 金幣',
  DrawStop.deckEmpty => '這週的籤抽完了，下週一再來',
  DrawStop.closed => '賭場這週沒有開',
};

/// Tells the player why a draw stopped short.
void showStop(BuildContext context, DrawOutcome outcome, int price) {
  final message = stopMessage(outcome.stop, price);
  if (message != null) {
    showPixelToast(context, message, icon: PixelIcons.skull);
  }
}

/// The results of drawing several at once.
Future<void> showDrawSummary(
  BuildContext context,
  DrawOutcome outcome,
  CasinoView view,
) => showPixelDialog<void>(
  context,
  builder: (ctx) => _DrawSummary(outcome: outcome, view: view),
);

class _DrawSummary extends StatelessWidget {
  const _DrawSummary({required this.outcome, required this.view});

  final DrawOutcome outcome;
  final CasinoView view;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final drawn = [...outcome.drawn]..sort(compareTickets);
    return WinFx(
      shot: 1,
      size: loudest(drawn),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '連抽 ${drawn.length} 次',
            style: text.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          for (final t in drawn)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  PixelSpriteView(gameTierIcon(ticketTier(t))),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 56,
                    child: Text(
                      tierName(ticketTier(t)),
                      style: text.bodyMedium?.copyWith(
                        color: tierColor(ticketTier(t)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.kind == TicketKind.refund
                          ? '不收金幣'
                          : view.accounts[t.accountId]?.name ?? '',
                      style: text.bodySmall,
                    ),
                  ),
                  if (t.amount > 0)
                    Text('+${formatNtd(t.amount)} 元', style: text.bodyMedium),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '共贏 ${formatNtd(outcome.won)} 元',
            style: text.titleMedium?.copyWith(color: PixelPalette.goldLight),
            textAlign: TextAlign.center,
          ),
          if (stopMessage(outcome.stop, view.price) case final m?) ...[
            const SizedBox(height: 4),
            Text(m, style: text.bodySmall, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 12),
          PixelButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('收下'),
          ),
        ],
      ),
    );
  }
}

/// A 16×16 icon for a tier, for lists.
PixelSprite gameTierIcon(PrizeTier? tier) => switch (tier) {
  PrizeTier.top => PixelIcons.crown,
  PrizeTier.high => PixelIcons.star,
  PrizeTier.mid => PixelIcons.flame,
  PrizeTier.low => PixelIcons.potion,
  null => PixelIcons.scroll,
};

/// The buttons under a game: one draw, or several at once.
class DrawButtons extends ConsumerWidget {
  const DrawButtons({
    super.key,
    required this.view,
    required this.onDraw,
    this.label = '抽一次',
    this.many = 5,
    this.busy = false,
  });

  final CasinoView view;
  final void Function(int times) onDraw;
  final String label;

  /// How many the second button draws; 0 hides it.
  final int many;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold = ref.watch(goldProvider).value ?? 0;
    final can =
        !busy && view.open && view.left.isNotEmpty && gold >= view.price;
    return Row(
      children: [
        Expanded(
          child: PixelButton(
            expand: true,
            onPressed: can ? () => onDraw(1) : null,
            child: Text('$label（${view.price} 金幣）'),
          ),
        ),
        if (many > 1) ...[
          const SizedBox(width: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            onPressed: can ? () => onDraw(many) : null,
            child: Text('連抽 $many'),
          ),
        ],
      ],
    );
  }
}

/// Why there is nothing to draw this week, and where to go about it.
class CasinoClosedNotice extends StatelessWidget {
  const CasinoClosedNotice({super.key, required this.view});

  final CasinoView view;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (title, detail) = switch (view.closed) {
      CasinoClosed.noBank => ('還沒有獎池', '賭場的獎金來自銀行的獎池。先到銀行開戶，下次來就有籤可以抽了。'),
      CasinoClosed.emptyPool => ('這週休息', '獎池這週沒有錢可以發。下個月 1 號補充獎池後，賭場就會重新開張。'),
      _ => ('準備中', '這週的籤還在準備，稍等一下。'),
    };
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: text.titleLarge),
          const SizedBox(height: 4),
          Text(detail, style: text.bodyMedium),
          if (view.closed == CasinoClosed.noBank) ...[
            const SizedBox(height: 12),
            PixelButton(
              onPressed: () => BankScreen.open(context),
              child: const Text('去銀行'),
            ),
          ],
        ],
      ),
    );
  }
}
