import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/logical_day.dart';
import '../pixel/pixel.dart';
import 'pixel_controls.dart';

/// iOS's own wheels, on the dark pixel look.
Widget _wheelTheme(Widget child) => CupertinoTheme(
  data: const CupertinoThemeData(
    brightness: Brightness.dark,
    textTheme: CupertinoTextThemeData(
      dateTimePickerTextStyle: TextStyle(
        color: PixelPalette.parchment,
        fontSize: 22,
      ),
    ),
  ),
  child: child,
);

/// Asks for a time of day on a 24-hour wheel. Null when the sheet is
/// dismissed or cancelled.
Future<TimeOfDay?> pickTime(
  BuildContext context, {
  required String title,
  required TimeOfDay initial,
}) => showPixelSheet<TimeOfDay>(
  context,
  builder: (_) => _WheelSheet<TimeOfDay>(
    title: title,
    initial: initial,
    wheel: (value, onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.time,
      use24hFormat: true,
      initialDateTime: DateTime(2026, 1, 1, initial.hour, initial.minute),
      onDateTimeChanged: (d) =>
          onChanged(TimeOfDay(hour: d.hour, minute: d.minute)),
    ),
  ),
);

/// Asks for a calendar day between [first] and [last]. Null when the sheet
/// is dismissed or cancelled.
Future<LogicalDay?> pickDay(
  BuildContext context, {
  required String title,
  required LogicalDay initial,
  required LogicalDay first,
  required LogicalDay last,
}) => showPixelSheet<LogicalDay>(
  context,
  builder: (_) => _WheelSheet<LogicalDay>(
    title: title,
    initial: initial,
    wheel: (value, onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: DateTime(initial.year, initial.month, initial.day),
      minimumDate: DateTime(first.year, first.month, first.day),
      maximumDate: DateTime(last.year, last.month, last.day),
      onDateTimeChanged: (d) => onChanged(LogicalDay(d.year, d.month, d.day)),
    ),
  ),
);

class _WheelSheet<T> extends StatefulWidget {
  const _WheelSheet({
    required this.title,
    required this.initial,
    required this.wheel,
  });

  final String title;
  final T initial;
  final Widget Function(T value, ValueChanged<T> onChanged) wheel;

  @override
  State<_WheelSheet<T>> createState() => _WheelSheetState<T>();
}

class _WheelSheetState<T> extends State<_WheelSheet<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: _wheelTheme(widget.wheel(_value, (v) => _value = v)),
        ),
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          onPressed: () => Navigator.pop<T>(context, _value),
          child: const Text('確定'),
        ),
        const SizedBox(height: 8),
        PixelButton(
          expand: true,
          tone: PixelButtonTone.quiet,
          onPressed: () => Navigator.pop<T>(context),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
