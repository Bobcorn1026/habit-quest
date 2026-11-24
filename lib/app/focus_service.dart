import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/logical_day.dart';
import '../data/database.dart';
import '../data/economy_repository.dart';
import '../data/focus_repository.dart';
import '../data/settings_repository.dart';
import '../domain/focus_settings.dart';
import '../game/focus.dart';
import '../game/game_rules.dart';
import '../game/period.dart';
import 'providers.dart';
import 'reminders.dart';
import 'screen_control.dart';
import 'sfx.dart';
import 'town_service.dart';

/// Notification id of the end of a break; above the daily plan's ids.
const kBreakNotificationId = 200;

/// Why a session ended (`focus_sessions.end_reason`).
abstract final class FocusEnd {
  static const stopped = 'stopped';

  /// The player was away from the app for longer than the grace period, or
  /// the clock jumped.
  static const away = 'away';

  /// The app died while the session ran.
  static const lost = 'lost';

  /// The day turned over; the session went on as one of the new day.
  static const dayEnd = 'day';
}

enum FocusPhase { idle, running, resting }

@immutable
class FocusState {
  const FocusState({
    this.ready = false,
    this.phase = FocusPhase.idle,
    this.sessionId,
    this.day,
    this.sessionSeconds = 0,
    this.breakEndsAt,
    this.powerSave = false,
    this.endedAway = false,
  });

  /// False until what an earlier launch left behind is dealt with.
  final bool ready;
  final FocusPhase phase;

  /// The running session and the day it counts for.
  final int? sessionId;
  final LogicalDay? day;

  /// Focused seconds of the running session, live.
  final int sessionSeconds;
  final DateTime? breakEndsAt;

  /// The power-saving view has dimmed the screen.
  final bool powerSave;

  /// The last session ended because the player was away too long.
  final bool endedAway;

  FocusState copyWith({
    int? sessionId,
    LogicalDay? day,
    int? sessionSeconds,
    bool? powerSave,
  }) => FocusState(
    ready: ready,
    phase: phase,
    sessionId: sessionId ?? this.sessionId,
    day: day ?? this.day,
    sessionSeconds: sessionSeconds ?? this.sessionSeconds,
    breakEndsAt: breakEndsAt,
    powerSave: powerSave ?? this.powerSave,
    endedAway: endedAway,
  );
}

/// This week at the training ground as saved.
@immutable
class FocusWeekView {
  const FocusWeekView({
    required this.week,
    required this.sessions,
    required this.restDays,
  });

  final FocusWeekRow week;
  final List<FocusSessionRow> sessions;
  final Set<LogicalDay> restDays;

  /// The ledger through [today], with session [liveId] counted at
  /// [liveSeconds] on [liveDay] instead of what was last saved of it.
  FocusLedger ledger(
    LogicalDay today, {
    int? liveId,
    int liveSeconds = 0,
    LogicalDay? liveDay,
  }) {
    final byDay = sumByDay(sessions.where((s) => s.id != liveId));
    if (liveId != null && liveDay != null) {
      byDay.update(
        liveDay,
        (seconds) => seconds + liveSeconds,
        ifAbsent: () => liveSeconds,
      );
    }
    return computeFocusLedger(
      week: week.weekStart,
      fromDay: week.fromDay,
      today: today,
      terms: week.terms,
      secondsByDay: byDay,
      restDays: restDays,
    );
  }
}

LogicalDay _weekOf(GameRules rules, LogicalDay day) =>
    PeriodCalendar.weeks(weekStartsOn: rules.weekStartsOn).periodOf(day).start;

final _thisWeekProvider = Provider<LogicalDay>(
  (ref) => _weekOf(ref.watch(gameRulesProvider), ref.watch(todayProvider)),
);

final _focusWeekRowProvider = StreamProvider<FocusWeekRow?>(
  (ref) => ref.watch(focusRepoProvider).watchWeek(ref.watch(_thisWeekProvider)),
);

final _focusSessionsProvider = StreamProvider<List<FocusSessionRow>>((ref) {
  final week = ref.watch(_thisWeekProvider);
  return ref.watch(focusRepoProvider).watchSessions(week, week.addDays(6));
});

