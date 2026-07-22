import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_curves.dart';

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

  /// Material 3 fade-through: outgoing fades + scales out, then incoming
  /// fades + scales in.
  fadeThrough,

  /// iOS-style parallax: incoming slides fully in from the right while the
  /// outgoing page parallax-slides partway out to the left.
  cupertino,

  /// Depth: incoming rises + scales up from below while the outgoing page
  /// recedes and fades.
  depth,

  /// Modal sheet: incoming slides up from the bottom; the page behind scales
  /// down slightly.
  sheet,

  /// Circular reveal: the incoming page expands from a growing circle.
  circularReveal,

  /// 3D cube-style rotation between pages.
  cube3D,

  /// Blur cross-fade: incoming sharpens in while outgoing blurs away.
  blur,

  /// Container transform: the incoming page expands from `originRect`
  /// (e.g. a tapped card) into the full screen, with rounded corners easing
  /// out. Falls back to a centered grow when no rect is given.
  containerTransform,

  /// Frosted glass: the incoming page materializes through a blur that peaks
  /// mid-transition and clears.
  glass,
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
    this.revealAlignment = Alignment.center,
    this.originRect,
    this.curve = FxCurves.emphasized,
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

  /// Origin for [FxPageTransition.circularReveal].
  final Alignment revealAlignment;

  /// Screen-space source rect for [FxPageTransition.containerTransform].
  final Rect? originRect;
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
      revealAlignment: revealAlignment,
      originRect: originRect,
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
  Alignment revealAlignment = Alignment.center,
  Rect? originRect,
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

    case FxPageTransition.fadeThrough:
      return _fadeThrough(curve, animation, secondaryAnimation, child);

    case FxPageTransition.cupertino:
      return _cupertino(curve, animation, secondaryAnimation, child);

    case FxPageTransition.depth:
      return _depth(curve, animation, secondaryAnimation, child);

    case FxPageTransition.sheet:
      return _sheet(curve, animation, secondaryAnimation, child);

    case FxPageTransition.circularReveal:
      return _circularReveal(curve, animation, revealAlignment, child);

    case FxPageTransition.cube3D:
      return _cube(curve, animation, secondaryAnimation, child);

    case FxPageTransition.blur:
      return _blur(curve, animation, secondaryAnimation, child);

    case FxPageTransition.containerTransform:
      return _containerTransform(curve, animation, originRect, child);

    case FxPageTransition.glass:
      return _glass(curve, animation, child);
  }
}

Widget _fadeThrough(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final inCurve = Interval(0.35, 1, curve: curve);
  final outCurve = Interval(0, 0.35, curve: curve);

  final incoming = FadeTransition(
    opacity: animation.drive(CurveTween(curve: inCurve)),
    child: ScaleTransition(
      scale: animation.drive(
        Tween<double>(begin: 0.92, end: 1).chain(CurveTween(curve: inCurve)),
      ),
      child: child,
    ),
  );

  return FadeTransition(
    opacity: secondaryAnimation.drive(
      Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: outCurve)),
    ),
    child: ScaleTransition(
      scale: secondaryAnimation.drive(
        Tween<double>(begin: 1, end: 0.92).chain(CurveTween(curve: outCurve)),
      ),
      child: incoming,
    ),
  );
}

Widget _cupertino(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = SlideTransition(
    position: animation.drive(
      Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: curve)),
    ),
    child: child,
  );

  // Dim this page as it recedes under a newer one (native iOS feel).
  final dimmed = Stack(
    fit: StackFit.passthrough,
    children: [
      incoming,
      Positioned.fill(
        child: IgnorePointer(
          child: FadeTransition(
            opacity: secondaryAnimation.drive(
              Tween<double>(
                begin: 0,
                end: 0.12,
              ).chain(CurveTween(curve: curve)),
            ),
            child: const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      ),
    ],
  );

  return SlideTransition(
    position: secondaryAnimation.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0),
      ).chain(CurveTween(curve: curve)),
    ),
    child: dimmed,
  );
}

Widget _depth(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = FadeTransition(
    opacity: animation.drive(CurveTween(curve: curve)),
    child: ScaleTransition(
      scale: animation.drive(
        Tween<double>(begin: 0.85, end: 1).chain(CurveTween(curve: curve)),
      ),
      child: child,
    ),
  );

  return FadeTransition(
    opacity: secondaryAnimation.drive(
      Tween<double>(begin: 1, end: 0).chain(CurveTween(curve: curve)),
    ),
    child: ScaleTransition(
      scale: secondaryAnimation.drive(
        Tween<double>(begin: 1, end: 1.1).chain(CurveTween(curve: curve)),
      ),
      child: incoming,
    ),
  );
}

