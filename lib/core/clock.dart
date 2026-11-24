/// Source of "now", injectable so tests can pin time.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// The system clock moved by [offset]: debug builds use it to try out the
/// days and weeks ahead.
class AdjustableClock implements Clock {
  AdjustableClock();

  Duration offset = Duration.zero;

  @override
  DateTime now() => DateTime.now().add(offset);
}

class FixedClock implements Clock {
  FixedClock(this.value);

  DateTime value;

  @override
  DateTime now() => value;

  void advance(Duration by) => value = value.add(by);
}
