import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FxPageRoute', () {
    for (final transition in FxPageTransition.values) {
      testWidgets('$transition pushes and settles on the new page', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.fxPush<void>(
                      const Scaffold(body: Center(child: Text('DETAIL'))),
                      transition: transition,
                    ),
                    child: const Text('go'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('go'));
        await tester.pump(); // start transition
        await tester.pump(const Duration(milliseconds: 175)); // mid-flight
        await tester.pumpAndSettle(); // complete

        expect(find.text('DETAIL'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('reverse (pop) animates back without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.fxPush<void>(
                    const Scaffold(body: Center(child: Text('DETAIL'))),
                    transition: FxPageTransition.sharedAxisHorizontal,
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Hero', () {
    testWidgets('heroAnimate flies between routes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: GestureDetector(
                  onTap: () => context.fxPush<void>(
                    Scaffold(
                      body: Center(
                        child: const SizedBox(
                          width: 200,
                          height: 200,
                        ).heroAnimate('box'),
                      ),
                    ),
                  ),
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                  ).heroAnimate('box'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
      await tester.tap(find.byType(Hero));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-flight a Hero is in the overlay.
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    test('FxArcRectTween lifts the path at mid-flight', () {
      final tween = FxArcRectTween(
        begin: const Rect.fromLTWH(0, 0, 10, 10),
        end: const Rect.fromLTWH(200, 200, 10, 10),
      );
      final mid = tween.lerp(0.5);
      final straight = RectTween(
        begin: const Rect.fromLTWH(0, 0, 10, 10),
        end: const Rect.fromLTWH(200, 200, 10, 10),
      ).lerp(0.5)!;
      // The arc shifts vertically off the straight-line midpoint.
      expect(mid.center.dy, isNot(closeTo(straight.center.dy, 0.5)));
    });
  });
}
