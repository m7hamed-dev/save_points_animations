import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// An animated gradient background whose direction slowly rotates — a modern,
/// living backdrop for hero sections, cards, or splash screens.
///
/// ```dart
/// FxAnimatedGradient(
///   colors: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
///   child: const Center(child: Text('Welcome')),
/// );
/// ```
class FxAnimatedGradient extends StatefulWidget {
  const FxAnimatedGradient({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 6),
    this.child,
  });

  /// The gradient stops to cycle through (2+ colors).
  final List<Color> colors;

  /// Time for one full rotation.
  final Duration duration;
  final Widget? child;

  @override
  State<FxAnimatedGradient> createState() => _FxAnimatedGradientState();
}

class _FxAnimatedGradientState extends State<FxAnimatedGradient>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant FxAnimatedGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      // A running repeat keeps its old period until restarted; a
      // controller stopped for reduced motion stays stopped.
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion) {
      _controller.stop();
    } else {
      _controller.repeat();
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
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final angle = _controller.value * 2 * math.pi;
          final dx = math.cos(angle);
          final dy = math.sin(angle);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment(-dx, -dy),
                end: Alignment(dx, dy),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
