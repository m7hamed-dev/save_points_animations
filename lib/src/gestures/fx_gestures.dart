import 'package:flutter/widgets.dart';

/// Interactive, state-driven gesture animations (distinct from the one-shot
/// timeline effects — these track pointer state continuously).
extension FxGestures on Widget {
  /// Scale down while pressed, springing back on release.
  ///
  /// ```dart
  /// button.pressScale();
  /// ```
  Widget pressScale({
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 120),
    Curve pressCurve = Curves.easeOut,
    Curve releaseCurve = Curves.easeOut,
    VoidCallback? onTap,
  }) => _FxPressable(
    pressedScale: scale,
    pressDuration: duration,
    releaseDuration: duration,
    pressCurve: pressCurve,
    releaseCurve: releaseCurve,
    onTap: onTap,
    child: this,
  );

  /// Dip on press and bounce back with an elastic overshoot on release.
  Widget pressBounce({double scale = 0.9, VoidCallback? onTap}) => _FxPressable(
    pressedScale: scale,
    pressDuration: const Duration(milliseconds: 120),
    releaseDuration: const Duration(milliseconds: 500),
    pressCurve: Curves.easeOut,
    releaseCurve: Curves.elasticOut,
    onTap: onTap,
    child: this,
  );

  /// Grow slightly while hovered (desktop/web).
  Widget hoverScale({
    double scale = 1.05,
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeOut,
  }) => _FxHoverable(
    hoverScale: scale,
    duration: duration,
    curve: curve,
    child: this,
  );
}

class _FxPressable extends StatefulWidget {
  const _FxPressable({
    required this.child,
    required this.pressedScale,
    required this.pressDuration,
    required this.releaseDuration,
    required this.pressCurve,
    required this.releaseCurve,
    this.onTap,
  });

  final Widget child;
  final double pressedScale;
  final Duration pressDuration;
  final Duration releaseDuration;
  final Curve pressCurve;
  final Curve releaseCurve;
  final VoidCallback? onTap;

  @override
  State<_FxPressable> createState() => _FxPressableState();
}

class _FxPressableState extends State<_FxPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.pressDuration,
    reverseDuration: widget.releaseDuration,
  );

  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.pressCurve,
          reverseCurve: widget.releaseCurve,
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A raw Listener drives the scale so feedback is immediate on pointer
    // down (GestureDetector's tap callbacks are arena-gated). The inner
    // GestureDetector supplies tap semantics for [onTap].
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}

class _FxHoverable extends StatefulWidget {
  const _FxHoverable({
    required this.child,
    required this.hoverScale,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final double hoverScale;
  final Duration duration;
  final Curve curve;

  @override
  State<_FxHoverable> createState() => _FxHoverableState();
}

class _FxHoverableState extends State<_FxHoverable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: widget.hoverScale,
  ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
