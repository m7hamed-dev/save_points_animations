import 'package:flutter/widgets.dart';

/// Linear interpolation helper shared by effects.
double fxLerp(double a, double b, double t) => a + (b - a) * t;

/// Piecewise-linear keyframe interpolation. [frames] is an ordered list of
/// `[stop, value]` pairs with `stop` in `0..1`.
double fxKeyframe(double t, List<List<double>> frames) {
  if (t <= frames.first[0]) return frames.first[1];
  if (t >= frames.last[0]) return frames.last[1];
  for (var i = 0; i < frames.length - 1; i++) {
    final a = frames[i];
    final b = frames[i + 1];
    if (t >= a[0] && t <= b[0]) {
      final span = b[0] - a[0];
      final local = span == 0 ? 0.0 : (t - a[0]) / span;
      return a[1] + (b[1] - a[1]) * local;
    }
  }
  return frames.last[1];
}

/// Mutable accumulator that every [FxEffect] contributes to for a single frame.
///
/// The engine collapses all transform-type effects into a single [Matrix4] and
/// all fade-type effects into a single opacity multiplier, so the composed
/// result adds at most one [Transform] and one [Opacity] to the tree (plus one
/// wrapper per genuinely wrapping effect such as blur). See the performance
/// contract in `prompt.enhanced.md` §0.2.
class FxAccumulator {
  /// The composed transform (translate/scale/rotate/skew/flip), about center.
  final Matrix4 transform = Matrix4.identity();

  /// The composed opacity multiplier in `0..1`.
  double opacity = 1.0;

  /// Ordered wrappers for effects that need their own render object
  /// (blur, color filter, fractional slide, …). Applied innermost-first.
  final List<Widget Function(Widget child)> wraps = <Widget Function(Widget)>[];

  /// Register a wrapping effect.
  void addWrap(Widget Function(Widget child) wrap) => wraps.add(wrap);
}

/// Compose a single animated frame: apply the accumulator's wrappers, opacity,
/// and transform over [child] (dropping any that are no-ops at rest).
///
/// Shared by the time-driven [FxEffect] engine and scroll-driven effects.
Widget fxComposeFrame(
  Widget child,
  FxAccumulator acc, {
  bool addRepaintBoundary = true,
}) {
  var built = child;
  for (final wrap in acc.wraps) {
    built = wrap(built);
  }
  if ((acc.opacity - 1.0).abs() > 1e-3) {
    built = Opacity(opacity: acc.opacity.clamp(0.0, 1.0), child: built);
  }
  if (!acc.transform.isIdentity()) {
    built = Transform(
      transform: acc.transform,
      alignment: Alignment.center,
      child: built,
    );
  }
  return addRepaintBoundary ? RepaintBoundary(child: built) : built;
}

/// Base class for every animation effect.
///
/// Effects are **immutable value objects**. They carry optional per-effect
/// timing overrides ([delay], [duration], [curve]); when omitted the engine
/// resolves them from the nearest `FxTheme`, then package defaults.
///
/// The animation value passed to [apply] is already **eased** (the effect's
/// curve has been applied by the engine), so implementations only interpolate
/// their own property between begin and end.
///
/// Create custom effects by extending this class — no package modification
/// required:
///
/// ```dart
/// class SwingEffect extends FxEffect {
///   const SwingEffect({super.delay, super.duration, super.curve});
///
///   @override
///   void apply(FxAccumulator acc, double t) {
///     final angle = math.sin(t * math.pi * 2) * 0.2 * (1 - t);
///     acc.transform.multiply(Matrix4.rotationZ(angle));
///   }
///
///   @override
///   FxEffect copyWithTiming({Duration? delay, Duration? duration, Curve? curve}) =>
///       SwingEffect(
///         delay: delay ?? this.delay,
///         duration: duration ?? this.duration,
///         curve: curve ?? this.curve,
///       );
/// }
/// ```
abstract class FxEffect {
  /// Const base constructor.
  const FxEffect({this.delay, this.duration, this.curve});

  /// Start offset for this effect, relative to the current timeline cursor.
  final Duration? delay;

  /// How long this effect animates. Falls back to theme/default when null.
  final Duration? duration;

  /// The easing curve for this effect. Falls back to theme/default when null.
  final Curve? curve;

  /// Contribute this effect's visual result at eased progress [t] (`0..1`).
  void apply(FxAccumulator acc, double t);

  /// Return a copy with overridden timing. Concrete effects must preserve
  /// their own value fields. Used by fluent `.duration()/.delay()/.curve()`
  /// and by list staggering.
  FxEffect copyWithTiming({Duration? delay, Duration? duration, Curve? curve});
}
