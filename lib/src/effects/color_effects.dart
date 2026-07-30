import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Luminance coefficients (Rec. 709) used by the color matrices.
const double _lumR = 0.2126;
const double _lumG = 0.7152;
const double _lumB = 0.0722;

/// Animates color saturation. `0` is fully grayscale, `1` is unchanged.
///
/// Use `SaturationEffect(begin: 0, end: 1)` for a grayscale-to-color reveal.
class SaturationEffect extends FxEffect {
  const SaturationEffect({
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
    final s = fxLerp(begin, end, t);
    // Saturation of exactly 1 is the identity matrix; skip the filter layer so
    // a completed animation doesn't leave an extra ColorFiltered render object.
    if ((s - 1.0).abs() < 1e-3) return;
    final sr = (1 - s) * _lumR;
    final sg = (1 - s) * _lumG;
    final sb = (1 - s) * _lumB;
    final matrix = <double>[
      sr + s, sg, sb, 0, 0, //
      sr, sg + s, sb, 0, 0, //
      sr, sg, sb + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
    acc.addWrap(
      (child) =>
          ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => SaturationEffect(
    begin: begin,
    end: end,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Animates brightness. `1` is unchanged, `<1` darker, `>1` brighter.
class BrightnessEffect extends FxEffect {
  const BrightnessEffect({
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
    final b = fxLerp(begin, end, t);
    // Brightness of exactly 1 is the identity matrix; skip the filter layer.
    if ((b - 1.0).abs() < 1e-3) return;
    final matrix = <double>[
      b, 0, 0, 0, 0, //
      0, b, 0, 0, 0, //
      0, 0, b, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
    acc.addWrap(
      (child) =>
          ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => BrightnessEffect(
    begin: begin,
    end: end,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Animates a luminance-preserving hue rotation, in **degrees**.
class HueEffect extends FxEffect {
  const HueEffect({
    this.begin = 0.0,
    this.end = 360.0,
    super.delay,
    super.duration,
    super.curve = Curves.linear,
  });

  final double begin;
  final double end;

  @override
  void apply(FxAccumulator acc, double t) {
    final degrees = fxLerp(begin, end, t);
    // A hue rotation that is a whole multiple of 360° is the identity; skip the
    // filter layer so a completed cycle doesn't leave an extra render object.
    if ((degrees % 360.0).abs() < 1e-3) return;
    final angle = degrees * math.pi / 180.0;
    final c = math.cos(angle);
    final s = math.sin(angle);
    final matrix = <double>[
      _lumR + c * (1 - _lumR) + s * (-_lumR),
      _lumG + c * (-_lumG) + s * (-_lumG),
      _lumB + c * (-_lumB) + s * (1 - _lumB),
      0, 0, //
      _lumR + c * (-_lumR) + s * (0.143),
      _lumG + c * (1 - _lumG) + s * (0.140),
      _lumB + c * (-_lumB) + s * (-0.283),
      0, 0, //
      _lumR + c * (-_lumR) + s * (-(1 - _lumR)),
      _lumG + c * (-_lumG) + s * (_lumG),
      _lumB + c * (1 - _lumB) + s * (_lumB),
      0, 0, //
      0, 0, 0, 1, 0, //
    ];
    acc.addWrap(
      (child) =>
          ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => HueEffect(
    begin: begin,
    end: end,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
