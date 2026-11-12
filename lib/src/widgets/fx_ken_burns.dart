import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A slow, cinematic zoom-and-pan over [child] (the "Ken Burns" effect) — ideal
/// for image backgrounds and hero headers. Ping-pongs for a seamless loop.
///
/// Honors the platform "reduce motion" setting (at mount and when toggled at
/// runtime): the drift stops and [child] is shown unzoomed.
///
/// ```dart
/// FxKenBurns(child: Image.asset('hero.jpg', fit: BoxFit.cover));
/// ```
class FxKenBurns extends StatefulWidget {
  const FxKenBurns({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 12),
    this.maxScale = 1.25,
    this.panX = 0.06,
    this.panY = 0.04,
    this.curve = Curves.easeInOut,
  });

  final Widget child;
  final Duration duration;
  final double maxScale;

  /// Horizontal pan as a fraction of the child's width.
  final double panX;

  /// Vertical pan as a fraction of the child's height.
  final double panY;
  final Curve curve;

  @override
  State<FxKenBurns> createState() => _FxKenBurnsState();
}

class _FxKenBurnsState extends State<FxKenBurns>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FxMotionAware only reports reduce-motion *flips*, so kick off the first
    // run once the flag is known.
    if (!_kicked) {
      _kicked = true;
      if (!reduceMotion) _controller.repeat(reverse: true);
    }
  }

  // Reacting to reduce-motion *changes* (not just once at mount) means toggling
  // the OS setting at runtime stops/resumes the drift immediately.
  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FxKenBurns oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      // A running repeat keeps its old period until restarted.
      if (_controller.isAnimating) _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            // Reduced motion: show the child as-is (no zoom or pan).
            if (reduceMotion) return child!;
            final t = widget.curve.transform(_controller.value);
            final scale = 1 + (widget.maxScale - 1) * t;
            return Transform.scale(
              scale: scale,
              child: FractionalTranslation(
                translation: Offset(
                  widget.panX * (t * 2 - 1),
                  widget.panY * (t * 2 - 1),
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
