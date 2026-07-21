import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('attention effects return to rest at t=1', () {
    final identityAtEnd = <String, FxEffect>{
      'flash': const FlashEffect(),
      'wobble': const WobbleEffect(),
      'swing': const SwingEffect(),
      'heartbeat': const HeartbeatEffect(),
      'jelly': const JellyEffect(),
      'rubberBand': const RubberBandEffect(),
      'tada': const TadaEffect(),
      'float': const FloatEffect(),
    };

    identityAtEnd.forEach((name, effect) {
      test('$name is identity + full opacity at rest', () {
        final acc = FxAccumulator();
        effect.apply(acc, 1.0);
        expect(acc.transform.isIdentity(), isTrue, reason: name);
        expect(acc.opacity, closeTo(1.0, 1e-6), reason: name);
      });
    });
  });

  test('flash dips to zero opacity at its first quarter', () {
    final acc = FxAccumulator();
    const FlashEffect().apply(acc, 0.25);
    expect(acc.opacity, closeTo(0.0, 1e-6));
  });

  test('heartbeat scales up at its first beat', () {
    final acc = FxAccumulator();
    const HeartbeatEffect().apply(acc, 0.14);
    expect(acc.transform.getMaxScaleOnAxis(), closeTo(1.3, 1e-6));
  });

  test('rubberBand stretches non-uniformly', () {
    final acc = FxAccumulator();
    const RubberBandEffect().apply(acc, 0.3);
    final sx = acc.transform.entry(0, 0);
    final sy = acc.transform.entry(1, 1);
    expect(sx, closeTo(1.25, 1e-6));
    expect(sy, closeTo(0.75, 1e-6));
  });

  testWidgets('fluent attention methods build and render', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: const Text(
            '!',
          ).animate().tada().then().rubberBand().then().jelly(),
        ),
      ),
    );
    expect(find.text('!'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('presets build and render', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: const Icon(IconData(0x1F600)).success()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
