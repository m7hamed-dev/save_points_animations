import 'package:flutter/animation.dart';

/// A curated set of named curves for expressive, consistent motion.
///
/// These wrap standard [Curves] and hand-tuned [Cubic]s so call sites read
/// intent (`FxCurves.snappy`) instead of raw bezier values.
abstract final class FxCurves {
  /// Gentle ease with a soft landing.
  static const Curve soft = Cubic(0.25, 0.1, 0.25, 1.0);

  /// Quick to start, decisive settle — good for UI feedback.
  static const Curve snappy = Cubic(0.4, 0.0, 0.2, 1.0);

  /// Balanced ease-in-out.
  static const Curve smooth = Curves.easeInOut;

  /// Springy overshoot.
  static const Curve spring = Curves.elasticOut;

  /// Classic bounce settle.
  static const Curve bounce = Curves.bounceOut;

  /// Pronounced elastic overshoot.
  static const Curve elastic = Curves.elasticOut;

  /// Fast out, slow in (Material emphasized).
  static const Curve fastOut = Curves.fastOutSlowIn;

  /// Flutter's default motion curve.
  static const Curve flutter = Curves.fastOutSlowIn;

  /// Material standard easing.
  static const Curve material = Cubic(0.4, 0.0, 0.2, 1.0);
}
