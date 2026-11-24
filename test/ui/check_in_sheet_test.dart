import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ui/pixel/pixel.dart';
import 'package:habit_quest/ui/screens/board/check_in_sheet.dart';

import '../support/app_harness.dart';
import '../support/builders.dart';

void main() {
  /// Opens the sheet for a [target]-per-day habit; [result] gets its answer.
  Future<AppHarness> open(
    WidgetTester tester,
    List<CheckInInput?> result, {
    double target = 20,
    String unit = '分鐘',
  }) async {
    final h = AppHarness();
    await h.pump(
      tester,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async => result.add(
                await CheckInSheet.show(
                  context,
                  habit: buildHabit(target: target, unit: unit),
                  quest: buildQuest(target: target),
                ),
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

  Future<void> typeAmount(WidgetTester tester, String value) async {
    await tester.tap(find.byKey(const Key('amount-value')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('amount-field')), value);
    await tester.pump();
  }

  bool submitEnabled(WidgetTester tester) =>
      tester
          .widget<PixelButton>(find.widgetWithText(PixelButton, '回報冒險成果'))
          .onPressed !=
      null;

  testWidgets('tapping the number lets you type exactly what you did', (
    tester,
  ) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result);
    expect(find.byKey(const Key('amount-field')), findsNothing);

    await typeAmount(tester, '12');
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);

    expect(result.single!.amount, 12);
    await h.dispose(tester);
  });

  testWidgets('decimals work too', (tester) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result, target: 5, unit: '公里');
    await typeAmount(tester, '4.5');
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);
    expect(result.single!.amount, 4.5);
    await h.dispose(tester);
  });

  testWidgets('more than the target can be typed', (tester) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result);
    await typeAmount(tester, '95');
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);
    expect(result.single!.amount, 95);
    await h.dispose(tester);
  });

  testWidgets('an empty or zero amount cannot be reported', (tester) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result);
    await typeAmount(tester, '');
    expect(submitEnabled(tester), isFalse);
    await tester.enterText(find.byKey(const Key('amount-field')), '0');
    await tester.pump();
    expect(submitEnabled(tester), isFalse);
    await tester.enterText(find.byKey(const Key('amount-field')), '3');
    await tester.pump();
    expect(submitEnabled(tester), isTrue);
    await h.dispose(tester);
  });

  testWidgets('the plus and minus buttons carry on from a typed amount', (
    tester,
  ) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result);
    await typeAmount(tester, '12');
    await tester.tap(find.text('＋'));
    await tester.pump();
    expect(find.byKey(const Key('amount-field')), findsNothing);
    expect(find.text('17'), findsOneWidget);
    await tester.tap(find.text('回報冒險成果'));
    await h.settle(tester);
    expect(result.single!.amount, 17);
    await h.dispose(tester);
  });

  testWidgets('the existing buttons still work without typing', (tester) async {
    final result = <CheckInInput?>[];
    final h = await open(tester, result);
    await tester.tap(find.text('－'));
    await tester.pump();
    expect(find.text('15'), findsOneWidget);
    await tester.tap(find.text('×2.0'));
    await tester.pump();
    expect(find.text('40'), findsOneWidget);
    await h.dispose(tester);
  });
}
