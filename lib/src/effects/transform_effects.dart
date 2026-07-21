import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/effects/fx_effect.dart';

double _deg2rad(double deg) => deg * math.pi / 180.0;

/// Translates the child by an interpolated pixel offset (folded into the
/// shared transform matrix).
class MoveEffect extends FxEffect {
  const MoveEffect({
    this.beginX = 0,
    this.beginY = 0,
    this.endX = 0,
    this.endY = 0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double beginX;
  final double beginY;
  final double endX;
  final double endY;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.transform.multiply(
      Matrix4.translationValues(
        fxLerp(beginX, endX, t),
        fxLerp(beginY, endY, t),
        0,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => MoveEffect(
    beginX: beginX,
    beginY: beginY,
    endX: endX,
    endY: endY,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Scales the child uniformly (or per-axis) about its center.
class ScaleEffect extends FxEffect {
  const ScaleEffect({
    this.begin = 0.0,
    this.end = 1.0,
    this.beginY,
    this.endY,
    super.delay,
    super.duration,
    super.curve,
  });

  final double begin;
  final double end;

  /// Optional independent Y begin/end. When null, uses [begin]/[end].
  final double? beginY;
  final double? endY;

  @override
  void apply(FxAccumulator acc, double t) {
    final sx = fxLerp(begin, end, t);
    final sy = fxLerp(beginY ?? begin, endY ?? end, t);
    acc.transform.multiply(Matrix4.diagonal3Values(sx, sy, 1));
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => ScaleEffect(
    begin: begin,
    end: end,
    beginY: beginY,
    endY: endY,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Rotates the child about the Z axis. Values are in **degrees**.
///
/// Defaults to an "into place" entrance (`begin` degrees → `0`).
class RotateEffect extends FxEffect {
  const RotateEffect({
    this.beginDegrees = 0,
    this.endDegrees = 0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double beginDegrees;
  final double endDegrees;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.transform.multiply(
      Matrix4.rotationZ(_deg2rad(fxLerp(beginDegrees, endDegrees, t))),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => RotateEffect(
    beginDegrees: beginDegrees,
    endDegrees: endDegrees,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Skews the child along X and/or Y. Values are in **degrees**.
class SkewEffect extends FxEffect {
  const SkewEffect({
    this.beginX = 0,
    this.beginY = 0,
    this.endX = 0,
    this.endY = 0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double beginX;
  final double beginY;
  final double endX;
  final double endY;

  @override
  void apply(FxAccumulator acc, double t) {
    final ax = _deg2rad(fxLerp(beginX, endX, t));
    final ay = _deg2rad(fxLerp(beginY, endY, t));
    final m = Matrix4.identity()
      ..setEntry(0, 1, math.tan(ax))
      ..setEntry(1, 0, math.tan(ay));
    acc.transform.multiply(m);
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => SkewEffect(
    beginX: beginX,
    beginY: beginY,
    endX: endX,
    endY: endY,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// 3D flip about the X or Y axis (with a subtle perspective), in **degrees**.
class FlipEffect extends FxEffect {
  const FlipEffect({
    this.horizontal = true,
    this.beginDegrees = 90,
    this.endDegrees = 0,
    super.delay,
    super.duration,
    super.curve,
  });

  /// When true, flips about the Y axis (a horizontal flip); otherwise X.
  final bool horizontal;
  final double beginDegrees;
  final double endDegrees;

  @override
  void apply(FxAccumulator acc, double t) {
    final angle = _deg2rad(fxLerp(beginDegrees, endDegrees, t));
    final m = Matrix4.identity()..setEntry(3, 2, 0.001);
    if (horizontal) {
      m.rotateY(angle);
    } else {
      m.rotateX(angle);
    }
    acc.transform.multiply(m);
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => FlipEffect(
    horizontal: horizontal,
    beginDegrees: beginDegrees,
    endDegrees: endDegrees,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

/// Slides the child by a fraction of its own size (size-relative, ideal for
/// `slideFrom*` entrances). Implemented as a [FractionalTranslation] wrapper.
class SlideEffect extends FxEffect {
  const SlideEffect({
    this.beginX = 0,
    this.beginY = 0,
    this.endX = 0,
    this.endY = 0,
    super.delay,
    super.duration,
    super.curve,
  });

  final double beginX;
  final double beginY;
  final double endX;
  final double endY;

  @override
  void apply(FxAccumulator acc, double t) {
    final dx = fxLerp(beginX, endX, t);
    final dy = fxLerp(beginY, endY, t);
    if (dx == 0 && dy == 0) return;
    acc.addWrap(
      (child) =>
          FractionalTranslation(translation: Offset(dx, dy), child: child),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => SlideEffect(
    beginX: beginX,
    beginY: beginY,
    endX: endX,
    endY: endY,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}
