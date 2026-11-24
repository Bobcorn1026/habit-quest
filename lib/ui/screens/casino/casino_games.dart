import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/casino_service.dart';
import '../../../app/providers.dart';
import '../../../core/logical_day.dart';
import '../../../data/database.dart';
import '../../../domain/casino.dart';
import '../../pixel/pixel.dart';
import '../../widgets/casino_fx.dart';
import '../../widgets/pixel_page.dart';
import 'casino_format.dart';
import 'casino_widgets.dart';

/// Opens [game]'s page.
Future<void> openCasinoGame(BuildContext context, CasinoGame game) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => switch (game) {
          CasinoGame.slots => const SlotsScreen(),
          CasinoGame.grid => const GridScreen(),
          CasinoGame.scratch => const ScratchScreen(),
          CasinoGame.chest => const ChestScreen(),
        },
      ),
    );

/// The header as it was before a draw whose result is still hidden: the
/// draw is written before the reels spin (or the foil comes off), and the
/// live gold and prize money would give the result away.
typedef FrozenHeader = ({CasinoView view, int gold});

FrozenHeader? _headerNow(WidgetRef ref) {
  final view = ref.read(casinoViewProvider).value;
  return view == null
      ? null
      : (view: view, gold: ref.read(goldProvider).value ?? 0);
}

/// A game's page: the header, the game, and whatever goes below it.
class _GamePage extends ConsumerWidget {
  const _GamePage({
    required this.game,
    required this.builder,
    this.bottom,
    this.frozen,
  });

  final CasinoGame game;
  final Widget Function(CasinoView view) builder;
  final Widget Function(CasinoView view)? bottom;

  /// Shown in the header instead of the live figures.
  final FrozenHeader? frozen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(casinoViewProvider).value;
    final (name, _) = gameText(game);
    return PixelPage(
      title: name,
      bottom: view == null || !view.open || bottom == null
          ? null
          : bottom!(view),
      children: [
        // Between the week turning over and its deck being dealt there is
        // no week to play: say so instead of building the game on nothing.
        if (view != null && view.open) ...[
          CasinoHeader(view: frozen?.view ?? view, gold: frozen?.gold),
          const SizedBox(height: 12),
          builder(view),
        ] else if (view != null)
          CasinoClosedNotice(view: view),
      ],
    );
  }
}

// ── Slots ────────────────────────────────────────────────────────────────

class SlotsScreen extends ConsumerStatefulWidget {
  const SlotsScreen({super.key});

  @override
  ConsumerState<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends ConsumerState<SlotsScreen> {
  CasinoTicketRow? _last;
  int _spin = 0;

  /// The last spin [_landed] reported; behind [_spin] while one is out.
  int _landedSpin = 0;
  int _shot = 0;
  bool _busy = false;
  DrawOutcome? _many;
  FrozenHeader? _frozen;

  /// How loud the last landing was; set only once the reels stop, so the
  /// effects can't give the result away while they spin.
  FxSize _fx = FxSize.none;

  Future<void> _draw(int times) async {
    setState(() {
      _busy = true;
      _frozen = _headerNow(ref);
    });
    final DrawOutcome outcome;
    try {
      outcome = await ref
          .read(casinoServiceProvider)
          .draw(game: CasinoGame.slots, times: times);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _frozen = null;
        });
      }
      rethrow;
    }
    if (!mounted) return;
    if (outcome.drawn.isEmpty) {
      setState(() {
        _busy = false;
        _frozen = null;
      });
      showStop(
        context,
        outcome,
        ref.read(casinoViewProvider).value?.price ?? 0,
      );
      return;
    }
    // Several at once spin to the best of them, then list them all.
    final shown = bestOf(outcome.drawn);
    setState(() {
      _last = shown;
      _many = times == 1 ? null : outcome;
      _spin++;
    });
  }

  Future<void> _landed() async {
    if (!mounted || _landedSpin == _spin) return;
    setState(() {
      _landedSpin = _spin;
      _busy = false;
      _frozen = null;
      _fx = fxSizeOf(_last);
      _shot++;
    });
    final many = _many;
    final view = ref.read(casinoViewProvider).value;
    if (many != null && view != null) {
      _many = null;
      await showDrawSummary(context, many, view);
    }
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    game: CasinoGame.slots,
    frozen: _frozen,
    builder: (view) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WinFx(
          shot: _shot,
          size: _fx,
          child: PixelFrame(
            style: PixelFrameStyle.ornate,
            child: SlotReels(
              spin: _spin,
              result: _last == null ? null : ticketTier(_last!),
              hasResult: _last != null,
              landed: _landedSpin == _spin,
              onLanded: _landed,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_last != null && !_busy)
          PrizeReveal(key: ValueKey(_shot), ticket: _last!, view: view),
      ],
    ),
    bottom: (view) =>
        DrawButtons(view: view, label: '拉一次', busy: _busy, onDraw: _draw),
  );
}

