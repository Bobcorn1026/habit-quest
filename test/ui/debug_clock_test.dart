import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app/providers.dart';
import 'package:habit_quest/core/clock.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/ui/screens/settings/debug_clock.dart';

void main() {
  testWidgets('the debug clock moves the day forward and back', (tester) async {
    final clock = AdjustableClock();
    final today = LogicalDay.of(DateTime.now());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clockProvider.overrideWithValue(clock)],
        child: const MaterialApp(home: Scaffold(body: DebugClockControls())),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DebugClockControls)),
    );
    expect(container.read(todayProvider), today);

    await tester.tap(find.text('+1 天'));
    await tester.pump();
    expect(container.read(todayProvider), today.addDays(1));
    expect(find.textContaining('快 1 天'), findsOneWidget);

    await tester.tap(find.text('+1 週'));
    await tester.pump();
    expect(container.read(todayProvider), today.addDays(8));

    await tester.tap(find.text('回到現在'));
    await tester.pump();
    expect(container.read(todayProvider), today);
    expect(clock.offset, Duration.zero);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a pinned clock has nothing to move', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 9))),
        ],
        child: const MaterialApp(home: Scaffold(body: DebugClockControls())),
      ),
    );
    expect(find.text('+1 天'), findsNothing);
  });
}
