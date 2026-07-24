import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A rotating radar / sonar scan — concentric rings with a sweeping trail.
/// Great for "scanning", "searching", or live-tracking states.
///
/// ```dart
/// FxRadar(size: 160, color: Colors.green);
/// ```
class FxRadar extends StatefulWidget {
  const FxRadar({
    super.key,
    this.size = 160,
    this.color = const Color(0xFF43A047),
    this.rings = 3,
    this.duration = const Duration(seconds: 3),
    this.child,
  });

  final double size;
  final Color color;
  final int rings;
  final Duration duration;

  /// Optional content centered inside the radar.
  final Widget? child;

  @override
  State<FxRadar> createState() => _FxRadarState();
}

class _FxRadarState extends State<FxRadar> with SingleTickerProviderStateMixin {
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
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RadarPainter(
                  repaint: _controller,
                  color: widget.color,
                  rings: widget.rings,
                ),
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required Animation<double> repaint,
    required this.color,
    required this.rings,
  }) : _animation = repaint,
       super(repaint: repaint);

  final Animation<double> _animation;
  final Color color;
  final int rings;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = _animation.value * 2 * math.pi;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= rings; i++) {
      canvas.drawCircle(center, radius * i / rings, ringPaint);
    }
    // Cross hairs.
    canvas
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        ringPaint,
      )
      ..drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        ringPaint,
      );

    // Sweeping trail via a rotated sweep gradient.
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.5)],
        stops: const [0.75, 1],
        transform: GradientRotation(angle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweepPaint);

    // Leading edge line.
    final edge = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawLine(
      center,
      edge,
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rings != rings;
}