/// Three reels that spin and stop from the left on [result]'s symbol;
/// calls [onLanded] when the last one stops. Before the first spin they
/// show a crown, a star and a flame.
///
/// The game page drops the reels while the week turns over ("準備中"), so a
/// spin can be cut off, or asked for while there are none: when they come
/// back with [landed] false they show the result and land at once.
class SlotReels extends StatefulWidget {
  const SlotReels({
    super.key,
    required this.spin,
    required this.result,
    required this.hasResult,
    required this.onLanded,
    this.landed = true,
  });

  final int spin;
  final PrizeTier? result;
  final bool hasResult;

  /// Whether [onLanded] was already called for [spin].
  final bool landed;
  final VoidCallback onLanded;

  @override
  State<SlotReels> createState() => _SlotReelsState();
}

class _SlotReelsState extends State<SlotReels>
    with SingleTickerProviderStateMixin {
  late final _run =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onLanded();
      });

  @override
  void initState() {
    super.initState();
    if (!widget.landed) {
      final landed = widget.onLanded;
      WidgetsBinding.instance.addPostFrameCallback((_) => landed());
    }
  }

  @override
  void didUpdateWidget(SlotReels old) {
    super.didUpdateWidget(old);
    if (widget.spin == old.spin) return;
    if (reduceMotion(context)) {
      // No spin: the reels already show the result.
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLanded());
    } else {
      _run.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  double _stopAt(int reel) => 0.45 + 0.55 * (reel + 1) / 3;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _run,
    builder: (context, _) {
      final t = _run.value;
      final spinning = _run.isAnimating;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var reel = 0; reel < 3; reel++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: PixelFrame(
                style: PixelFrameStyle.parchment,
                padding: const EdgeInsets.all(8),
                child: PixelSpriteView(
                  !widget.hasResult
                      ? kReelSymbols[reel]
                      : spinning && t < _stopAt(reel)
                      ? kReelSymbols[((t * 28).floor() + reel * 2) %
                            kReelSymbols.length]
                      : tierSymbol(widget.result),
                ),
              ),
            ),
        ],
      );
    },
  );
}

// ── Grid ─────────────────────────────────────────────────────────────────

class GridScreen extends ConsumerStatefulWidget {
  const GridScreen({super.key});

