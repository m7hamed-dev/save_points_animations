import 'package:flutter/widgets.dart';

/// A [RectTween] that arcs (rather than moving in a straight line) for more
/// natural Hero flights.
class FxArcRectTween extends RectTween {
  FxArcRectTween({super.begin, super.end});

  @override
  Rect lerp(double t) {
    final base = super.lerp(t);
    if (base == null) return Rect.zero;
    final a = begin;
    final b = end;
    if (a == null || b == null) return base;
    // Arc the center along a sine curve for a gentle curved flight path.
    final lift = (b.center - a.center).distance * 0.15;
    final arc = -lift * (t * (1 - t) * 4); // 0 at ends, peak mid-flight
    return base.shift(Offset(0, arc));
  }
}

/// Hero enhancements.
extension FxHero on Widget {
  /// Wrap this widget in a [Hero] with the given [tag].
  ///
  /// Pair the same [tag] on the source and destination widgets to animate
  /// between them across an [FxPageRoute] (or any route).
  ///
  /// ```dart
  /// Image.asset('a.png').heroAnimate('photo');
  /// ```
  Widget heroAnimate(
    Object tag, {
    bool arc = true,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
  }) {
    return Hero(
      tag: tag,
      createRectTween: arc
          ? (begin, end) => FxArcRectTween(begin: begin, end: end)
          : null,
      flightShuttleBuilder: flightShuttleBuilder,
      child: this,
    );
  }
}
