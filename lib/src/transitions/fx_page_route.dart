import 'package:flutter/widgets.dart';

import '../core/fx_curves.dart';

/// The built-in page transition styles.
enum FxPageTransition {
  /// Cross-fade.
  fade,

  /// Fade + subtle scale-up.
  scale,

  /// Fade-through zoom (scale from small).
  zoom,

  /// Full-screen directional slide (see `slideFrom`).
  slide,

  /// Rotate + scale + fade.
  rotation,

  /// Material shared-axis along X (incoming slides in, outgoing slides out).
  sharedAxisHorizontal,

  /// Material shared-axis along Y.
  sharedAxisVertical,
}

Offset _slideBegin(AxisDirection from) {
  switch (from) {
    case AxisDirection.right:
      return const Offset(1, 0);
    case AxisDirection.left:
      return const Offset(-1, 0);
    case AxisDirection.up:
      return const Offset(0, -1);
    case AxisDirection.down:
      return const Offset(0, 1);
  }
}

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
    this.curve = FxCurves.snappy,
    Duration duration = const Duration(milliseconds: 350),
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
  final Curve curve;

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
      curve: curve,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// The raw transition builder — also reusable as a `transitionsBuilder` in a
/// custom [PageRouteBuilder] or `PageTransitionsBuilder`.
Widget buildFxTransition({
  required FxPageTransition transition,
  required AxisDirection slideFrom,
  required Curve curve,
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
}) {
  final opacity = animation.drive(CurveTween(curve: curve));

  switch (transition) {
    case FxPageTransition.fade:
      return FadeTransition(opacity: opacity, child: child);

    case FxPageTransition.scale:
      return FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        ),
      );

    case FxPageTransition.zoom:
      return FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve)),
          ),
          child: child,
        ),
      );

    case FxPageTransition.slide:
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: _slideBegin(slideFrom),
            end: Offset.zero,
          ).chain(CurveTween(curve: curve)),
        ),
        child: child,
      );

    case FxPageTransition.rotation:
      return RotationTransition(
        turns: animation.drive(
          Tween<double>(begin: -0.08, end: 0.0).chain(CurveTween(curve: curve)),
        ),
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.9, end: 1.0).chain(CurveTween(curve: curve)),
          ),
          child: FadeTransition(opacity: opacity, child: child),
        ),
      );

    case FxPageTransition.sharedAxisHorizontal:
      return _sharedAxis(
        Axis.horizontal,
        curve,
        animation,
        secondaryAnimation,
        child,
      );

    case FxPageTransition.sharedAxisVertical:
      return _sharedAxis(
        Axis.vertical,
        curve,
        animation,
        secondaryAnimation,
        child,
      );
  }
}

Widget _sharedAxis(
  Axis axis,
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final enterBegin = axis == Axis.horizontal
      ? const Offset(0.3, 0)
      : const Offset(0, 0.3);
  final exitEnd = axis == Axis.horizontal
      ? const Offset(-0.3, 0)
      : const Offset(0, -0.3);

  final entering = FadeTransition(
    opacity: animation.drive(CurveTween(curve: curve)),
    child: SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: enterBegin,
          end: Offset.zero,
        ).chain(CurveTween(curve: curve)),
      ),
      child: child,
    ),
  );

  // When a newer page pushes on top, slide/fade this one out.
  return SlideTransition(
    position: secondaryAnimation.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: exitEnd,
      ).chain(CurveTween(curve: curve)),
    ),
    child: FadeTransition(
      opacity: secondaryAnimation.drive(
        Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: curve)),
      ),
      child: entering,
    ),
  );
}

/// Navigator sugar for pushing routes with [FxPageTransition]s.
extension FxNavigator on BuildContext {
  /// Push [page] with an [FxPageTransition].
  ///
  /// ```dart
  /// context.fxPush(DetailPage(), transition: FxPageTransition.sharedAxisHorizontal);
  /// ```
  Future<T?> fxPush<T>(
    Widget page, {
    FxPageTransition transition = FxPageTransition.fade,
    AxisDirection slideFrom = AxisDirection.right,
    Curve curve = FxCurves.snappy,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return Navigator.of(this).push<T>(
      FxPageRoute<T>(
        builder: (_) => page,
        transition: transition,
        slideFrom: slideFrom,
        curve: curve,
        duration: duration,
      ),
    );
  }
}