/// This week at the training ground; null until it is open.
final focusWeekProvider = Provider<FocusWeekView?>((ref) {
  final week = ref.watch(_focusWeekRowProvider).value;
  final sessions = ref.watch(_focusSessionsProvider).value;
  final rest = ref.watch(restDaysProvider).value;
  // A stream may still hold last week's row for a moment after Monday.
  if (week == null ||
      sessions == null ||
      rest == null ||
      week.weekStart != ref.watch(_thisWeekProvider)) {
    return null;
  }
  return FocusWeekView(week: week, sessions: sessions, restDays: rest);
});

/// This week's ledger through today, the running session counted live.
final focusLedgerProvider = Provider<FocusLedger?>((ref) {
  final view = ref.watch(focusWeekProvider);
  if (view == null) return null;
  final focus = ref.watch(focusProvider);
  return view.ledger(
    ref.watch(todayProvider),
    liveId: focus.sessionId,
    liveSeconds: focus.sessionSeconds,
    liveDay: focus.day,
  );
});

/// The training ground as the player set it up.
final focusSettingsProvider = StreamProvider<FocusSettings>(
  (ref) => ref
      .watch(settingsRepoProvider)
      .watch(SettingKeys.focus)
      .map(FocusSettings.fromJson),
);

/// How often a running session or a break is looked at; null turns the
/// timer off (tests call [FocusController.tick] themselves).
final focusTickProvider = Provider<Duration?>(
  (ref) => const Duration(seconds: 1),
);

final focusProvider = NotifierProvider<FocusController, FocusState>(
  FocusController.new,
);

/// The focus timer of the training ground. Time always comes from the
/// [Clock]; the timer only decides when to look at it.
class FocusController extends Notifier<FocusState> {
  late Clock _clock;
  late GameRules _rules;
  late FocusRepository _repo;
  late EconomyRepository _economy;
  late SettingsRepository _settings;
  late ScreenControl _screen;
  late Sfx _sfx;
  late ReminderScheduler _scheduler;

  Timer? _ticker;
  FocusWeekView? _view;
  Future<void> _work = Future.value();

  // The running session: [_anchorSeconds] counted up to [_anchor], and the
  // time since then on top.
  DateTime _anchor = DateTime(0);
  int _anchorSeconds = 0;
  DateTime _lastTick = DateTime(0);
  DateTime _lastSave = DateTime(0);
  DateTime? _hiddenAt;
  int _awaySeconds = 0;

  /// The day's focus gold as last written; null when not known.
  int? _paidGold;

  FocusRules get _focusRules => _rules.focus;

  @override
  FocusState build() {
    // Read, not watched: rebuilding would forget a running session.
    _clock = ref.read(clockProvider);
    _rules = ref.read(gameRulesProvider);
    _repo = ref.read(focusRepoProvider);
    _economy = ref.read(economyRepoProvider);
    _settings = ref.read(settingsRepoProvider);
    _screen = ref.read(screenControlProvider);
    _sfx = ref.read(sfxProvider);
    _scheduler = ref.read(reminderSchedulerProvider);
    ref.onDispose(_stopTicker);
    ref.listen(
      focusWeekProvider,
      (_, next) => _view = next,
      fireImmediately: true,
    );
    _serial(_restore);
    return const FocusState();
  }

