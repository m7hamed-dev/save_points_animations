import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Animates opacity (folded into the single composed opacity multiplier).
class FadeEffect extends FxEffect {
  const FadeEffect({
    this.begin = 0.0,
    this.end = 1.0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double begin;
  final double end;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.opacity *= fxLerp(begin, end, t).clamp(0.0, 1.0);
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => FadeEffect(
    begin: begin,
    end: end,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Animates a gaussian blur on the child (sigma begin → end).
///
/// Defaults to a "blur in" (`begin` sigma → `0`).
class BlurEffect extends FxEffect {
  const BlurEffect({
    this.begin = 8.0,
    this.end = 0.0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double begin;
  final double end;

  @override
  void apply(FxAccumulator acc, double t) {
    final sigma = fxLerp(begin, end, t);
    if (sigma <= 0.01) return;
    acc.addWrap(
      (child) => ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => BlurEffect(
    begin: begin,
    end: end,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Animates a color tint over the child, fading its strength begin → end.
class TintEffect extends FxEffect {
  const TintEffect({
    required this.color,
    this.begin = 1.0,
    this.end = 0.0,
    this.blendMode = BlendMode.srcATop,
    super.delay,
    super.duration,
    super.curve,
  });

  final Color color;
  final double begin;
  final double end;
  final BlendMode blendMode;

  @override
  void apply(FxAccumulator acc, double t) {
    final strength = fxLerp(begin, end, t).clamp(0.0, 1.0);
    if (strength <= 0.001) return;
    acc.addWrap(
      (child) => ColorFiltered(
        colorFilter: ColorFilter.mode(
          color.withValues(alpha: color.a * strength),
          blendMode,
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
  }) => TintEffect(
    color: color,
    begin: begin,
    end: end,
    blendMode: blendMode,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
