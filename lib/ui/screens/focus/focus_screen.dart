import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/focus_service.dart';
import '../../../app/providers.dart';
import '../../../core/logical_day.dart';
import '../../../data/focus_repository.dart';
import '../../../data/settings_repository.dart';
import '../../../domain/focus_settings.dart';
import '../../../game/focus.dart';
import '../../pixel/pixel.dart';
import '../../widgets/mentor_tips.dart';
import '../../widgets/pixel_controls.dart';
import '../../widgets/pixel_page.dart';
import 'focus_format.dart';

/// The training ground: a focus timer that starts each day below zero.
class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const FocusScreen()));

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  // A break counts down and the time of day moves on while the timer's own
  // state stays the same.
  Timer? _repaint;

  @override
  void initState() {
    super.initState();
    _repaint = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final resting = ref.read(focusProvider).phase == FocusPhase.resting;
      final clock = ref.read(focusSettingsProvider).value?.showClock ?? false;
      if (resting || clock) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showMentorTip(context, ref, MentorTip.focus),
    );
  }

  @override
  void dispose() {
    _repaint?.cancel();
    super.dispose();
  }

  FocusController get _timer => ref.read(focusProvider.notifier);

  Future<void> _start() async {
    final ok = await _timer.start();
    if (!ok && mounted) {
      showPixelToast(context, '修練場還沒準備好，等一下再試試。', icon: PixelIcons.skull);
    }
  }

  Future<void> _save(FocusSettings next) =>
      ref.read(settingsRepoProvider).write(SettingKeys.focus, next.toJson());

  /// Leaving while a session runs ends it, after asking.
  Future<void> _leave() async {
    final stop = await showPixelDialog<bool>(
      context,
      builder: (ctx) => const _LeaveDialog(),
    );
    if (stop != true || !mounted) return;
    await _timer.stop();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(focusProvider);
    final view = ref.watch(focusWeekProvider);
    final ledger = ref.watch(focusLedgerProvider);
    final settings =
        ref.watch(focusSettingsProvider).value ?? const FocusSettings();
    final rules = ref.watch(gameRulesProvider).focus;
    final today = ref.watch(todayProvider);
    final now = ref.watch(clockProvider).now();
    final day = ledger?.days.lastOrNull;
    final restDay = view?.restDays.contains(today) ?? false;
    final running = focus.phase == FocusPhase.running;
    final value = day?.endSeconds ?? 0;

    return PopScope(
      canPop: !running,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Stack(
        children: [
          PixelPage(
            title: '修練場',
            children: [
              _TimerPanel(
                focus: focus,
                day: day,
                ledger: ledger,
                terms: view?.week.terms,
                restDay: restDay,
                settings: settings,
                now: now,
                graceSeconds: rules.awayGraceSeconds,
              ),
              const SizedBox(height: 12),
              _Controls(
                focus: focus,
                onStart: _start,
                onStop: _timer.stop,
                onSkipBreak: _timer.skipBreak,
                onPowerSave: () => _timer.setPowerSave(true),
              ),
              if (view != null && ledger != null) ...[
                const PixelHeading('本週', icon: PixelIcons.star),
                _WeekPanel(view: view, ledger: ledger, today: today),
              ],
              const PixelHeading('修練場設定', icon: PixelIcons.scroll),
              _SettingsPanel(
                settings: settings,
                rules: rules,
                terms: view?.week.terms,
                onChanged: _save,
              ),
            ],
          ),
          if (focus.powerSave)
            Positioned.fill(
              child: _PowerSaveView(
                timer: settings.hideTimer ? null : value,
                time: settings.showClock ? now : null,
                now: now,
                onExit: () => _timer.setPowerSave(false),
              ),
            ),
        ],
      ),
    );
  }
}

/// Digits of one width, so a running timer does not shift as it counts.
const _tabular = [FontFeature.tabularFigures()];

