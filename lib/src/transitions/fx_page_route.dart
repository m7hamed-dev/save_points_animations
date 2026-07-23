import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/physics/fx_physics.dart';
import 'package:save_points_animations/src/themes/fx_theme.dart';
import 'package:save_points_animations/src/transitions/fx_page_transition.dart';
import 'package:save_points_animations/src/transitions/fx_transition_builder.dart';

/// A configurable [PageRoute] that animates entry/exit with one of the
/// [FxPageTransition] styles.
///
/// ```dart
/// Navigator.of(context).push(
///   FxPageRoute(builder: (_) => DetailPage(), transition: FxPageTransition.zoom),
/// );
/// ```
class FxPageRoute<T> extends PageRouteBuilder<T> {
  FxPageRoute({
    required WidgetBuilder builder,
    this.transition = FxPageTransition.fade,
    this.slideFrom = AxisDirection.right,
    this.revealAlignment = Alignment.center,
    this.originRect,
    this.curve,
    Duration duration = kFxDefaultTransitionDuration,
    Duration? reverseDuration,
    super.settings,
    super.opaque,
    super.barrierColor,
    super.barrierDismissible,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration ?? duration,
       );

  final FxPageTransition transition;
  final AxisDirection slideFrom;

  /// Origin for [FxPageTransition.circularReveal].
  final Alignment revealAlignment;

  /// Screen-space source rect for [FxPageTransition.containerTransform].
  final Rect? originRect;

  /// Easing for this transition. When null, resolves from
  /// `FxTheme.of(context).transitionCurve`.
  final Curve? curve;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildFxTransition(
      transition: transition,
      slideFrom: slideFrom,
      revealAlignment: revealAlignment,
      originRect: originRect,
      curve: curve ?? FxTheme.of(context).transitionCurve,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Navigator sugar for pushing routes with [FxPageTransition]s.
extension FxNavigator on BuildContext {
  /// Push [page] with an [FxPageTransition].
  ///
  /// When [curve] / [duration] are omitted they resolve from
  /// `FxTheme.of(context).transitionCurve` / `transitionDuration`, so
  /// transitions can be themed independently of effect animations.
  ///
  /// ```dart
  /// context.fxPush(DetailPage(), transition: FxPageTransition.sharedAxisHorizontal);
  /// ```
  Future<T?> fxPush<T>(
    Widget page, {
    FxPageTransition transition = .fade,
    AxisDirection slideFrom = .right,
    Alignment revealAlignment = .center,
    Rect? originRect,
    Curve? curve,
    Duration? duration,
  }) {
    final theme = FxTheme.of(this);
    return Navigator.of(this).push<T>(
      FxPageRoute<T>(
        builder: (_) => page,
        transition: transition,
        slideFrom: slideFrom,
        revealAlignment: revealAlignment,
        originRect: originRect,
        curve: curve ?? theme.transitionCurve,
        duration: duration ?? theme.transitionDuration,
      ),
    );
  }

  /// Push [page] with a circular reveal from [alignment] (e.g. a tap point).
  Future<T?> fxPushReveal<T>(
    Widget page, {
    Alignment alignment = Alignment.center,
    Duration? duration,
  }) => fxPush<T>(
    page,
    transition: .circularReveal,
    revealAlignment: alignment,
    duration: duration,
  );

  /// Push [page] with a container transform expanding from [originRect]
  /// (in global/screen coordinates — e.g. from a tapped card's bounds).
  Future<T?> fxPushFrom<T>(
    Widget page,
    Rect originRect, {
    Duration? duration,
  }) => fxPush<T>(
    page,
    transition: .containerTransform,
    originRect: originRect,
    duration: duration,
  );

  /// Push [page] with a **physically spring-driven** transition.
  ///
  /// The [FxSpringCurve] provides natural overshoot + settle, and its own
  /// settle time becomes the transition duration — so the timing is governed
  /// by the spring, not a fixed number.
  ///
  /// ```dart
  /// context.fxPushSpring(DetailPage(), stiffness: 220, damping: 18);
  /// ```
  Future<T?> fxPushSpring<T>(
    Widget page, {
    FxPageTransition transition = FxPageTransition.slide,
    AxisDirection slideFrom = AxisDirection.right,
    double stiffness = 180,
    double damping = 16,
    double mass = 1,
    double velocity = 0,
  }) {
    final spring = FxSpringCurve(
      stiffness: stiffness,
      damping: damping,
      mass: mass,
      velocity: velocity,
    );
    return fxPush<T>(
      page,
      transition: transition,
      slideFrom: slideFrom,
      curve: spring,
      duration: spring.settleDuration,
    );
  }
}
