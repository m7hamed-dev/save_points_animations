import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('color effects (accumulator)', () {
    test('SaturationEffect adds a ColorFilter wrapper', () {
      final acc = FxAccumulator();
      const SaturationEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });

    test('BrightnessEffect interpolates and wraps', () {
      final acc = FxAccumulator();
      const BrightnessEffect(begin: 0.5, end: 1.5).apply(acc, 1);
      expect(acc.wraps, hasLength(1));
    });

    test('HueEffect wraps with a color filter', () {
      final acc = FxAccumulator();
      const HueEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });
  });

  group('loading effects', () {
    test('ShimmerEffect adds a ShaderMask wrapper', () {
      final acc = FxAccumulator();
      const ShimmerEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });

    test('BreatheEffect returns to rest at both ends', () {
      final start = FxAccumulator();
      const BreatheEffect().apply(start, 0.0);
      expect(start.transform.isIdentity(), isTrue);
      expect(start.opacity, closeTo(1.0, 1e-6));

      final end = FxAccumulator();
      const BreatheEffect().apply(end, 1.0);
      expect(end.transform.isIdentity(), isTrue);
      expect(end.opacity, closeTo(1.0, 1e-6));
    });
  });

  group('entrance effects', () {
    test('RollInEffect settles to identity + full opacity', () {
      final acc = FxAccumulator();
      const RollInEffect().apply(acc, 1.0);
      expect(acc.transform.isIdentity(), isTrue);
      expect(acc.opacity, closeTo(1.0, 1e-6));
    });

    test('JackInTheBoxEffect starts tiny/transparent and settles full', () {
      final start = FxAccumulator();
      const JackInTheBoxEffect().apply(start, 0.0);
      expect(start.opacity, closeTo(0.0, 1e-6));
      // Column-0 length is the x-scale (~0.1 at the start).
      final sx =
          start.transform.entry(0, 0).abs() + start.transform.entry(1, 0).abs();
      expect(sx, lessThan(0.2));

      final end = FxAccumulator();
      const JackInTheBoxEffect().apply(end, 1.0);
      expect(end.opacity, closeTo(1.0, 1e-6));
      expect(end.transform.isIdentity(), isTrue);
    });

    test('HingeEffect fades out by the end', () {
      final acc = FxAccumulator();
      const HingeEffect().apply(acc, 1.0);
      expect(acc.opacity, closeTo(0.0, 1e-6));
    });
  });

  group('fluent + one-shot wiring', () {
    testWidgets('new fluent effects build and render', (tester) async {
      await tester.pumpWidget(
        _host(
          const Text('x')
              .animate()
              .shimmer()
              .then()
              .grayscale()
              .then()
              .rollIn()
              .then()
              .hueShift(),
        ),
      );
      expect(find.text('x'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('widget one-shots build', (tester) async {
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('a').shimmer(),
              const Text('b').jackInTheBox(),
              const Text('c').rotateIn(),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('text animations', () {
    testWidgets('typewriter reveals characters over time', (tester) async {
      await tester.pumpWidget(
        _host('Hello'.typewriter(duration: const Duration(milliseconds: 500))),
      );
      await tester.pump(); // start
      await tester.pump(const Duration(milliseconds: 250));
      final midText = tester.widget<Text>(find.byType(Text)).data ?? '';
      expect(midText.length, greaterThan(0));
      expect(midText.length, lessThan('Hello'.length));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.widget<Text>(find.byType(Text)).data, 'Hello');
    });

    testWidgets('animateChars produces one animated glyph per character', (
      tester,
    ) async {
      await tester.pumpWidget(_host('abc'.animateChars()));
      expect(find.byType(FxBuilder), findsNWidgets(3));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('countUp animates toward the target', (tester) async {
      await tester.pumpWidget(
        _host((100).countUp(duration: const Duration(milliseconds: 400))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final mid = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(100));
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.widget<Text>(find.byType(Text)).data, '100');
    });
  });
}
