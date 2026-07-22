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

  // --- Material 3 "expressive" easing tokens --------------------------------

  /// Material 3 emphasized — the modern default: quick, confident start with a
  /// long, smooth settle. Great for most entrances and transitions.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Emphasized decelerate — for elements **entering** the screen.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// Emphasized accelerate — for elements **leaving** the screen.
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// Standard decelerate — a clean, overshoot-free "ease-out".
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
}