String _timeOfDay(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// The day's timer in large digits, red below zero and gold above.
class _TimerPanel extends StatelessWidget {
  const _TimerPanel({
    required this.focus,
    required this.day,
    required this.ledger,
    required this.terms,
    required this.restDay,
    required this.settings,
    required this.now,
    required this.graceSeconds,
  });

  final FocusState focus;
  final FocusDay? day;
  final FocusLedger? ledger;
  final FocusTerms? terms;
  final bool restDay;
  final FocusSettings settings;
  final DateTime now;

  /// How long the player may leave the app before a session ends.
  final int graceSeconds;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final day = this.day;
    final value = day?.endSeconds ?? 0;
    final running = focus.phase == FocusPhase.running;
    final hidden = running && settings.hideTimer;
    final big = text.displaySmall!.copyWith(
      fontSize: crispFontSize(dpr, 64),
      height: 1.25,
      fontFeatures: _tabular,
      color: value < 0 ? PixelPalette.red : PixelPalette.gold,
    );
    final earnedAll =
        terms != null &&
        ledger != null &&
        ledger!.earnedSeconds >= terms!.earnCapMinutes * 60;

    final label = switch (focus.phase) {
      FocusPhase.idle => '今天的碼表',
      FocusPhase.running when hidden => '專注中',
      FocusPhase.running => '專注中・這一輪 ${formatFocusClock(focus.sessionSeconds)}',
      FocusPhase.resting => '休息中',
    };
    final notes = <String>[
      if (day == null)
        '冒險者登記後，修練場就會開張。'
      else ...[
        if (restDay) '今天是休息日，不加新的負債。',
        if (!restDay && day.startSeconds == 0 && day.focusedSeconds == 0)
          '今天的負債已經用預繳抵掉了。',
        if (value < 0)
          '還欠 ${owedMinutes(value)} 分鐘，過了 0 才開始賺金幣。'
        else if (earnedAll)
          '本週能賺的金幣已經賺滿，再專注會預繳之後幾天的負債。'
        else
          '今天賺了 ${day.gold} 金幣',
      ],
      if (focus.phase == FocusPhase.idle && focus.endedAway)
        '上一輪因為離開 app 超過 $graceSeconds 秒，在離開那一刻結束了。',
    ];

    return PixelFrame(
      style: PixelFrameStyle.ornate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(fontFeatures: _tabular),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              hidden ? '・・・' : formatFocusClock(value),
              key: const Key('focus-clock'),
              style: big,
            ),
          ),
          for (final note in notes)
            Text(note, textAlign: TextAlign.center, style: text.bodySmall),
          if (focus.phase == FocusPhase.resting &&
              focus.breakEndsAt != null) ...[
            const SizedBox(height: 6),
            Text(
              '休息還剩 ${formatFocusClock(_left(focus.breakEndsAt!))}',
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(
                color: PixelPalette.tealLight,
                fontFeatures: _tabular,
              ),
            ),
            Text(
              '可以離開 app，時間到會通知你。',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
          if (settings.showClock)
            Text(
              '現在 ${_timeOfDay(now)}',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
        ],
      ),
    );
  }

  int _left(DateTime ends) {
    final s = ends.difference(now).inSeconds;
    return s < 0 ? 0 : s;
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.focus,
    required this.onStart,
    required this.onStop,
    required this.onSkipBreak,
    required this.onPowerSave,
  });

  final FocusState focus;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSkipBreak;
  final VoidCallback onPowerSave;

  @override
  Widget build(BuildContext context) {
    final ready = focus.ready;
    return switch (focus.phase) {
      FocusPhase.idle => PixelButton(
        expand: true,
        onPressed: ready ? onStart : null,
        child: const Text('開始專注'),
      ),
      FocusPhase.running => Row(
        children: [
          Expanded(
            child: PixelButton(
              tone: PixelButtonTone.danger,
              expand: true,
              onPressed: onStop,
              child: const Text('停止'),
            ),
          ),
          const SizedBox(width: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            onPressed: onPowerSave,
            child: const Text('省電模式'),
          ),
        ],
      ),
      FocusPhase.resting => Row(
        children: [
          Expanded(
            child: PixelButton(
              expand: true,
              onPressed: onStart,
              child: const Text('開始下一輪'),
            ),
          ),
          const SizedBox(width: 8),
          PixelButton(
            tone: PixelButtonTone.quiet,
            onPressed: onSkipBreak,
            child: const Text('跳過休息'),
          ),
        ],
      ),
    };
  }
}

