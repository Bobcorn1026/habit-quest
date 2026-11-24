import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/app.dart';
import 'package:habit_quest/ui/screens/dev/kit_gallery.dart';

void main() {
  testWidgets('kit gallery renders every component', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HabitQuestApp(home: KitGallery())),
    );
    await tester.pumpAndSettle();
    expect(find.text('第三章：霧之圖書館'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pixel type scale is crisp on a 3x screen', (tester) async {
    late double body;
    await tester.pumpWidget(
      HabitQuestApp(
        home: Builder(
          builder: (context) {
            body = Theme.of(context).textTheme.bodyMedium!.fontSize!;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tester.view.devicePixelRatio, 3);
    expect(body * 3 % 12, 0);
  });
}
