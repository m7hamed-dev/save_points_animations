import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// Step a simulation until it reports settled (or a safety cap is hit) and
/// return that time in seconds.
double _settleTime(Simulation sim) {
  const dt = 1 / 300.0;
  var t = 0.0;
  while (t < 8.0 && !sim.isDone(t)) {
    t += dt;
  }
  return t <= 0 ? 1 / 60.0 : t;
}

/// A [Curve] driven by a real spring [SpringSimulation].
///
/// Unlike the fixed [Curves.elasticOut] approximation, this produces motion
/// governed by physical [stiffness], [damping] and [mass] — including natural
/// overshoot and settle. Pair it with an effect via [FxBuilder.spring], which
/// also sets the physically-correct settle duration.
class FxSpringCurve extends Curve {
  FxSpringCurve({
    this.stiffness = 180,
    this.damping = 12,
    this.mass = 1,
    this.velocity = 0,
  }) : _sim = SpringSimulation(
         SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
         0,
         1,
         velocity,
       ) {
    _settle = _settleTime(_sim);
  }

  /// Spring constant (higher = snappier).
  final double stiffness;

  /// Damping coefficient (higher = less bouncy).
  final double damping;

  /// Oscillating mass (higher = slower).
  final double mass;

  /// Initial velocity toward the target.
  final double velocity;

  final SpringSimulation _sim;
  late final double _settle;

  /// The time the spring takes to settle — use it as the effect's duration.
  Duration get settleDuration =>
      Duration(microseconds: (_settle * 1e6).round());

  @override
  double transformInternal(double t) => _sim.x(t * _settle);
}

/// A [Curve] that normalizes any [Simulation] to the `0..1` domain, mapping the
/// simulation's start position to 0 and its settled position to 1.
class _SimulationCurve extends Curve {
  _SimulationCurve(this._sim) {
    _duration = _settleTime(_sim);
    final start = _sim.x(0);
    final end = _sim.x(_duration);
    _start = start;
    _range = end - start;
  }

  final Simulation _sim;
  late final double _duration;
  late final double _start;
  late final double _range;

  @override
  double transformInternal(double t) {
    if (_range.abs() < 1e-9) return t;
    return (_sim.x(t * _duration) - _start) / _range;
  }
}

/// Factory helpers for physics-based [Curve]s.
///
/// ```dart
/// widget.animate().moveY(200).curve(FxPhysics.gravity());
/// ```
abstract final class FxPhysics {
  /// A spring curve (see [FxSpringCurve]).
  static FxSpringCurve spring({
    double stiffness = 180,
    double damping = 12,
    double mass = 1,
    double velocity = 0,
  }) => FxSpringCurve(
    stiffness: stiffness,
    damping: damping,
    mass: mass,
    velocity: velocity,
  );

  /// A constant-acceleration (gravity) fall curve.
  static Curve gravity({double acceleration = 9.8, double velocity = 0}) =>
      _SimulationCurve(GravitySimulation(acceleration, 0, 1, velocity));

  /// A decelerating friction/inertia curve (a flick that slows to rest).
  static Curve friction({double drag = 0.2, double velocity = 1}) =>
      _SimulationCurve(FrictionSimulation(drag, 0, velocity));
}
