import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A loader of dots that orbit a common center, each pulsing as it travels.
///
/// ```dart
/// const FxOrbitLoader();
/// ```
class FxOrbitLoader extends StatefulWidget {
  const FxOrbitLoader({
    super.key,
    this.size = 48,
    this.dotCount = 3,
    this.dotRadius = 5,
    this.color = const Color(0xFF448AFF),
    this.duration = const Duration(milliseconds: 1200),
  });

  final double size;
  final int dotCount;
  final double dotRadius;
  final Color color;
  final Duration duration;

  @override
  State<FxOrbitLoader> createState() => _FxOrbitLoaderState();
}

class _FxOrbitLoaderState extends State<FxOrbitLoader>
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
    // FxMotionAware only reports reduce-motion *flips*, so start the first
    // loop here once the flag is known.
    if (!_kicked) {
      _kicked = true;
      if (!reduceMotion) _controller.repeat();
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
  void didUpdateWidget(covariant FxOrbitLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (!reduceMotion) _controller.repeat();
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
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _OrbitPainter(
            repaint: _controller,
            controller: _controller,
            dotCount: widget.dotCount,
            dotRadius: widget.dotRadius,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required Listenable repaint,
    required this.controller,
    required this.dotCount,
    required this.dotRadius,
    required this.color,
  }) : _dotPaint = Paint()..color = color,
       super(repaint: repaint);

  final Animation<double> controller;
  final int dotCount;
  final double dotRadius;
  final Color color;

  final Paint _dotPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final t = controller.value;
    final center = size.center(Offset.zero);
    final orbit = size.shortestSide / 2 - dotRadius;
    for (var i = 0; i < dotCount; i++) {
      final angle = t * 2 * math.pi + i * 2 * math.pi / dotCount;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * orbit;
      final scale = 0.5 + 0.5 * ((math.sin(angle) + 1) / 2);
      canvas.drawCircle(pos, dotRadius * scale, _dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.dotCount != dotCount ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.color != color;
}
