import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';

/// Reveals the child through an expanding circular clip (a "circular reveal").
///
/// At `t = 0` nothing shows; at `t = 1` the whole child is visible.
class CircularRevealEffect extends FxEffect {
  const CircularRevealEffect({
    this.center = Alignment.center,
    super.delay,
    super.duration,
    super.curve,
  });

  /// The origin the reveal grows from.
  final Alignment center;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.addWrap(
      (child) => ClipPath(
        clipper: _CircleRevealClipper(t.clamp(0.0, 1.0), center),
        child: child,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => CircularRevealEffect(
    center: center,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

class _CircleRevealClipper extends CustomClipper<Path> {
  _CircleRevealClipper(this.fraction, this.center);

  final double fraction;
  final Alignment center;

  @override
  Path getClip(Size size) {
    final origin = center.alongSize(size);
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxRadius = 0.0;
    for (final corner in corners) {
      final d = (corner - origin).distance;
      if (d > maxRadius) maxRadius = d;
    }
    return Path()
      ..addOval(Rect.fromCircle(center: origin, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.center != center;
}

/// Reveals the child through a directional rectangular wipe (a "curtain").
class WipeEffect extends FxEffect {
  const WipeEffect({
    this.direction = AxisDirection.right,
    this.fromCenter = false,
    super.delay,
    super.duration,
    super.curve,
  });

  /// The edge the wipe travels from.
  final AxisDirection direction;

  /// When true, the reveal opens outward from the center instead of an edge.
  final bool fromCenter;

  @override
  void apply(FxAccumulator acc, double t) {
    acc.addWrap(
      (child) => ClipRect(
        clipper: _WipeClipper(t.clamp(0.0, 1.0), direction, fromCenter),
        child: child,
      ),
    );
  }

  @override
  FxEffect copyWithTiming({
    Duration? delay,
    Duration? duration,
    Curve? curve,
  }) => WipeEffect(
    direction: direction,
    fromCenter: fromCenter,
    delay: delay ?? this.delay,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );
}

class _WipeClipper extends CustomClipper<Rect> {
  _WipeClipper(this.fraction, this.direction, this.fromCenter);

  final double fraction;
  final AxisDirection direction;
  final bool fromCenter;

  @override
  Rect getClip(Size size) {
    final horizontal =
        direction == AxisDirection.left || direction == AxisDirection.right;
    if (fromCenter) {
      if (horizontal) {
        final w = size.width * fraction;
        return Rect.fromLTWH((size.width - w) / 2, 0, w, size.height);
      }
      final h = size.height * fraction;
      return Rect.fromLTWH(0, (size.height - h) / 2, size.width, h);
    }
    switch (direction) {
      case AxisDirection.right:
        return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
      case AxisDirection.left:
        return Rect.fromLTWH(
          size.width * (1 - fraction),
          0,
          size.width * fraction,
          size.height,
        );
      case AxisDirection.down:
        return Rect.fromLTWH(0, 0, size.width, size.height * fraction);
      case AxisDirection.up:
        return Rect.fromLTWH(
          0,
          size.height * (1 - fraction),
          size.width,
          size.height * fraction,
        );
    }
  }

  @override
  bool shouldReclip(_WipeClipper oldClipper) =>
      oldClipper.fraction != fraction ||
      oldClipper.direction != direction ||
      oldClipper.fromCenter != fromCenter;
}
