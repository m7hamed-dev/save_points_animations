import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FxSpringCurve', () {
    test('has clean 0 and 1 endpoints', () {
      final spring = FxSpringCurve();
      expect(spring.transform(0), 0.0);
      expect(spring.transform(1), 1.0);
    });

    test('an underdamped spring overshoots past the target', () {
      final spring = FxSpringCurve();
      var maxValue = 0.0;
      for (var i = 0; i <= 100; i++) {
        final v = spring.transform(i / 100);
        if (v > maxValue) maxValue = v;
      }
      expect(maxValue, greaterThan(1.0)); // bounces past 1 then settles
    });

    test('a heavily damped spring does not overshoot much', () {
      final spring = FxSpringCurve(stiffness: 100, damping: 40);
      var maxValue = 0.0;
      for (var i = 0; i <= 100; i++) {
        final v = spring.transform(i / 100);
        if (v > maxValue) maxValue = v;
      }
      expect(maxValue, lessThan(1.05));
    });

    test('exposes a positive settle duration', () {
      expect(FxSpringCurve().settleDuration.inMilliseconds, greaterThan(0));
    });

    test('stiffer springs settle faster', () {
      final soft = FxSpringCurve(stiffness: 80).settleDuration;
      final stiff = FxSpringCurve(stiffness: 400).settleDuration;
      expect(stiff, lessThan(soft));
    });
  });

  group('FxPhysics curves', () {
    test('gravity has clean endpoints', () {
      final g = FxPhysics.gravity();
      expect(g.transform(0), 0.0);
      expect(g.transform(1), 1.0);
    });

    test('friction has clean endpoints', () {
      final f = FxPhysics.friction();
      expect(f.transform(0), 0.0);
      expect(f.transform(1), 1.0);
    });
  });

  testWidgets('spring() drives an effect and settles fully opaque', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: const Text(
            'spring',
          ).animate().fade().scale(begin: 0.5).spring(),
        ),
      ),
    );
    expect(find.text('spring'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    // Settled: fade reached 1, the Opacity wrapper is dropped.
    expect(find.byType(Opacity), findsNothing);
  });
}
