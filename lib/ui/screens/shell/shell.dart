import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/board.dart';
import '../../../app/progression.dart';
import '../../../app/providers.dart';
import '../../../game/progression.dart';

import '../../pixel/pixel.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import '../board/board_screen.dart';
import '../hero/hero_screen.dart';
import '../story/chapter_banner.dart';
import '../story/chronicle_screen.dart';
import '../town/town_screen.dart';

/// The four main tabs.
class Shell extends ConsumerStatefulWidget {
  const Shell({super.key, this.tabs});

  /// Overrides tab pages (tests).
  final List<Widget>? tabs;

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int _index = 0;

  static const _tabTips = [
    MentorTip.board,
    MentorTip.chronicle,
    MentorTip.town,
    MentorTip.hero,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tip(_tabTips[0]));
  }

  void _tip(MentorTip tip) {
    if (mounted) showMentorTip(context, ref, tip);
  }

  void _select(int i) {
    setState(() => _index = i);
    _tip(_tabTips[i]);
  }

  @override
  Widget build(BuildContext context) {
    // Moments 莉娜 explains the first time they come up.
    ref.listen(progressionProvider, (_, next) {
      final p = next.value;
      if (p == null) return;
      if (p.classAppraisalOpen) _tip(MentorTip.classOpen);
      if (p.guild.state == TrialState.available) _tip(MentorTip.trial);
    });
    ref.listen(blessingProvider, (_, next) {
      if (next != null) _tip(MentorTip.blessing);
    });
    ref.listen(sideQuestProvider, (_, next) {
      if (next != null) _tip(MentorTip.sideQuest);
    });
    ref.listen(boardProvider, (_, next) {
      if (next.value?.entries.any((e) => e.offer != null) ?? false) {
        _tip(MentorTip.offer);
      }
    });
    final tabs =
        widget.tabs ??
        const [
          BoardScreen(header: ChapterBanner()),
          ChronicleScreen(),
          TownScreen(),
          HeroScreen(),
        ];
    return Scaffold(
      body: PixelBackdrop(
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: IndexedStack(index: _index, children: tabs),
            ),
          ),
        ),
      ),
      bottomNavigationBar: PixelTabBar(
        index: _index,
        onSelect: _select,
        items: const [
          (PixelIcons.sword, '任務板'),
          (PixelIcons.book, '冒險日誌'),
          (kTownIcon, '城鎮'),
          (PixelIcons.shield, '角色'),
        ],
      ),
    );
  }
}
