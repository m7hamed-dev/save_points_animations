import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}
