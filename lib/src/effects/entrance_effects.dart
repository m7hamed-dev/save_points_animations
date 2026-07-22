import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

double _deg2rad(double deg) => deg * math.pi / 180.0;

/// Roll in from the left with rotation (Animate.css `rollIn`).
///
/// Self-contained: fades, slides from -100% and unrolls from -120°.
class RollInEffect extends FxEffect {
  const RollInEffect({super.delay, super.duration, super.curve});

  @override
  void apply(FxAccumulator acc, double t) {
    acc.opacity *= t.clamp(0.0, 1.0);
    acc.transform.multiply(Matrix4.rotationZ(_deg2rad(fxLerp(-120, 0, t))));
    final dx = fxLerp(-1.0, 0, t);
    if (dx != 0) {
      acc.addWrap(
        (child) =>
            FractionalTranslation(translation: Offset(dx, 0), child: child),
      );
    }
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => RollInEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Swing from a corner and drop away (Animate.css `hinge` — an exit).
///
/// Note: Animate.css hinges from the top-left corner; this engine transforms
/// about center, so the swing reads slightly differently but the choreography
/// (wobble, then fall + fade) is preserved.
class HingeEffect extends FxEffect {
  const HingeEffect({super.delay, super.duration, super.curve = Curves.linear});

  @override
  void apply(FxAccumulator acc, double t) {
    final rot = fxKeyframe(t, const [
      [0, 0],
      [0.2, 80],
      [0.4, 60],
      [0.6, 80],
      [0.8, 60],
      [1, 60],
    ]);
    final fall = t < 0.8 ? 0.0 : (t - 0.8) / 0.2 * 700;
    final op = t < 0.8 ? 1.0 : 1 - (t - 0.8) / 0.2;

    acc.transform.multiply(Matrix4.translationValues(0, fall, 0));
    acc.transform.multiply(Matrix4.rotationZ(_deg2rad(rot)));
    acc.opacity *= op.clamp(0.0, 1.0);
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => HingeEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Pop out of a box: tiny + rotated → full (Animate.css `jackInTheBox`).
class JackInTheBoxEffect extends FxEffect {
  const JackInTheBoxEffect({super.delay, super.duration, super.curve});

  @override
  void apply(FxAccumulator acc, double t) {
    acc.opacity *= t.clamp(0.0, 1.0);
    final scale = fxLerp(0.1, 1.0, t);
    final rot = fxKeyframe(t, const [
      [0, 30],
      [0.5, -10],
      [0.7, 3],
      [1, 0],
    ]);
    acc.transform.multiply(Matrix4.rotationZ(_deg2rad(rot)));
    acc.transform.multiply(Matrix4.diagonal3Values(scale, scale, 1));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => JackInTheBoxEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
