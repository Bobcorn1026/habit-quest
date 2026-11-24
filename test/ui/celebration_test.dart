import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ui/widgets/celebration.dart';

void main() {
  testWidgets('chibis dance until 莉娜 finishes and is tapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showCelebration(
                context,
                title: '等級提升！',
                detail: 'Lv.1 → Lv.2',
                lines: const ['恭喜！'],
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('等級提升！'), findsOneWidget);
    expect(find.byType(DancingChibis), findsOneWidget);

    await tester.tap(find.text('恭喜！'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('等級提升！'), findsNothing);
  });
}
