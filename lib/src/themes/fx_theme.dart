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

/// Package-level default page-transition duration.
const Duration kFxDefaultTransitionDuration = Duration(milliseconds: 350);

/// Package-level default page-transition curve.
const Curve kFxDefaultTransitionCurve = FxCurves.emphasized;

/// Behavior when the platform requests reduced motion.
enum FxReducedMotionBehavior {
  /// Jump straight to the animation's final frame (default).
  jumpToEnd,

  /// Skip the animation entirely, showing the child untouched — no effect is
  /// applied, so an entrance such as `.fade()` never leaves it invisible.
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
    this.transitionCurve = kFxDefaultTransitionCurve,
    this.transitionDuration = kFxDefaultTransitionDuration,
    this.respectReducedMotion = true,
    this.reducedMotionBehavior = FxReducedMotionBehavior.jumpToEnd,
  });

  /// Default easing for `.animate()` **effects**.
  final Curve curve;

  /// Default duration for `.animate()` **effects**.
  final Duration duration;

  /// Default delay for `.animate()` effects.
  final Duration delay;

  /// Default easing for **page transitions** (themed independently of effects).
  final Curve transitionCurve;

  /// Default duration for **page transitions**.
  final Duration transitionDuration;

  final bool respectReducedMotion;
  final FxReducedMotionBehavior reducedMotionBehavior;

  /// Return a copy with the given fields replaced.
  FxThemeData copyWith({
    Duration? duration,
    Curve? curve,
    Duration? delay,
    Curve? transitionCurve,
    Duration? transitionDuration,
    bool? respectReducedMotion,
    FxReducedMotionBehavior? reducedMotionBehavior,
  }) => FxThemeData(
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
    delay: delay ?? this.delay,
    transitionCurve: transitionCurve ?? this.transitionCurve,
    transitionDuration: transitionDuration ?? this.transitionDuration,
    respectReducedMotion: respectReducedMotion ?? this.respectReducedMotion,
    reducedMotionBehavior: reducedMotionBehavior ?? this.reducedMotionBehavior,
  );

  @override
  bool operator ==(Object other) =>
      other is FxThemeData &&
      other.duration == duration &&
      other.curve == curve &&
      other.delay == delay &&
      other.transitionCurve == transitionCurve &&
      other.transitionDuration == transitionDuration &&
      other.respectReducedMotion == respectReducedMotion &&
      other.reducedMotionBehavior == reducedMotionBehavior;

  @override
  int get hashCode => Object.hash(
    duration,
    curve,
    delay,
    transitionCurve,
    transitionDuration,
    respectReducedMotion,
    reducedMotionBehavior,
  );
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
    this.transitionCurve,
    this.transitionDuration,
    this.respectReducedMotion = true,
    this.reducedMotionBehavior = FxReducedMotionBehavior.jumpToEnd,
    required super.child,
  });

  final Duration? duration;
  final Curve? curve;
  final Duration? delay;

  /// Default easing for page transitions (`FxPageRoute` / `context.fxPush`).
  final Curve? transitionCurve;

  /// Default duration for page transitions.
  final Duration? transitionDuration;

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
      transitionCurve: theme?.transitionCurve ?? kFxDefaultTransitionCurve,
      transitionDuration:
          theme?.transitionDuration ?? kFxDefaultTransitionDuration,
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
      transitionCurve != oldWidget.transitionCurve ||
      transitionDuration != oldWidget.transitionDuration ||
      respectReducedMotion != oldWidget.respectReducedMotion ||
      reducedMotionBehavior != oldWidget.reducedMotionBehavior;
}