/// This week: focus against the goal, gold against what can be earned, and
/// how each day closed.
class _WeekPanel extends StatelessWidget {
  const _WeekPanel({
    required this.view,
    required this.ledger,
    required this.today,
  });

  final FocusWeekView view;
  final FocusLedger ledger;
  final LogicalDay today;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final terms = view.week.terms;
    final cap = terms.capMinutes * 60;
    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '專注 ${formatFocusSpan(ledger.focusedSeconds)}',
                  style: text.bodyMedium,
                ),
              ),
              Text('目標 ${formatFocusSpan(cap)}', style: text.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          PixelBar(
            value: cap == 0 ? 0 : ledger.focusedSeconds / cap,
            segments: terms.capMinutes ~/ 60,
          ),
          const SizedBox(height: 6),
          Text(
            '已賺 ${ledger.gold}／${terms.maxGold} 金幣・時薪 ${terms.goldPerHour}',
            style: text.bodySmall,
          ),
          if (ledger.prepaidSeconds > 0)
            Text(
              '預繳 ${formatFocusSpan(ledger.prepaidSeconds)}，會抵掉之後幾天的負債',
              style: text.bodySmall,
            ),
          const SizedBox(height: 8),
          _DayStrip(view: view, ledger: ledger, today: today),
        ],
      ),
    );
  }
}

/// Seven small squares: how each day of the week closed.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.view,
    required this.ledger,
    required this.today,
  });

  final FocusWeekView view;
  final FocusLedger ledger;
  final LogicalDay today;

  static const _names = ['一', '二', '三', '四', '五', '六', '日'];

  Color _color(LogicalDay day) {
    if (day.isAfter(today) || day.isBefore(view.week.fromDay)) {
      return PixelPalette.panelEdge;
    }
    if (view.restDays.contains(day)) return PixelPalette.teal;
    final closed = ledger.days.where((d) => d.day == day).firstOrNull;
    if (closed == null) return PixelPalette.panelEdge;
    if (closed.endSeconds >= 0) return PixelPalette.green;
    return day == today ? PixelPalette.goldShade : PixelPalette.red;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final px = context.artPixel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final day = view.week.weekStart.addDays(i);
                    return Column(
                      children: [
                        Text(
                          _names[day.weekday - 1],
                          style: text.bodySmall?.copyWith(
                            color: day == today ? PixelPalette.goldLight : null,
                          ),
                        ),
                        Container(
                          width: 8 * px,
                          height: 8 * px,
                          decoration: BoxDecoration(
                            color: _color(day),
                            border: Border.all(
                              color: PixelPalette.outline,
                              width: px,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text('綠：還清　紅：沒還完　藍綠：休息日', style: text.bodySmall),
      ],
    );
  }
}

/// Switches and lengths of the training ground. The daily debt and the goal
/// only change next week's terms.
class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.settings,
    required this.rules,
    required this.terms,
    required this.onChanged,
  });

  final FocusSettings settings;
  final FocusRules rules;
  final FocusTerms? terms;
  final ValueChanged<FocusSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final daily = settings.dailyMinutes ?? rules.dailyMinutes;
    final goal = settings.goalMinutes ?? rules.weeklyGoalMinutes;
    final terms = this.terms;

    Widget option(String label, Widget control, {String? note}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodyMedium),
          const SizedBox(height: 4),
          control,
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(note, style: text.bodySmall),
          ],
        ],
      ),
    );
    Widget onOff(bool value, ValueChanged<bool> changed) => PixelSegments<bool>(
      values: const [true, false],
      selected: value,
      label: (v) => v ? '開' : '關',
      onChanged: changed,
    );

    return PixelFrame(
      style: PixelFrameStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          option(
            '音效',
            onOff(
              settings.sound,
              (v) => onChanged(settings.copyWith(sound: v)),
            ),
          ),
          option(
            '顯示現在時間',
            onOff(
              settings.showClock,
              (v) => onChanged(settings.copyWith(showClock: v)),
            ),
          ),
          option(
            '專注時隱藏數字',
            onOff(
              settings.hideTimer,
              (v) => onChanged(settings.copyWith(hideTimer: v)),
            ),
          ),
          option(
            '休息時間',
            PixelSegments<int>(
              values: const [5, 10, 15, 20],
              selected: settings.breakMinutes ?? rules.breakMinutes,
              label: (v) => '$v 分',
              onChanged: (v) => onChanged(settings.copyWith(breakMinutes: v)),
            ),
          ),
          option(
            '每天的負債',
            PixelSegments<int>(
              values: const [30, 40, 50, 60],
              selected: daily,
              label: (v) => '$v 分',
              onChanged: (v) => onChanged(settings.copyWith(dailyMinutes: v)),
            ),
            note: terms != null && terms.dailyMinutes != daily
                ? '下週一起生效（本週是 ${terms.dailyMinutes} 分鐘）'
                : '改了從下週一起生效',
          ),
          option(
            '每週目標',
            PixelSegments<int>(
              values: const [480, 600, 720, 900],
              selected: goal,
              label: (v) => '${v ~/ 60} 小時',
              onChanged: (v) => onChanged(settings.copyWith(goalMinutes: v)),
            ),
            note: terms != null && terms.capMinutes != goal
                ? '下週一起生效（本週是 ${formatFocusSpan(terms.capMinutes * 60)}）'
                : '改了從下週一起生效',
          ),
        ],
      ),
    );
  }
}

