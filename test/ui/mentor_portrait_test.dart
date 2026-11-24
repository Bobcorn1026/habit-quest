import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_quest/ui/pixel/pixel.dart';
import 'package:habit_quest/ui/widgets/mentor_portrait.dart';

PixelSprite faceAt(int ms) => MentorIdle.at(Duration(milliseconds: ms)).face;

PixelSprite shownFace(WidgetTester tester) => tester
    .widgetList<PixelSpriteView>(find.byType(PixelSpriteView))
    .map((v) => v.sprite)
    .firstWhere((s) => s.width == 48);

void main() {
  test('莉娜 blinks, yawns and loops', () {
    expect(faceAt(0), MentorFrames.idle);
    expect(faceAt(2650), MentorFrames.blink);
    expect(faceAt(2800), MentorFrames.idle);
    expect(faceAt(18100), MentorFrames.yawnStart);
    expect(faceAt(19000), MentorFrames.yawn);
    expect(faceAt(19800), MentorFrames.yawnStart);
    expect(faceAt(24000 + 2650), MentorFrames.blink);
  });

  test('the z drifts up and to the right, then starts over', () {
    final early = MentorIdle.at(const Duration(milliseconds: 100)).zs.first;
    final later = MentorIdle.at(const Duration(milliseconds: 2000)).zs.first;
    expect(later.y, lessThan(early.y));
    expect(later.x, greaterThanOrEqualTo(early.x));
    final next = MentorIdle.at(
      const Duration(milliseconds: MentorIdle.zPeriod + 100),
    ).zs.first;
    expect(next, early);
  });

  testWidgets('the portrait plays the loop', (tester) async {
    await tester.pumpWidget(const Center(child: MentorPortrait()));
    expect(shownFace(tester), MentorFrames.idle);
    await tester.pump(const Duration(milliseconds: 2650));
    expect(shownFace(tester), MentorFrames.blink);
    await tester.pump(const Duration(milliseconds: 300));
    expect(shownFace(tester), MentorFrames.idle);
  });

  testWidgets('reduced motion keeps her still', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Center(child: MentorPortrait()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2650));
    expect(shownFace(tester), MentorFrames.idle);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
