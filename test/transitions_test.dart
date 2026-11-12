import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FxPageRoute', () {
    for (final transition in FxPageTransition.values) {
      testWidgets('$transition pushes and settles on the new page', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(transition),
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

    testWidgets(
      'modern transitions render their signature widgets mid-flight',
      (tester) async {
        Future<void> pushAndCheck(
          FxPageTransition transition,
          Finder signature,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey(transition),
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
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 150)); // mid-flight
          expect(signature, findsWidgets, reason: '$transition');
          await tester.pumpAndSettle();
        }

        await pushAndCheck(
          FxPageTransition.circularReveal,
          find.byType(ClipPath),
        );
        await pushAndCheck(FxPageTransition.blur, find.byType(ImageFiltered));
        await pushAndCheck(FxPageTransition.cube3D, find.byType(Transform));
        await pushAndCheck(FxPageTransition.glass, find.byType(ImageFiltered));
        await pushAndCheck(
          FxPageTransition.containerTransform,
          find.byType(ClipPath),
        );
      },
    );

    testWidgets('fxPushReveal and fxPushFrom navigate successfully', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.fxPushReveal<void>(
                      const Scaffold(body: Center(child: Text('REVEAL'))),
                      alignment: Alignment.topLeft,
                    ),
                    child: const Text('reveal'),
                  ),
                  ElevatedButton(
                    onPressed: () => context.fxPushFrom<void>(
                      const Scaffold(body: Center(child: Text('CONTAINER'))),
                      const Rect.fromLTWH(20, 40, 100, 60),
                    ),
                    child: const Text('container'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('reveal'));
      await tester.pumpAndSettle();
      expect(find.text('REVEAL'), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('container'));
      await tester.pumpAndSettle();
      expect(find.text('CONTAINER'), findsOneWidget);
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
