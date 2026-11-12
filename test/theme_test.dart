import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FxTheme resolution', () {
    testWidgets('effect and transition curves theme independently', (
      tester,
    ) async {
      late FxThemeData resolved;
      await tester.pumpWidget(
        FxTheme(
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 111),
          transitionCurve: Curves.bounceOut,
          transitionDuration: const Duration(milliseconds: 222),
          child: Builder(
            builder: (context) {
              resolved = FxTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolved.curve, Curves.easeIn);
      expect(resolved.duration, const Duration(milliseconds: 111));
      expect(resolved.transitionCurve, Curves.bounceOut);
      expect(resolved.transitionDuration, const Duration(milliseconds: 222));
    });

    testWidgets('falls back to modern defaults when unset', (tester) async {
      late FxThemeData resolved;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = FxTheme.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(resolved.curve, FxCurves.emphasized);
      expect(resolved.transitionCurve, FxCurves.emphasized);
      expect(resolved.transitionDuration, const Duration(milliseconds: 350));
    });

    testWidgets('a themed transition still navigates', (tester) async {
      await tester.pumpWidget(
        FxTheme(
          transitionCurve: Curves.easeInOutBack,
          transitionDuration: const Duration(milliseconds: 200),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.fxPush<void>(
                      const Scaffold(body: Center(child: Text('THEMED'))),
                      transition: FxPageTransition.depth,
                    ),
                    child: const Text('go'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('THEMED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('FxThemeData.copyWith replaces only the given fields', () {
      const base = FxThemeData();
      final copy = base.copyWith(
        transitionCurve: Curves.bounceOut,
        duration: const Duration(milliseconds: 999),
      );
      expect(copy.transitionCurve, Curves.bounceOut);
      expect(copy.duration, const Duration(milliseconds: 999));
      // Untouched fields are preserved.
      expect(copy.curve, base.curve);
      expect(copy.transitionDuration, base.transitionDuration);
      // Value equality + hashing.
      expect(base.copyWith(), base);
      expect(base.copyWith().hashCode, base.hashCode);
      expect(copy, isNot(base));
    });
  });

  group('spring-driven route', () {
    testWidgets('fxPushSpring navigates with a physical settle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.fxPushSpring<void>(
                    const Scaffold(body: Center(child: Text('SPRUNG'))),
                    stiffness: 240,
                    damping: 18,
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
      await tester.pump(const Duration(milliseconds: 100)); // mid-flight
      expect(find.byType(SlideTransition), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('SPRUNG'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