  @override
  ConsumerState<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends ConsumerState<GridScreen> {
  final _revealKey = GlobalKey();
  CasinoTicketRow? _last;
  int _shot = 0;
  bool _busy = false;

  Future<void> _pick(int? ticketId, {int times = 1}) async {
    setState(() => _busy = true);
    final DrawOutcome outcome;
    try {
      outcome = await ref
          .read(casinoServiceProvider)
          .draw(game: CasinoGame.grid, times: times, ticketId: ticketId);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      rethrow;
    }
    if (!mounted) return;
    final view = ref.read(casinoViewProvider).value;
    setState(() {
      _busy = false;
      if (outcome.drawn.isNotEmpty && times == 1) {
        _last = outcome.drawn.single;
        _shot++;
      }
    });
    if (outcome.drawn.isNotEmpty && times == 1) {
      // A full board pushes the result below the buttons on a phone.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _revealKey.currentContext;
        if (target == null || !target.mounted) return;
        Scrollable.ensureVisible(
          target,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: reduceMotion(target)
              ? Duration.zero
              : const Duration(milliseconds: 250),
        );
      });
    }
    if (outcome.drawn.isEmpty) {
      showStop(context, outcome, view?.price ?? 0);
    } else if (times > 1 && view != null) {
      await showDrawSummary(context, outcome, view);
    }
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    game: CasinoGame.grid,
    builder: (view) {
      final text = Theme.of(context).textTheme;
      final gold = ref.watch(goldProvider).value ?? 0;
      final can = !_busy && gold >= view.price;
      // Every ticket keeps its square all week: shuffled by the week, so
      // the board looks the same each time it opens.
      final tiles = [...view.tickets]
        ..shuffle(math.Random(view.week!.weekStart.toKey().hashCode));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            gold >= view.price
                ? '挑一格掀開（${view.price} 金幣）'
                : '金幣不夠：一抽要 ${view.price} 金幣',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          WinFx(
            shot: _shot,
            size: fxSizeOf(_last),
            child: PixelFrame(
              style: PixelFrameStyle.ornate,
              padding: const EdgeInsets.all(8),
              child: GridView.count(
                crossAxisCount: 6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  for (final t in tiles)
                    _GridTile(
                      ticket: t,
                      fresh: t.id == _last?.id,
                      onTap: t.drawnAt == null && can
                          ? () => _pick(t.id)
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_last != null)
            KeyedSubtree(
              key: _revealKey,
              child: PrizeReveal(
                key: ValueKey(_shot),
                ticket: _last!,
                view: view,
              ),
            ),
        ],
      );
    },
    bottom: (view) => DrawButtons(
      view: view,
      label: '隨機掀一格',
      busy: _busy,
      onDraw: (times) => _pick(null, times: times),
    ),
  );
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.ticket, required this.fresh, this.onTap});

  final CasinoTicketRow ticket;
  final bool fresh;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final open = ticket.drawnAt != null;
    final tier = ticketTier(ticket);
    return Semantics(
      button: !open,
      label: open ? tierName(tier) : '還沒掀開的格子',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: open && !fresh ? 0.4 : 1,
          child: PixelFrame(
            style: open ? PixelFrameStyle.panel : PixelFrameStyle.parchment,
            padding: EdgeInsets.zero,
            child: Center(
              child: open
                  ? PixelSpriteView(gameTierIcon(tier))
                  : Text(
                      '?',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: PixelPalette.leather),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Scratch card ─────────────────────────────────────────────────────────

class ScratchScreen extends ConsumerStatefulWidget {
  const ScratchScreen({super.key});

  @override
  ConsumerState<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends ConsumerState<ScratchScreen> {
  static const _cols = 32, _rows = 14;

  /// The share scratched off at which the rest comes off by itself.
  static const _autoOpen = 0.55;

  CasinoTicketRow? _card;
  List<bool> _scratched = List.filled(_cols * _rows, false);
  bool _open = false;
  bool _busy = false;
  int _shot = 0;
  FrozenHeader? _frozen;

  /// Runs while the bottom button has just changed what it does (scratch
  /// off ↔ buy another), so a quick second tap doesn't do the other thing.
  Timer? _cool;
  bool get _cooling => _cool?.isActive ?? false;

  void _coolDown() {
    _cool?.cancel();
    _cool = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cool?.cancel();
    super.dispose();
  }

  Future<void> _buy(int _) async {
    setState(() {
      _busy = true;
      _frozen = _headerNow(ref);
    });
    final DrawOutcome outcome;
    try {
      outcome = await ref
          .read(casinoServiceProvider)
          .draw(game: CasinoGame.scratch);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _frozen = null;
        });
      }
      rethrow;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (outcome.drawn.isEmpty) _frozen = null;
      if (outcome.drawn.isNotEmpty) {
        _card = outcome.drawn.single;
        _scratched = List.filled(_cols * _rows, false);
        _open = false;
        _coolDown();
      }
    });
    if (outcome.drawn.isEmpty) {
      showStop(
        context,
        outcome,
        ref.read(casinoViewProvider).value?.price ?? 0,
      );
    }
  }

  void _scratch(Offset at, Size size) {
    if (_card == null || _open) return;
    final cw = size.width / _cols, ch = size.height / _rows;
    final c0 = at.dx / cw, r0 = at.dy / ch;
    var changed = false;
    for (var r = 0; r < _rows; r++) {
      for (var c = 0; c < _cols; c++) {
        final dx = c + 0.5 - c0, dy = (r + 0.5 - r0) * ch / cw;
        if (dx * dx + dy * dy <= 6.5 && !_scratched[r * _cols + c]) {
          _scratched[r * _cols + c] = true;
          changed = true;
        }
      }
    }
    if (!changed) return;
    final share = _scratched.where((s) => s).length / _scratched.length;
    setState(() {
      if (share >= _autoOpen) _reveal();
    });
  }

  void _reveal() {
    _open = true;
    _frozen = null;
    _shot++;
    _coolDown();
  }

  /// Wins every touch on the card before the page's scroll can.
  static final _claimTouch = <Type, GestureRecognizerFactory>{
    EagerGestureRecognizer:
        GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
          EagerGestureRecognizer.new,
          (_) {},
        ),
  };

  @override
  Widget build(BuildContext context) => _GamePage(
    game: CasinoGame.scratch,
    frozen: _frozen,
    builder: (view) {
      final text = Theme.of(context).textTheme;
      final card = _card;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WinFx(
            shot: _shot,
            size: _open ? fxSizeOf(card) : FxSize.none,
            child: PixelFrame(
              style: PixelFrameStyle.ornate,
              child: SizedBox(
                height: 200,
                child: card == null
                    ? Center(child: Text('買一張刮刮樂試試手氣', style: text.bodyLarge))
                    : LayoutBuilder(
                        builder: (context, box) {
                          final size = box.biggest;
                          // While there is foil left, a finger on the card
                          // is scratching: claim it at once so the page
                          // under it doesn't scroll (or bounce on iOS).
                          return RawGestureDetector(
                            behavior: HitTestBehavior.opaque,
                            gestures: _open ? const {} : _claimTouch,
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (e) =>
                                  _scratch(e.localPosition, size),
                              onPointerMove: (e) =>
                                  _scratch(e.localPosition, size),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Center(
                                      child: _open
                                          ? PrizeReveal(
                                              key: ValueKey(_shot),
                                              ticket: card,
                                              view: view,
                                            )
                                          : PixelSpriteView(
                                              tierSymbol(ticketTier(card)),
                                            ),
                                    ),
                                  ),
                                  if (!_open)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _FoilPainter(
                                          scratched: _scratched,
                                          cols: _cols,
                                          rows: _rows,
                                          px: context.artPixel,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (card != null && !_open)
            Text('用手指刮開銀漆，刮掉一半多就會整張打開', style: text.bodySmall),
        ],
      );
    },
    bottom: (view) => card(view),
  );

  Widget card(CasinoView view) {
    if (_card != null && !_open) {
      return PixelButton(
        tone: PixelButtonTone.quiet,
        expand: true,
        onPressed: _cooling ? null : () => setState(_reveal),
        child: const Text('一口氣刮開'),
      );
    }
    return DrawButtons(
      view: view,
      label: _card == null ? '買一張' : '再買一張',
      many: 0,
      busy: _busy || _cooling,
      onDraw: _buy,
    );
  }
}

/// The silver coat of a scratch card, in blocks, minus what is scratched.
class _FoilPainter extends CustomPainter {
  _FoilPainter({
    required this.scratched,
    required this.cols,
    required this.rows,
    required this.px,
  });

  final List<bool> scratched;
  final int cols;
  final int rows;
  final double px;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / cols, ch = size.height / rows;
    final paint = Paint();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (scratched[r * cols + c]) continue;
        // A diagonal sheen, stepped like old foil.
        final band = (c + r) % 11;
        paint.color = band == 0
            ? PixelPalette.white
            : band < 3
            ? PixelPalette.steelLight
            : PixelPalette.steel;
        final x = (c * cw / px).floorToDouble() * px;
        final y = (r * ch / px).floorToDouble() * px;
        final x1 = ((c + 1) * cw / px).ceilToDouble() * px;
        final y1 = ((r + 1) * ch / px).ceilToDouble() * px;
        canvas.drawRect(Rect.fromLTRB(x, y, x1, y1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FoilPainter old) => true;
}

// ── Chests ───────────────────────────────────────────────────────────────

class ChestScreen extends ConsumerStatefulWidget {
  const ChestScreen({super.key});

  @override
  ConsumerState<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends ConsumerState<ChestScreen> {
  List<CasinoTicketRow> _chests = const [];

  /// Whether a deal came back yet, and the week it found no chests in.
  bool _dealt = false;
  LogicalDay? _emptyWeek;
  int? _picked;
  bool _busy = false;
  int _shot = 0;

  @override
  void initState() {
    super.initState();
    _deal();
    // A new week has a new deck: chests from the old one can't be opened.
    ref.listenManual(
      casinoViewProvider.select((v) => v.value?.week?.weekStart),
      (_, week) {
        if (week == null || !_dealt) return;
        final stale = _chests.isEmpty
            ? week != _emptyWeek
            : _chests.any((c) => c.weekStart != week);
        if (stale) _deal();
      },
    );
  }

  Future<void> _deal() async {
    final chests = await ref.read(casinoServiceProvider).chests();
    if (!mounted) return;
    setState(() {
      _chests = chests;
      _dealt = true;
      _emptyWeek = chests.isEmpty
          ? ref.read(casinoViewProvider).value?.week?.weekStart
          : null;
      _picked = null;
    });
  }

  /// Whether the chest at [index] is still in this week's deck: another
  /// game may have drawn it, or the week turned over since it was dealt.
  bool _inDeck(int index) {
    final left = ref.read(casinoViewProvider).value?.left ?? const [];
    return left.any((t) => t.id == _chests[index].id);
  }

  Future<void> _open(int index) async {
    if (!_inDeck(index)) {
      await _deal();
      return;
    }
    setState(() => _busy = true);
    final DrawOutcome outcome;
    try {
      outcome = await ref
          .read(casinoServiceProvider)
          .draw(game: CasinoGame.chest, ticketId: _chests[index].id);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      rethrow;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (outcome.drawn.isNotEmpty) {
        _chests = [..._chests]..[index] = outcome.drawn.single;
        _picked = index;
        _shot++;
      }
    });
    if (outcome.drawn.isEmpty) {
      showStop(
        context,
        outcome,
        ref.read(casinoViewProvider).value?.price ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) => _GamePage(
    game: CasinoGame.chest,
    builder: (view) {
      final text = Theme.of(context).textTheme;
      final gold = ref.watch(goldProvider).value ?? 0;
      final can = !_busy && _picked == null && gold >= view.price;
      final picked = _picked;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            picked != null
                ? '其他寶箱裡裝的是……'
                : gold >= view.price
                ? '挑一個寶箱打開（${view.price} 金幣）'
                : '金幣不夠：一抽要 ${view.price} 金幣',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          WinFx(
            shot: _shot,
            size: picked == null ? FxSize.none : fxSizeOf(_chests[picked]),
            child: PixelFrame(
              style: PixelFrameStyle.ornate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < _chests.length; i++)
                    ChestTile(
                      ticket: _chests[i],
                      open: picked != null,
                      chosen: picked == i,
                      onTap: can ? () => _open(i) : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (picked != null)
            PrizeReveal(
              key: ValueKey(_shot),
              ticket: _chests[picked],
              view: view,
            ),
        ],
      );
    },
    bottom: (view) => PixelButton(
      expand: true,
      onPressed: _picked != null && !_busy && view.left.isNotEmpty
          ? _deal
          : null,
      child: const Text('再挑一次'),
    ),
  );
}

class ChestTile extends StatelessWidget {
  const ChestTile({
    super.key,
    required this.ticket,
    required this.open,
    required this.chosen,
    this.onTap,
  });

  final CasinoTicketRow ticket;

  /// The round is over: every chest shows what it held.
  final bool open;
  final bool chosen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tier = ticketTier(ticket);
    return Semantics(
      button: !open,
      label: open ? tierName(tier) : '寶箱',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: open && !chosen ? 0.5 : 1,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // An opened chest shows what it held.
                PixelSpriteView(open ? tierSymbol(tier) : PixelArt.chest),
                const SizedBox(height: 4),
                Text(
                  open ? tierName(tier) : '？',
                  style: text.bodyMedium?.copyWith(
                    color: open ? tierColor(tier) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
