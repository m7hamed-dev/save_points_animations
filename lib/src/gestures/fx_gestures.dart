import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Interactive, state-driven gesture animations (distinct from the one-shot
/// timeline effects — these track pointer state continuously).
extension FxGestures on Widget {
  /// Scale down while pressed, springing back on release.
  ///
  /// Even the quickest tap shows the full dip before springing back, and a
  /// finger that moves past the touch slop (to scroll a list the widget sits
  /// in, say) releases it straight away.
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

  /// Where the pressing finger landed, while one is down.
  Offset? _down;

  void _press(PointerDownEvent event) {
    _down = event.position;
    _controller.forward();
  }

  /// A finger that drifts past the touch slop is scrolling or dragging, not
  /// pressing: let go at once.
  void _move(PointerMoveEvent event) {
    final down = _down;
    if (down != null && (event.position - down).distance > kTouchSlop) {
      _cancel();
    }
  }

  /// Lifted: finish the dip first, so even the quickest tap shows it, then
  /// spring back (unless a new press has started meanwhile).
  void _lift(PointerUpEvent event) {
    if (_down == null) return;
    _down = null;
    if (_controller.status == AnimationStatus.forward) {
      _controller.forward().whenCompleteOrCancel(() {
        if (mounted && _down == null) _controller.reverse();
      });
    } else {
      _controller.reverse();
    }
  }

  void _cancel([PointerCancelEvent? event]) {
    _down = null;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // A raw Listener drives the scale so feedback is immediate on pointer
    // down (GestureDetector's tap callbacks are arena-gated). The inner
    // GestureDetector supplies tap semantics for [onTap].
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _press,
      onPointerMove: _move,
      onPointerUp: _lift,
      onPointerCancel: _cancel,
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
