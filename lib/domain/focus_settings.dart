import 'package:flutter/foundation.dart';

/// What the player changed at the training ground; null keeps the rule
/// (`FocusRules`). The daily minutes and the goal only matter from the next
/// week on, when that week's terms are fixed; the break and the sound at
/// once, since they change no gold.
@immutable
class FocusSettings {
  const FocusSettings({
    this.dailyMinutes,
    this.goalMinutes,
    this.breakMinutes,
    this.sound = true,
    this.showClock = false,
    this.hideTimer = false,
  });

  factory FocusSettings.fromJson(Object? json) {
    final map = json is Map ? json : const {};
    int? minutes(Object? value) =>
        value is num && value > 0 ? value.toInt() : null;
    return FocusSettings(
      dailyMinutes: minutes(map['dailyMinutes']),
      goalMinutes: minutes(map['goalMinutes']),
      breakMinutes: minutes(map['breakMinutes']),
      sound: map['sound'] != false,
      showClock: map['showClock'] == true,
      hideTimer: map['hideTimer'] == true,
    );
  }

  /// How far below zero each day starts.
  final int? dailyMinutes;

  /// The weekly goal.
  final int? goalMinutes;

  /// The break after a session.
  final int? breakMinutes;

  /// 8-bit sounds when a session starts and stops and a break ends.
  final bool sound;

  /// The focus screen also shows the time of day.
  final bool showClock;

  /// The focus screen hides the running numbers, for focus without watching
  /// the clock.
  final bool hideTimer;

  /// A copy with the given changes.
  FocusSettings copyWith({
    int? dailyMinutes,
    int? goalMinutes,
    int? breakMinutes,
    bool? sound,
    bool? showClock,
    bool? hideTimer,
  }) => FocusSettings(
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    goalMinutes: goalMinutes ?? this.goalMinutes,
    breakMinutes: breakMinutes ?? this.breakMinutes,
    sound: sound ?? this.sound,
    showClock: showClock ?? this.showClock,
    hideTimer: hideTimer ?? this.hideTimer,
  );

  Map<String, Object?> toJson() => {
    'dailyMinutes': ?dailyMinutes,
    'goalMinutes': ?goalMinutes,
    'breakMinutes': ?breakMinutes,
    if (!sound) 'sound': false,
    if (showClock) 'showClock': true,
    if (hideTimer) 'hideTimer': true,
  };
}
