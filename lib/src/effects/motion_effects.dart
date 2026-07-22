import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// A damped horizontal shake. Oscillates and settles to rest as `t → 1`.
class ShakeEffect extends FxEffect {
  const ShakeEffect({
    this.amplitude = 10.0,
    this.count = 3,
    this.horizontal = true,
    super.delay,
    super.duration,
    super.curve,
  });

  /// Peak displacement in logical pixels.
  final double amplitude;

  /// Number of full oscillations across the duration.
  final int count;

  /// Shake horizontally (true) or vertically (false).
  final bool horizontal;

  @override
  void apply(FxAccumulator acc, double t) {
    final offset = math.sin(t * math.pi * 2 * count) * amplitude * (1 - t);
    acc.transform.multiply(
      horizontal
          ? Matrix4.translationValues(offset, 0, 0)
          : Matrix4.translationValues(0, offset, 0),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => ShakeEffect(
    amplitude: amplitude,
    count: count,
    horizontal: horizontal,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// A damped vertical bounce that settles to rest as `t → 1`.
class BounceEffect extends FxEffect {
  const BounceEffect({
    this.amplitude = 20.0,
    this.count = 3,
    super.delay,
    super.duration,
    super.curve,
  });

  final double amplitude;
  final int count;

  @override
  void apply(FxAccumulator acc, double t) {
    final offset = -(math.sin(t * math.pi * count).abs()) * amplitude * (1 - t);
    acc.transform.multiply(Matrix4.translationValues(0, offset, 0));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => BounceEffect(
    amplitude: amplitude,
    count: count,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// A single grow-and-return pulse (scales up to `1 + amount`, then back).
class PulseEffect extends FxEffect {
  const PulseEffect({
    this.amount = 0.1,
    super.delay,
    super.duration,
    super.curve,
  });

  /// Fractional peak growth (0.1 == +10%).
  final double amount;

  @override
  void apply(FxAccumulator acc, double t) {
    final scale = 1 + math.sin(t * math.pi) * amount;
    acc.transform.multiply(Matrix4.diagonal3Values(scale, scale, 1));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => PulseEffect(
    amount: amount,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
