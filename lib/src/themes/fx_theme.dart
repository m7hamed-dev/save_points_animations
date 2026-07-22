import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_curves.dart';

/// Package-level default duration when neither the effect nor an [FxTheme]
/// specifies one.
const Duration kFxDefaultDuration = Duration(milliseconds: 350);

/// Package-level default curve — Material 3 emphasized easing for a modern,
/// confident-in / smooth-settle feel (override per effect or via [FxTheme]).
const Curve kFxDefaultCurve = FxCurves.emphasized;

/// Package-level default delay.
const Duration kFxDefaultDelay = Duration.zero;

/// Behavior when the platform requests reduced motion.
enum FxReducedMotionBehavior {
  /// Jump straight to the animation's final frame (default).
  jumpToEnd,

  /// Skip the animation entirely, showing the child untouched at its start.
  disable,

  /// Ignore the request and play normally.
  play,
}

/// Resolved, non-null animation defaults for a build.
@immutable
class FxThemeData {
  const FxThemeData({
    this.duration = kFxDefaultDuration,
    this.curve = kFxDefaultCurve,
    this.delay = kFxDefaultDelay,
    this.respectReducedMotion = true,
    this.reducedMotionBehavior = FxReducedMotionBehavior.jumpToEnd,
  });

  final Duration duration;
  final Curve curve;
  final Duration delay;
  final bool respectReducedMotion;
  final FxReducedMotionBehavior reducedMotionBehavior;
}

/// Provides global animation defaults to descendant `.animate()` builders.
///
/// Resolution order for any parameter is:
/// **explicit call argument → nearest [FxTheme] → package default.**
///
/// ```dart
/// FxTheme(
///   duration: 300.ms,
///   curve: Curves.easeOut,
///   child: MaterialApp(...),
/// );
/// ```
class FxTheme extends InheritedWidget {
  const FxTheme({
    super.key,
    this.duration,
    this.curve,
    this.delay,
    this.respectReducedMotion = true,
    this.reducedMotionBehavior = FxReducedMotionBehavior.jumpToEnd,
    required super.child,
  });

  final Duration? duration;
  final Curve? curve;
  final Duration? delay;
  final bool respectReducedMotion;
  final FxReducedMotionBehavior reducedMotionBehavior;

  /// The resolved defaults in scope at [context], falling back to package
  /// defaults when no [FxTheme] ancestor exists.
  static FxThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<FxTheme>();
    return FxThemeData(
      duration: theme?.duration ?? kFxDefaultDuration,
      curve: theme?.curve ?? kFxDefaultCurve,
      delay: theme?.delay ?? kFxDefaultDelay,
      respectReducedMotion: theme?.respectReducedMotion ?? true,
      reducedMotionBehavior:
          theme?.reducedMotionBehavior ?? FxReducedMotionBehavior.jumpToEnd,
    );
  }

  @override
  bool updateShouldNotify(FxTheme oldWidget) =>
      duration != oldWidget.duration ||
      curve != oldWidget.curve ||
      delay != oldWidget.delay ||
      respectReducedMotion != oldWidget.respectReducedMotion ||
      reducedMotionBehavior != oldWidget.reducedMotionBehavior;
}
