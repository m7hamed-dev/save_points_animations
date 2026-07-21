import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'fx_effect.dart';

double _deg2rad(double deg) => deg * math.pi / 180.0;

/// Piecewise-linear keyframe interpolation. [frames] is an ordered list of
/// `[stop, value]` pairs with `stop` in `0..1`.
double _kf(double t, List<List<double>> frames) {
  if (t <= frames.first[0]) return frames.first[1];
  if (t >= frames.last[0]) return frames.last[1];
  for (var i = 0; i < frames.length - 1; i++) {
    final a = frames[i];
    final b = frames[i + 1];
    if (t >= a[0] && t <= b[0]) {
      final span = b[0] - a[0];
      final local = span == 0 ? 0.0 : (t - a[0]) / span;
      return a[1] + (b[1] - a[1]) * local;
    }
  }
  return frames.last[1];
}

/// Attention-seeker effects carry a linear curve by default so their keyframe
/// timings map directly onto the timeline.
abstract class _AttentionEffect extends FxEffect {
  const _AttentionEffect({
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });
}

/// Opacity flashes on and off (Animate.css `flash`).
class FlashEffect extends _AttentionEffect {
  const FlashEffect({super.delay, super.duration, super.curve = Curves.linear});

  @override
  void apply(FxAccumulator acc, double t) {
    acc.opacity *= _kf(t, const [
      [0, 1],
      [0.25, 0],
      [0.5, 1],
      [0.75, 0],
      [1, 1],
    ]).clamp(0.0, 1.0);
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => FlashEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Horizontal shift + rotation wobble (Animate.css `wobble`).
class WobbleEffect extends _AttentionEffect {
  const WobbleEffect({
    this.amplitude = 1.0,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  /// Scales the wobble strength (1.0 == Animate.css defaults).
  final double amplitude;

  @override
  void apply(FxAccumulator acc, double t) {
    final tx =
        _kf(t, const [
          [0, 0],
          [0.15, -0.25],
          [0.3, 0.20],
          [0.45, -0.15],
          [0.6, 0.10],
          [0.75, -0.05],
          [1, 0],
        ]) *
        amplitude;
    final rot =
        _kf(t, const [
          [0, 0],
          [0.15, -5],
          [0.3, 3],
          [0.45, -3],
          [0.6, 2],
          [0.75, -1],
          [1, 0],
        ]) *
        amplitude;
    if (rot != 0) acc.transform.multiply(Matrix4.rotationZ(_deg2rad(rot)));
    if (tx != 0) {
      acc.addWrap(
        (child) =>
            FractionalTranslation(translation: Offset(tx, 0), child: child),
      );
    }
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => WobbleEffect(
    amplitude: amplitude,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Pendulum-like rotation (Animate.css `swing`).
class SwingEffect extends _AttentionEffect {
  const SwingEffect({super.delay, super.duration, super.curve = Curves.linear});

  @override
  void apply(FxAccumulator acc, double t) {
    final rot = _kf(t, const [
      [0, 0],
      [0.2, 15],
      [0.4, -10],
      [0.6, 5],
      [0.8, -5],
      [1, 0],
    ]);
    if (rot != 0) acc.transform.multiply(Matrix4.rotationZ(_deg2rad(rot)));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => SwingEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Two-beat scale pulse (Animate.css `heartBeat`).
class HeartbeatEffect extends _AttentionEffect {
  const HeartbeatEffect({
    this.peak = 1.3,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  final double peak;

  @override
  void apply(FxAccumulator acc, double t) {
    final s = _kf(t, [
      [0, 1],
      [0.14, peak],
      [0.28, 1],
      [0.42, peak],
      [0.7, 1],
      [1, 1],
    ]);
    if (s != 1) acc.transform.multiply(Matrix4.diagonal3Values(s, s, 1));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => HeartbeatEffect(
    peak: peak,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Skew wobble (Animate.css `jello`).
class JellyEffect extends _AttentionEffect {
  const JellyEffect({super.delay, super.duration, super.curve = Curves.linear});

  @override
  void apply(FxAccumulator acc, double t) {
    final skew = _kf(t, const [
      [0, 0],
      [0.111, 0],
      [0.222, -12.5],
      [0.333, 6.25],
      [0.444, -3.125],
      [0.555, 1.5625],
      [0.666, -0.78125],
      [0.777, 0.390625],
      [0.888, -0.1953125],
      [1, 0],
    ]);
    if (skew != 0) {
      final a = _deg2rad(skew);
      acc.transform.multiply(
        Matrix4.identity()
          ..setEntry(0, 1, math.tan(a))
          ..setEntry(1, 0, math.tan(a)),
      );
    }
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => JellyEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Non-uniform squash-and-stretch (Animate.css `rubberBand`).
class RubberBandEffect extends _AttentionEffect {
  const RubberBandEffect({
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  @override
  void apply(FxAccumulator acc, double t) {
    final sx = _kf(t, const [
      [0, 1],
      [0.3, 1.25],
      [0.4, 0.75],
      [0.5, 1.15],
      [0.65, 0.95],
      [0.75, 1.05],
      [1, 1],
    ]);
    final sy = _kf(t, const [
      [0, 1],
      [0.3, 0.75],
      [0.4, 1.25],
      [0.5, 0.85],
      [0.65, 1.05],
      [0.75, 0.95],
      [1, 1],
    ]);
    if (sx != 1 || sy != 1) {
      acc.transform.multiply(Matrix4.diagonal3Values(sx, sy, 1));
    }
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => RubberBandEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Wiggle-and-grow celebration (Animate.css `tada`).
class TadaEffect extends _AttentionEffect {
  const TadaEffect({super.delay, super.duration, super.curve = Curves.linear});

  @override
  void apply(FxAccumulator acc, double t) {
    final s = _kf(t, const [
      [0, 1],
      [0.1, 0.9],
      [0.2, 0.9],
      [0.3, 1.1],
      [0.9, 1.1],
      [1, 1],
    ]);
    final rot = _kf(t, const [
      [0, 0],
      [0.1, -3],
      [0.2, -3],
      [0.3, 3],
      [0.4, -3],
      [0.5, 3],
      [0.6, -3],
      [0.7, 3],
      [0.8, -3],
      [0.9, 3],
      [1, 0],
    ]);
    if (s != 1) acc.transform.multiply(Matrix4.diagonal3Values(s, s, 1));
    if (rot != 0) acc.transform.multiply(Matrix4.rotationZ(_deg2rad(rot)));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => TadaEffect(
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Gentle continuous vertical bob. Designed to loop (pair with `.looping()`);
/// returns to rest at both ends for a seamless cycle.
class FloatEffect extends _AttentionEffect {
  const FloatEffect({
    this.amplitude = 8.0,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  final double amplitude;

  @override
  void apply(FxAccumulator acc, double t) {
    final dy = -math.sin(t * 2 * math.pi) * amplitude;
    if (dy.abs() > 1e-6) {
      acc.transform.multiply(Matrix4.translationValues(0, dy, 0));
    }
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => FloatEffect(
    amplitude: amplitude,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Pulsing glow via an animated [BoxShadow]. Designed to loop; the glow rises
/// and falls to zero across one cycle. Best on widgets with a solid shape.
class GlowEffect extends _AttentionEffect {
  const GlowEffect({
    this.color = const Color(0xFF448AFF),
    this.maxBlur = 24.0,
    this.maxSpread = 2.0,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  final Color color;
  final double maxBlur;
  final double maxSpread;

  @override
  void apply(FxAccumulator acc, double t) {
    final g = (1 - math.cos(t * 2 * math.pi)) / 2; // 0 → 1 → 0
    if (g <= 0.001) return;
    acc.addWrap(
      (child) => DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: color.a * g),
              blurRadius: maxBlur * g,
              spreadRadius: maxSpread * g,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => GlowEffect(
    color: color,
    maxBlur: maxBlur,
    maxSpread: maxSpread,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