  /// Runs [op] after everything queued before it, so that the timer, the
  /// lifecycle and the buttons never interleave their writes. Errors are
  /// reported, not thrown, since most callers do not wait.
  Future<T?> _serial<T>(Future<T> Function() op) {
    final next = _work
        .then((_) => ref.mounted ? op() : Future<T?>.value())
        .then<T?>(
          (value) => value,
          onError: (Object error, StackTrace stack) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error,
                stack: stack,
                library: 'focus timer',
              ),
            );
            return null;
          },
        );
    _work = next;
    return next;
  }

  void _set(FocusState next) {
    if (ref.mounted) state = next;
  }

  LogicalDay _dayOf(DateTime time) =>
      LogicalDay.of(time, dayStartHour: _rules.dayStartHour);

  DateTime _startOf(LogicalDay day) =>
      DateTime(day.year, day.month, day.day, _rules.dayStartHour);

  /// Seconds of the running session at [time]; never less than what was
  /// already counted.
  int _live(DateTime time) =>
      _anchorSeconds + math.max(0, time.difference(_anchor).inSeconds);

  Future<FocusSettings> _chosen() async =>
      FocusSettings.fromJson(await _settings.read(SettingKeys.focus));

  Future<void> _sound(SfxCue cue) async {
    if ((await _chosen()).sound) await _sfx.play(cue);
  }

  void _startTicker() {
    _ticker?.cancel();
    final every = ref.read(focusTickProvider);
    if (every != null) _ticker = Timer.periodic(every, (_) => tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _restore() async {
    final dimmed = await _settings.read(SettingKeys.focusRestoreBrightness);
    if (dimmed is num) {
      // The app died in the power-saving view.
      await _screen.restoreSystemBrightness(dimmed.toDouble());
      await _settings.write(SettingKeys.focusRestoreBrightness, null);
    }
    // Sessions the app died in end where they were last seen.
    final lost = await _repo.openSessions();
    for (final session in lost) {
      await _repo.endSession(
        session.id,
        at: session.hiddenAt ?? session.lastSeenAt,
        seconds: session.seconds,
        reason: FocusEnd.lost,
      );
      await _payDay(session.day);
    }
    // A week that ended under one of them was waiting for it.
    if (lost.isNotEmpty) await _turnWeeks();
    final breakEnds = DateTime.tryParse(
      '${await _settings.read(SettingKeys.focusBreak) ?? ''}',
    );
    if (breakEnds != null && breakEnds.isAfter(_clock.now())) {
      _set(
        FocusState(
          ready: true,
          phase: FocusPhase.resting,
          breakEndsAt: breakEnds,
        ),
      );
      _startTicker();
      return;
    }
    if (breakEnds != null) await _settings.write(SettingKeys.focusBreak, null);
    _set(const FocusState(ready: true));
  }

  /// Writes the gold [day] has earned, from what is saved.
  Future<void> _payDay(LogicalDay day) async {
    final weekStart = _weekOf(_rules, day);
    final week = await _repo.week(weekStart);
    // A settled week was paid when it closed.
    if (week == null || week.settledAt != null) return;
    final ledger = computeFocusLedger(
      week: weekStart,
      fromDay: week.fromDay,
      today: day,
      terms: week.terms,
      secondsByDay: await _repo.secondsByDay(weekStart, day),
      restDays: await _economy.bookedDays(),
    );
    if (ledger.days.isEmpty || ledger.days.last.day != day) return;
    await _economy.setEvent(
      amount: ledger.days.last.gold,
      source: kFocusGoldSource,
      ref: day.toKey(),
      at: _clock.now(),
    );
  }

  /// Writes today's gold if the whole coins changed, from the week as last
  /// seen and the running session as it is now.
  Future<void> _payLive(LogicalDay day, int seconds, DateTime now) async {
    final view = _view;
    if (view == null ||
        view.week.weekStart != _weekOf(_rules, day) ||
        view.week.settledAt != null) {
      return;
    }
    final ledger = view.ledger(
      day,
      liveId: state.sessionId,
      liveSeconds: seconds,
      liveDay: day,
    );
    if (ledger.days.isEmpty || ledger.days.last.day != day) return;
    final gold = ledger.days.last.gold;
    if (gold == _paidGold) return;
    await _economy.setEvent(
      amount: gold,
      source: kFocusGoldSource,
      ref: day.toKey(),
      at: now,
    );
    _paidGold = gold;
  }

  /// Starts a session. False when there is no training ground yet (no
  /// adventurer) or one is already running.
  Future<bool> start() async =>
      await _serial(() async {
        if (!state.ready || state.phase == FocusPhase.running) return false;
        await ref.read(townServiceProvider).rollover();
        final now = _clock.now();
        final day = _dayOf(now);
        if (await _repo.week(_weekOf(_rules, day)) == null) return false;
        if (state.phase == FocusPhase.resting) await _endBreak(over: false);
        final id = await _repo.startSession(day, now);
        _begin(now);
        _set(
          FocusState(
            ready: true,
            phase: FocusPhase.running,
            sessionId: id,
            day: day,
          ),
        );
        await _screen.keepAwake(true);
        await _sound(SfxCue.start);
        _startTicker();
        // The break that follows ends with a notification.
        unawaited(_scheduler.requestPermission());
        return true;
      }) ??
      false;

  void _begin(DateTime at) {
    _anchor = at;
    _anchorSeconds = 0;
    _lastTick = at;
    _lastSave = at;
    _hiddenAt = null;
    _awaySeconds = 0;
    _paidGold = null;
  }

  /// Looks at the clock: counts the running session, splits it at the
  /// day's start, saves it now and then, and ends a break that is over.
  Future<void> tick() => _serial(() async {
    final now = _clock.now();
    switch (state.phase) {
      case FocusPhase.running:
        await _runningTick(now);
      case FocusPhase.resting:
        final ends = state.breakEndsAt;
        if (ends == null || !now.isBefore(ends)) await _endBreak(over: true);
      case FocusPhase.idle:
        _stopTicker();
    }
  });

  Future<void> _runningTick(DateTime now) async {
    // In the background: what happens is decided on coming back.
    if (_hiddenAt != null) return;
    if (now.isBefore(_lastTick)) {
      // The clock was turned back: keep what was counted, count on from now,
      // and save at once (the last save is now in the future).
      _anchorSeconds = _live(_lastTick);
      _anchor = now;
      _lastSave = DateTime(0);
    } else if (now.difference(_lastTick).inSeconds >
        _focusRules.awayGraceSeconds) {
      // Nobody looked for longer than the grace period without the app
      // leaving the front: the clock jumped. The session ends where it
      // was last seen.
      final last = _lastTick;
      await _finish(at: last, seconds: _live(last), reason: FocusEnd.away);
      _set(const FocusState(ready: true, endedAway: true));
      return;
    }
    _lastTick = now;

    var id = state.sessionId!;
    var day = state.day!;
    // A clock turned back over the day start keeps counting for the
    // session's day; only a later day splits it.
    if (_dayOf(now).isAfter(day)) {
      // The day turned over: the old day's session ends at its last moment
      // and a new one goes on for the new day.
      final boundary = _startOf(day.addDays(1));
      final from = _anchor.isAfter(boundary) ? _anchor : boundary;
      await _repo.endSession(
        id,
        at: boundary,
        seconds: _live(boundary),
        reason: FocusEnd.dayEnd,
      );
      await _payDay(day);
      final ended = day;
      day = _dayOf(now);
      id = await _repo.startSession(day, from);
      _begin(from);
      _lastTick = now;
      if (ref.mounted) ref.read(todayProvider.notifier).refresh();
      // Monday: last week was waiting for this session's last seconds.
      if (_weekOf(_rules, ended) != _weekOf(_rules, day)) await _turnWeeks();
    }

    final seconds = _live(now);
    _set(state.copyWith(sessionId: id, day: day, sessionSeconds: seconds));
    if (now.difference(_lastSave).inSeconds >= _focusRules.saveEverySeconds) {
      await _repo.saveSession(
        id,
        seconds: seconds,
        at: now,
        awaySeconds: _awaySeconds,
      );
      _lastSave = now;
    }
    await _payLive(day, seconds, now);
  }

  /// Ends the running session; what comes next is up to the caller.
  Future<void> _finish({
    required DateTime at,
    required int seconds,
    required String reason,
  }) async {
    _stopTicker();
    final day = state.day!;
    await _repo.endSession(
      state.sessionId!,
      at: at,
      seconds: seconds,
      reason: reason,
    );
    await _payDay(day);
    await _screen.keepAwake(false);
    if (state.powerSave) await _undim();
    _hiddenAt = null;
    // Ended in a later week (back after a long time away): its week was
    // waiting for it.
    if (_weekOf(_rules, day) != _weekOf(_rules, _dayOf(_clock.now()))) {
      await _turnWeeks();
    }
  }

  /// Lets the town settle weeks that were waiting for a session to end.
  Future<void> _turnWeeks() async {
    if (ref.mounted) await ref.read(townServiceProvider).rollover();
  }

  /// Stops the running session and starts the break.
  Future<void> stop() => _serial(() async {
    if (state.phase != FocusPhase.running) return;
    final now = _clock.now();
    // Settle a day boundary or a clock jump since the last look first.
    await _runningTick(now);
    if (state.phase != FocusPhase.running) return;
    await _finish(at: now, seconds: _live(now), reason: FocusEnd.stopped);
    await _sound(SfxCue.stop);
    final minutes = (await _chosen()).breakMinutes ?? _focusRules.breakMinutes;
    final ends = now.add(Duration(minutes: minutes));
    await _settings.write(SettingKeys.focusBreak, ends.toIso8601String());
    await _scheduler.scheduleOnce(
      kBreakNotificationId,
      ends,
      title: '修練場',
      body: '休息結束了。準備好就回來，再修練一輪吧。',
    );
    _set(FocusState(ready: true, phase: FocusPhase.resting, breakEndsAt: ends));
    _startTicker();
  });

  /// Ends the break early.
  Future<void> skipBreak() => _serial(() => _endBreak(over: false));

  Future<void> _endBreak({required bool over}) async {
    if (state.phase != FocusPhase.resting) return;
    _stopTicker();
    await _settings.write(SettingKeys.focusBreak, null);
    if (over) {
      await _sound(SfxCue.breakOver);
    } else {
      await _scheduler.cancel(kBreakNotificationId);
    }
    _set(const FocusState(ready: true));
  }

  /// The app left the front. A running session waits to see whether the
  /// player is back within the grace period.
  Future<void> hidden() => _serial(() async {
    if (state.phase != FocusPhase.running || _hiddenAt != null) return;
    final now = _clock.now();
    final seconds = _live(now.isBefore(_lastTick) ? _lastTick : now);
    _stopTicker();
    _hiddenAt = now;
    _anchorSeconds = seconds;
    _anchor = now;
    await _repo.saveSession(
      state.sessionId!,
      seconds: seconds,
      at: now,
      hiddenAt: now,
      awaySeconds: _awaySeconds,
    );
    _lastSave = now;
    _set(state.copyWith(sessionSeconds: seconds));
    await _screen.keepAwake(false);
    // The system brightness comes back by itself as the app leaves; nothing
    // is left to restore if the app dies in the background.
    if (state.powerSave) {
      await _settings.write(SettingKeys.focusRestoreBrightness, null);
    }
  });

  /// The app is in front again: a session left for no longer than the grace
  /// period goes on, a longer absence ends it where the player left.
  Future<void> returned() => _serial(() async {
    final now = _clock.now();
    if (state.phase == FocusPhase.resting) {
      final ends = state.breakEndsAt;
      if (ends == null || !now.isBefore(ends)) await _endBreak(over: true);
      return;
    }
    final hiddenAt = _hiddenAt;
    if (state.phase != FocusPhase.running || hiddenAt == null) return;
    final away = now.difference(hiddenAt).inSeconds;
    if (away > _focusRules.awayGraceSeconds) {
      await _finish(
        at: hiddenAt,
        seconds: _anchorSeconds,
        reason: FocusEnd.away,
      );
      _set(const FocusState(ready: true, endedAway: true));
      return;
    }
    // The time away is not focus; counting goes on from now.
    _hiddenAt = null;
    _awaySeconds += math.max(0, away);
    _anchor = now;
    _lastTick = now;
    _lastSave = now;
    await _repo.saveSession(
      state.sessionId!,
      seconds: _anchorSeconds,
      at: now,
      awaySeconds: _awaySeconds,
    );
    await _screen.keepAwake(true);
    // Dim again, from whatever the system is set to now.
    if (state.powerSave) await _dim();
    _startTicker();
  });

  /// Dims the screen for the power-saving view, or brings it back.
  Future<void> setPowerSave(bool on) => _serial(() async {
    if (on == state.powerSave) return;
    if (on) {
      await _dim();
      _set(state.copyWith(powerSave: true));
    } else {
      await _undim();
    }
  });

  Future<void> _dim() async {
    await _settings.write(
      SettingKeys.focusRestoreBrightness,
      await _screen.systemBrightness(),
    );
    await _screen.setBrightness(_focusRules.powerSaveBrightness);
  }

  Future<void> _undim() async {
    await _screen.resetBrightness();
    await _settings.write(SettingKeys.focusRestoreBrightness, null);
    _set(state.copyWith(powerSave: false));
  }
}
