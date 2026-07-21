import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FadeEffect', () {
    test('multiplies opacity by the interpolated value', () {
      final acc = FxAccumulator();
      const FadeEffect().apply(acc, 0.5);
      expect(acc.opacity, closeTo(0.5, 1e-9));
    });

    test('composes multiplicatively with a second fade', () {
      final acc = FxAccumulator();
      const FadeEffect(begin: 0, end: 1).apply(acc, 0.5); // 0.5
      const FadeEffect(begin: 0, end: 1).apply(acc, 0.5); // *0.5
      expect(acc.opacity, closeTo(0.25, 1e-9));
    });

    test('clamps out-of-range values', () {
      final acc = FxAccumulator();
      const FadeEffect(begin: 2, end: 2).apply(acc, 1);
      expect(acc.opacity, 1.0);
    });
  });

  group('transform effects', () {
    test('MoveEffect leaves an identity transform at rest (t=1, end=0)', () {
      final acc = FxAccumulator();
      const MoveEffect(beginY: 50).apply(acc, 1.0);
      expect(acc.transform.isIdentity(), isTrue);
    });

    test('MoveEffect translates at the midpoint', () {
      final acc = FxAccumulator();
      const MoveEffect(beginY: 50).apply(acc, 0.0);
      expect(acc.transform.getTranslation().y, closeTo(50, 1e-9));
    });

    test('ScaleEffect scales the matrix', () {
      final acc = FxAccumulator();
      const ScaleEffect(begin: 0, end: 2).apply(acc, 0.5);
      expect(acc.transform.getMaxScaleOnAxis(), closeTo(1.0, 1e-9));
    });

    test(
      'SlideEffect adds a FractionalTranslation wrapper only when moving',
      () {
        final moving = FxAccumulator();
        const SlideEffect(beginY: 1).apply(moving, 0.0);
        expect(moving.wraps, hasLength(1));

        final atRest = FxAccumulator();
        const SlideEffect(beginY: 1).apply(atRest, 1.0);
        expect(atRest.wraps, isEmpty);
      },
    );
  });

  group('custom effect', () {
    test('a user-defined FxEffect participates in the accumulator', () {
      final acc = FxAccumulator();
      const _HalveOpacity().apply(acc, 1.0);
      expect(acc.opacity, 0.5);
    });
  });
}

class _HalveOpacity extends FxEffect {
  const _HalveOpacity();

  @override
  void apply(FxAccumulator acc, double t) => acc.opacity *= 0.5;

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => this;
}
