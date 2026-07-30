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

/// A playful entrance: the child fades in while its scale overshoots past 1
/// and settles back — a subtle "pop". Great for badges, chips, reactions, and
/// anything that should feel like it snaps into place.
class PopEffect extends FxEffect {
  const PopEffect({
    this.overshoot = 1.1,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  /// Peak scale reached before settling to 1 (1.1 == +10%).
  final double overshoot;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.opacity *= fxKeyframe(t, const [
      [0, 0],
      [0.35, 1],
      [1, 1],
    ]).clamp(0.0, 1.0);
    final s = fxKeyframe(t, [
      [0, 0.3],
      [0.6, overshoot],
      [0.8, 0.98],
      [1, 1],
    ]);
    acc.transform.multiply(Matrix4.diagonal3Values(s, s, 1));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => PopEffect(
    overshoot: overshoot,
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
