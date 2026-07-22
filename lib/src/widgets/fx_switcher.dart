import 'package:flutter/widgets.dart';

/// How [FxSwitcher] animates between two children.
enum FxSwitcherEffect {
  /// Cross-fade.
  fade,

  /// Fade + subtle scale.
  scaleFade,

  /// Fade + slide up.
  slideUp,

  /// Fade + slide in horizontally.
  slideHorizontal,

  /// Fade + slight rotation.
  rotationFade,
}

/// Animates between children when [child] changes — like [AnimatedSwitcher],
/// but with the package's motion presets.
///
/// Give successive children **distinct keys** (e.g. `ValueKey`) so the switcher
/// knows the content changed:
///
/// ```dart
/// FxSwitcher(
///   effect: FxSwitcherEffect.scaleFade,
///   child: _loading
///       ? const CircularProgressIndicator(key: ValueKey('load'))
///       : Text(data, key: ValueKey(data)),
/// );
/// ```
class FxSwitcher extends StatelessWidget {
  const FxSwitcher({
    super.key,
    required this.child,
    this.effect = FxSwitcherEffect.scaleFade,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final FxSwitcherEffect effect;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: alignment,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) =>
          _switcherTransition(effect, child, animation),
      child: child,
    );
  }
}

Widget _switcherTransition(
  FxSwitcherEffect effect,
  Widget child,
  Animation<double> animation,
) {
  switch (effect) {
    case FxSwitcherEffect.fade:
      return FadeTransition(opacity: animation, child: child);

    case FxSwitcherEffect.scaleFade:
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
          child: child,
        ),
      );

    case FxSwitcherEffect.slideUp:
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );

    case FxSwitcherEffect.slideHorizontal:
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );

    case FxSwitcherEffect.rotationFade:
      return FadeTransition(
        opacity: animation,
        child: RotationTransition(
          turns: Tween<double>(begin: -0.03, end: 0).animate(animation),
          child: child,
        ),
      );
  }
}
