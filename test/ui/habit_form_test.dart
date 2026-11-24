import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/data/habit_repository.dart';
import 'package:habit_quest/domain/habit.dart';
import 'package:habit_quest/core/logical_day.dart';
import 'package:habit_quest/ui/widgets/habit_form.dart';

import '../support/app_harness.dart';

void main() {
  /// Opens the form from a button; [result] holds what it returned.
  Future<AppHarness> open(
    WidgetTester tester,
    List<HabitDraft?> result, {
    HabitKind kind = HabitKind.build,
    Habit? initial,
  }) async {
    final h = AppHarness();
    await h.pump(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => result.add(
                await HabitForm.show(context, kind, initial: initial),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await h.settle(tester);
    await tester.pump(const Duration(seconds: 1));
    return h;
  }

  Future<void> nameIt(WidgetTester tester, String name) =>
      tester.enterText(find.byType(TextField).first, name);

  testWidgets('frequency starts at every day and steps down to 4 a week', (
    tester,
  ) async {
    final result = <HabitDraft?>[];
    final h = await open(tester, result);
    expect(find.text('每天'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('－'));
      await tester.pump();
    }
    expect(find.text('每週 4 次'), findsOneWidget);

    await nameIt(tester, '健身房');
    await tester.tap(find.text('加入'));
    await h.settle(tester);
    expect(result.single!.timesPerWeek, 4);
    expect(result.single!.name, '健身房');
    await h.dispose(tester);
  });

  testWidgets('every count from 1 to 7 a week can be reached', (tester) async {
    final result = <HabitDraft?>[];
    final h = await open(tester, result);
    // Down to 1: the minus button stops there.
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.text('－'));
      await tester.pump();
    }
    expect(find.text('每週 1 次'), findsOneWidget);
    // Up through every count to 7, which reads as every day.
    for (var n = 2; n <= 6; n++) {
      await tester.tap(find.text('＋'));
      await tester.pump();
      expect(find.text('每週 $n 次'), findsOneWidget);
    }
    await tester.tap(find.text('＋'));
    await tester.pump();
    expect(find.text('每天'), findsOneWidget);
    // And the plus button stops at 7.
    await tester.tap(find.text('＋'));
    await tester.pump();
    expect(find.text('每天'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('editing a habit starts from its own frequency', (tester) async {
    final result = <HabitDraft?>[];
    final habit = Habit(
      id: 1,
      kind: HabitKind.build,
      name: '健身房',
      unit: '分鐘',
      target: 60,
      timesPerWeek: 4,
      firstDay: const LogicalDay(2026, 11, 2),
      createdAt: DateTime(2026, 11, 2),
    );
    final h = await open(tester, result, initial: habit);
    expect(find.text('每週 4 次'), findsOneWidget);
    await tester.tap(find.text('＋'));
    await tester.pump();
    expect(find.text('每週 5 次'), findsOneWidget);
    await h.dispose(tester);
  });

  testWidgets('a quit habit has no frequency', (tester) async {
    final result = <HabitDraft?>[];
    final h = await open(tester, result, kind: HabitKind.quit);
    expect(find.text('－'), findsNothing);
    await nameIt(tester, '十一點後滑手機');
    await tester.tap(find.text('加入'));
    await h.settle(tester);
    expect(result.single!.timesPerWeek, 7);
    await h.dispose(tester);
  });

  testWidgets('any amount and unit can be typed', (tester) async {
    final result = <HabitDraft?>[];
    final h = await open(tester, result);
    await nameIt(tester, '伏地挺身');
    // Fields in order: name, amount, unit.
    await tester.enterText(find.byType(TextField).at(1), '37.5');
    await tester.enterText(find.byType(TextField).at(2), '下');
    await tester.tap(find.text('加入'));
    await h.settle(tester);
    expect(result.single!.target, 37.5);
    expect(result.single!.unit, '下');
    await h.dispose(tester);
  });
}