/// Black screen with dim numbers that move once a minute; a tap leaves it.
/// The status bar is hidden while it shows.
class _PowerSaveView extends StatefulWidget {
  const _PowerSaveView({
    required this.timer,
    required this.time,
    required this.now,
    required this.onExit,
  });

  /// The timer to show, or null when the numbers are hidden.
  final int? timer;

  /// The time of day to show, or null.
  final DateTime? time;
  final DateTime now;
  final VoidCallback onExit;

  @override
  State<_PowerSaveView> createState() => _PowerSaveViewState();
}

class _PowerSaveViewState extends State<_PowerSaveView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // Somewhere else every minute, so nothing stays lit in one place.
    final minute = widget.now.millisecondsSinceEpoch ~/ 60000;
    final x = (minute * 7 % 11) / 5 - 1;
    final y = (minute * 5 % 13) / 6 - 1;
    final timer = widget.timer;
    final time = widget.time;
    const dim = PixelPalette.panelLight;
    return Semantics(
      button: true,
      label: '離開省電模式',
      child: GestureDetector(
        key: const Key('power-save'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onExit,
        child: ColoredBox(
          color: const Color(0xFF000000),
          child: SafeArea(
            child: Align(
              alignment: Alignment(x * 0.8, y * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timer != null)
                    Text(
                      formatFocusClock(timer),
                      style: text.displaySmall?.copyWith(
                        fontSize: crispFontSize(dpr, 48),
                        fontFeatures: _tabular,
                        color: timer < 0
                            ? PixelPalette.redShade
                            : PixelPalette.goldDark,
                      ),
                    ),
                  if (time != null)
                    Text(
                      _timeOfDay(time),
                      style: text.bodyMedium?.copyWith(color: dim),
                    ),
                  Text(
                    '點一下回到修練場',
                    style: text.bodySmall?.copyWith(
                      color: PixelPalette.panelEdge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaveDialog extends StatelessWidget {
  const _LeaveDialog();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('要結束這一輪專注嗎？', style: text.titleLarge),
        const SizedBox(height: 8),
        Text('離開修練場會停止計時，接著開始休息。', style: text.bodyMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.quiet,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('繼續專注'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelButton(
                tone: PixelButtonTone.danger,
                expand: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('結束並離開'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
