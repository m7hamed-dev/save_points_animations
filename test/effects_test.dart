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
      const FadeEffect().apply(acc, 0.5); // 0.5
      const FadeEffect().apply(acc, 0.5); // *0.5
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
      const ScaleEffect(end: 2).apply(acc, 0.5);
      expect(acc.transform.getMaxScaleOnAxis(), closeTo(1.0, 1e-9));
    });

    test('SlideEffect accumulates a size-relative offset, no wrapper', () {
      final moving = FxAccumulator();
      const SlideEffect(beginY: 1).apply(moving, 0.0);
      expect(moving.fractionalTranslation, const Offset(0, 1));
      expect(moving.wraps, isEmpty);

      final atRest = FxAccumulator();
      const SlideEffect(beginY: 1).apply(atRest, 1.0);
      expect(atRest.fractionalTranslation, Offset.zero);
    });

    test('directional slides and moves mirror under RTL', () {
      final ltr = FxAccumulator();
      const SlideEffect(beginX: -1, directional: true).apply(ltr, 0.0);
      expect(ltr.fractionalTranslation, const Offset(-1, 0));

      final rtl = FxAccumulator(textDirection: TextDirection.rtl);
      const SlideEffect(beginX: -1, directional: true).apply(rtl, 0.0);
      expect(rtl.fractionalTranslation, const Offset(1, 0));

      final plain = FxAccumulator(textDirection: TextDirection.rtl);
      const SlideEffect(beginX: -1).apply(plain, 0.0);
      expect(plain.fractionalTranslation, const Offset(-1, 0));

      final move = FxAccumulator(textDirection: TextDirection.rtl);
      const MoveEffect(beginX: 20, directional: true).apply(move, 0.0);
      expect(move.transform.getTranslation().x, -20);
    });

    test('paint-only flags match what apply writes', () {
      const paintOnly = <FxEffect>[
        FadeEffect(),
        MoveEffect(beginX: 4),
        ScaleEffect(),
        RotateEffect(),
        SkewEffect(beginX: 4),
        FlipEffect(),
        SlideEffect(beginY: 1),
        ShakeEffect(),
        BounceEffect(),
        PulseEffect(),
        BreatheEffect(),
        PopEffect(),
        RollInEffect(),
        HingeEffect(),
        JackInTheBoxEffect(),
        WobbleEffect(),
        SwingEffect(),
        HeartbeatEffect(),
        JellyEffect(),
        RubberBandEffect(),
        TadaEffect(),
        FloatEffect(),
        FlashEffect(),
        BlinkEffect(),
      ];
      for (final effect in paintOnly) {
        expect(effect.paintOnly, isTrue, reason: '$effect');
        for (final t in <double>[0, 0.25, 0.5, 0.75, 1]) {
          final acc = FxAccumulator();
          effect.apply(acc, t);
          expect(acc.wraps, isEmpty, reason: '$effect at t=$t');
        }
      }
      expect(const GlowEffect().paintOnly, isFalse);
      expect(const BlurEffect().paintOnly, isFalse);
    });
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
