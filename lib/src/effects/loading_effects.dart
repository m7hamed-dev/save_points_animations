import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// A moving highlight sweep across the child — the classic loading shimmer.
///
/// Designed to loop (pair with `.looping()`).
class ShimmerEffect extends FxEffect {
  const ShimmerEffect({
    this.color = const Color(0xCCFFFFFF),
    this.bandWidth = 0.25,
    this.angle = 0.2,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  /// The highlight color swept across the child.
  final Color color;

  /// Width of the highlight band as a fraction of the widget.
  final double bandWidth;

  /// Tilt of the sweep in radians (0 == horizontal).
  final double angle;

  @override
  void apply(FxAccumulator acc, double t) {
    // Sweep the highlight center from before the left edge to past the right.
    final center = fxLerp(-bandWidth, 1 + bandWidth, t);
    final s0 = (center - bandWidth).clamp(0.0, 1.0);
    final s1 = center.clamp(0.0, 1.0);
    final s2 = (center + bandWidth).clamp(0.0, 1.0);
    final dir = Offset(math.cos(angle), math.sin(angle));

    acc.addWrap(
      (child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-dir.dx, -dir.dy),
          end: Alignment(dir.dx, dir.dy),
          colors: [
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
          stops: [s0, s1, s2],
        ).createShader(bounds),
        child: child,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => ShimmerEffect(
    color: color,
    bandWidth: bandWidth,
    angle: angle,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// A gentle scale + opacity "breathing" pulse. Returns to rest at both ends,
/// so it loops seamlessly (pair with `.looping()`).
class BreatheEffect extends FxEffect {
  const BreatheEffect({
    this.scaleAmount = 0.04,
    this.opacityDip = 0.25,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  final double scaleAmount;
  final double opacityDip;

  @override
  void apply(FxAccumulator acc, double t) {
    final v = (1 - math.cos(t * 2 * math.pi)) / 2; // 0 → 1 → 0
    final scale = 1 + scaleAmount * v;
    acc.transform.multiply(Matrix4.diagonal3Values(scale, scale, 1));
    acc.opacity *= 1 - opacityDip * v;
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => BreatheEffect(
    scaleAmount: scaleAmount,
    opacityDip: opacityDip,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
