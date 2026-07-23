import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _OrbitPainter(
            t: _controller.value,
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
    required this.t,
    required this.dotCount,
    required this.dotRadius,
    required this.color,
  });

  final double t;
  final int dotCount;
  final double dotRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final orbit = size.shortestSide / 2 - dotRadius;
    for (var i = 0; i < dotCount; i++) {
      final angle = t * 2 * math.pi + i * 2 * math.pi / dotCount;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * orbit;
      final scale = 0.5 + 0.5 * ((math.sin(angle) + 1) / 2);
      canvas.drawCircle(pos, dotRadius * scale, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.dotCount != dotCount ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.color != color;
}