Widget _sheet(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Incoming sheet slides up with rounded top corners that flatten as it
  // reaches the top (modern iOS 15+ sheet).
  final incoming = AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = curve.transform(animation.value);
      final radius = ui.lerpDouble(28, 0, t)!;
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: curve)),
          ),
          child: child,
        ),
      );
    },
    child: child,
  );

  // Page behind scales down + dims, like a card sliding back in a stack.
  return ScaleTransition(
    scale: secondaryAnimation.drive(
      Tween<double>(begin: 1, end: 0.9).chain(CurveTween(curve: curve)),
    ),
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        incoming,
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: secondaryAnimation.drive(
                Tween<double>(
                  begin: 0,
                  end: 0.18,
                ).chain(CurveTween(curve: curve)),
              ),
              child: const ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _circularReveal(
  Curve curve,
  Animation<double> animation,
  Alignment alignment,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = curve.transform(animation.value);
      return ClipPath(clipper: _PageCircleClipper(t, alignment), child: child);
    },
    child: FadeTransition(opacity: animation, child: child),
  );
}

Widget _containerTransform(
  Curve curve,
  Animation<double> animation,
  Rect? originRect,
  Widget child,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = curve.transform(animation.value);
      return LayoutBuilder(
        builder: (context, constraints) {
          final full = Offset.zero & constraints.biggest;
          final begin =
              originRect ??
              Rect.fromCenter(
                center: full.center,
                width: full.width * 0.35,
                height: full.height * 0.2,
              );
          final rect = Rect.lerp(begin, full, t)!;
          final radius = ui.lerpDouble(24, 0, t)!;
          return Opacity(
            opacity: (t * 2.5).clamp(0.0, 1.0),
            child: ClipPath(clipper: _RectClipper(rect, radius), child: child),
          );
        },
      );
    },
    child: child,
  );
}

Widget _glass(Curve curve, Animation<double> animation, Widget child) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = curve.transform(animation.value);
      final sigma = math.sin(t * math.pi) * 12;
      final content = sigma < 0.1
          ? child!
          : ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            );
      return Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.98 + 0.02 * t, child: content),
      );
    },
    child: child,
  );
}

Widget _cube(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final deg = (1 - curve.transform(animation.value)) * 90;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateY(-deg * math.pi / 180);
      return Transform(
        transform: matrix,
        alignment: Alignment.centerLeft,
        child: child,
      );
    },
    child: child,
  );

  return AnimatedBuilder(
    animation: secondaryAnimation,
    builder: (context, child) {
      final deg = curve.transform(secondaryAnimation.value) * 90;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateY(deg * math.pi / 180);
      return Transform(
        transform: matrix,
        alignment: Alignment.centerRight,
        child: child,
      );
    },
    child: incoming,
  );
}

Widget _blur(
  Curve curve,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final incoming = AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = curve.transform(animation.value);
      final sigma = (1 - t) * 12;
      final content = sigma < 0.1
          ? child!
          : ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: child,
            );
      return Opacity(opacity: t, child: content);
    },
    child: child,
  );

  return AnimatedBuilder(
    animation: secondaryAnimation,
    builder: (context, child) {
      final sigma = curve.transform(secondaryAnimation.value) * 12;
      if (sigma < 0.1) return child!;
      return ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      );
    },
    child: incoming,
  );
}

class _PageCircleClipper extends CustomClipper<Path> {
  _PageCircleClipper(this.fraction, this.alignment);

  final double fraction;
  final Alignment alignment;

  @override
  Path getClip(Size size) {
    final center = alignment.alongSize(size);
    final corners = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    var maxRadius = 0.0;
    for (final corner in corners) {
      final d = (corner - center).distance;
      if (d > maxRadius) maxRadius = d;
    }
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_PageCircleClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.alignment != alignment;
}

class _RectClipper extends CustomClipper<Path> {
  _RectClipper(this.rect, this.radius);

  final Rect rect;
  final double radius;

  @override
  Path getClip(Size size) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

  @override
  bool shouldReclip(_RectClipper oldClipper) =>
      oldClipper.rect != rect || oldClipper.radius != radius;
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
    Alignment revealAlignment = Alignment.center,
    Rect? originRect,
    Curve curve = FxCurves.emphasized,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return Navigator.of(this).push<T>(
      FxPageRoute<T>(
        builder: (_) => page,
        transition: transition,
        slideFrom: slideFrom,
        revealAlignment: revealAlignment,
        originRect: originRect,
        curve: curve,
        duration: duration,
      ),
    );
  }

  /// Push [page] with a circular reveal from [alignment] (e.g. a tap point).
  Future<T?> fxPushReveal<T>(
    Widget page, {
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 450),
  }) => fxPush<T>(
    page,
    transition: FxPageTransition.circularReveal,
    revealAlignment: alignment,
    duration: duration,
  );

  /// Push [page] with a container transform expanding from [originRect]
  /// (in global/screen coordinates — e.g. from a tapped card's bounds).
  Future<T?> fxPushFrom<T>(
    Widget page,
    Rect originRect, {
    Duration duration = const Duration(milliseconds: 450),
  }) => fxPush<T>(
    page,
    transition: FxPageTransition.containerTransform,
    originRect: originRect,
    duration: duration,
  );
}
