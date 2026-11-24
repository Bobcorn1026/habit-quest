import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../pixel/pixel.dart';
import 'mentor_portrait.dart';

/// The guild receptionist who guides new players.
const kMentorName = '莉娜';

/// 莉娜 talking in an RPG text box. Each line appears letter by letter; a tap
/// shows the rest of the line, the next tap moves on.
class MentorBox extends StatefulWidget {
  const MentorBox({
    super.key,
    required this.lines,
    this.onDone,
    this.onTapDone,
  });

  final List<String> lines;

  /// The last line has been fully shown.
  final VoidCallback? onDone;

  /// Tapped after everything was shown (e.g. to close a tip).
  final VoidCallback? onTapDone;

  @override
  State<MentorBox> createState() => _MentorBoxState();
}

class _MentorBoxState extends State<MentorBox>
    with SingleTickerProviderStateMixin {
  static const _perChar = Duration(milliseconds: 35);

  late final Ticker _ticker = createTicker(_tick);
  var _line = 0;
  var _shown = 0;
  var _notified = false;

  // Characters of the current line, recomputed only when the line changes.
  List<String> _charsCache = const [];
  List<String>? _charsLines;
  int _charsLine = -1;

  List<String> get _chars {
    if (widget.lines.isEmpty) return const [];
    if (!identical(_charsLines, widget.lines) || _charsLine != _line) {
      _charsLines = widget.lines;
      _charsLine = _line;
      _charsCache = widget.lines[_line].characters.toList();
    }
    return _charsCache;
  }

  bool get _lineShown => _shown >= _chars.length;
  bool get _last => _line >= widget.lines.length - 1;
  bool get _finished => _last && _lineShown;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void didUpdateWidget(MentorBox old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.lines, widget.lines)) {
      _line = 0;
      _notified = false;
      _restart();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _restart() {
    _shown = 0;
    _ticker
      ..stop()
      ..start();
  }

  void _tick(Duration elapsed) {
    final n = (elapsed.inMilliseconds ~/ _perChar.inMilliseconds).clamp(
      0,
      _chars.length,
    );
    if (n != _shown) setState(() => _shown = n);
    if (_lineShown) {
      _ticker.stop();
      _notifyIfDone();
    }
  }

  void _notifyIfDone() {
    if (_finished && !_notified) {
      _notified = true;
      widget.onDone?.call();
    }
  }

  void _tap() {
    if (!_lineShown) {
      _ticker.stop();
      setState(() => _shown = _chars.length);
      _notifyIfDone();
    } else if (!_last) {
      setState(() => _line++);
      _restart();
    } else {
      widget.onTapDone?.call();
    }
  }

  void _skip() {
    _ticker.stop();
    setState(() {
      _line = widget.lines.length - 1;
      _shown = _chars.length;
    });
    _notifyIfDone();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chars = _chars;
    final shown = chars.take(_shown).join();
    final rest = chars.skip(_shown).join();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: PixelFrame(
        style: PixelFrameStyle.ornate,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MentorPortrait(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        kMentorName,
                        style: text.bodyMedium?.copyWith(
                          color: PixelPalette.goldLight,
                        ),
                      ),
                      const Spacer(),
                      if (!_finished)
                        GestureDetector(
                          onTap: _skip,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text('跳過 »', style: text.bodySmall),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // The unshown rest keeps its space, so lines never reflow.
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: shown),
                        TextSpan(
                          text: rest,
                          style: const TextStyle(color: Color(0x00000000)),
                        ),
                      ],
                    ),
                    style: text.bodyMedium?.copyWith(height: 1.5),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _lineShown && !_last ? '▼' : ' ',
                      style: text.bodySmall?.copyWith(
                        color: PixelPalette.goldLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 莉娜 says [lines] over the current screen; closes on the last tap.
Future<void> showMentor(BuildContext context, List<String> lines) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      pageBuilder: (ctx, _, _) => SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Material(
                type: MaterialType.transparency,
                child: MentorBox(
                  lines: lines,
                  onTapDone: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
