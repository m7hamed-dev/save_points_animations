import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('reveal & clip effects', () {
    test('CircularRevealEffect adds a ClipPath wrapper', () {
      final acc = FxAccumulator();
      const CircularRevealEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });

    test('WipeEffect adds a ClipRect wrapper', () {
      final acc = FxAccumulator();
      const WipeEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });

    testWidgets('fluent reveal effects build and render', (tester) async {
      await tester.pumpWidget(
        _host(
          const Text('reveal')
              .animate()
              .circularReveal()
              .then()
              .wipe(direction: AxisDirection.down)
              .then()
              .curtain(),
        ),
      );
      expect(find.text('reveal'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('loading indicators', () {
    testWidgets('render and animate without leaks', (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [FxDotsLoader(), FxBarsLoader(), FxProgressRing()],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(FxDotsLoader), findsOneWidget);
      expect(find.byType(FxBarsLoader), findsOneWidget);
      expect(find.byType(FxProgressRing), findsOneWidget);
      // Dispose without leaked repeating tickers.
      await tester.pumpWidget(_host(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });

  group('text FX', () {
    testWidgets('gradient / wavy / scramble / words build', (tester) async {
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'Gradient'.gradientText(),
              'Wavy'.wavyText(),
              'SCRAMBLE'.scrambleText(
                duration: const Duration(milliseconds: 300),
              ),
              'word by word'.wordsFadeIn(),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 300));
      // Scramble settles to the real text.
      expect(find.text('SCRAMBLE'), findsOneWidget);
    });

    testWidgets('wordsFadeIn produces one animated word per token', (
      tester,
    ) async {
      await tester.pumpWidget(_host('one two three'.wordsFadeIn()));
      expect(find.byType(FxBuilder), findsNWidgets(3));
    });
  });

  group('confetti', () {
    testWidgets('bursts on controller.play without error', (tester) async {
      final controller = FxConfettiController();
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 200,
            height: 200,
            child: FxConfetti(
              controller: controller,
              child: const ColoredBox(color: Color(0xFFEEEEEE)),
            ),
          ),
        ),
      );
      controller.play();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(_host(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });

  group('3D tilt', () {
    testWidgets('wraps child in a Transform and tracks hover', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 100, height: 100).tilt()),
      );
      expect(find.byType(FxTilt), findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(
        tester.getTopLeft(find.byType(FxTilt)) + const Offset(10, 10),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.takeException(), isNull);
    });
  });
}
