import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// The screen while focusing: kept awake, and dimmed in the power-saving
/// view.
abstract interface class ScreenControl {
  Future<void> keepAwake(bool on);

  /// The brightness the system is set to, 0–1.
  Future<double> systemBrightness();

  /// Sets the brightness while the app is in front; leaving the app brings
  /// the system's back on its own, and coming back sets this one again.
  Future<void> setBrightness(double level);

  /// Back to the system brightness.
  Future<void> resetBrightness();

  /// Makes [level] the system brightness again, after the app died with the
  /// screen dimmed.
  Future<void> restoreSystemBrightness(double level);
}

/// The real screen. A platform that cannot do something (the simulator's
/// brightness) is left as it is rather than failing the timer.
class DeviceScreenControl implements ScreenControl {
  const DeviceScreenControl();

  Future<T?> _try<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> keepAwake(bool on) =>
      _try(() => WakelockPlus.toggle(enable: on));

  @override
  Future<double> systemBrightness() async =>
      await _try(() => ScreenBrightness.instance.system) ?? 1;

  @override
  Future<void> setBrightness(double level) => _try(
    () => ScreenBrightness.instance.setApplicationScreenBrightness(level),
  );

  @override
  Future<void> resetBrightness() =>
      _try(ScreenBrightness.instance.resetApplicationScreenBrightness);

  @override
  Future<void> restoreSystemBrightness(double level) =>
      _try(() => ScreenBrightness.instance.setSystemScreenBrightness(level));
}

final screenControlProvider = Provider<ScreenControl>(
  (ref) => const DeviceScreenControl(),
);
