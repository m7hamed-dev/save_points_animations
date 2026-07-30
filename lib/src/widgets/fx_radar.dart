import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

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

class _FxRadarState extends State<FxRadar>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
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
  void didUpdateWidget(covariant FxRadar oldWidget) {
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
       _ringPaint = Paint()
         ..color = color.withValues(alpha: 0.3)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1,
       _edgePaint = Paint()
         ..color = color
         ..strokeWidth = 1.5,
       _sweepPaint = Paint(),
       super(repaint: repaint);

  final Animation<double> _animation;
  final Color color;
  final int rings;

  // Cached paints; only the sweep shader is rebuilt per frame.
  final Paint _ringPaint;
  final Paint _edgePaint;
  final Paint _sweepPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = _animation.value * 2 * math.pi;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    for (var i = 1; i <= rings; i++) {
      canvas.drawCircle(center, radius * i / rings, _ringPaint);
    }
    // Cross hairs.
    canvas
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        _ringPaint,
      )
      ..drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        _ringPaint,
      );

    // Sweeping trail via a rotated sweep gradient.
    _sweepPaint.shader = SweepGradient(
      colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.5)],
      stops: const [0.75, 1],
      transform: GradientRotation(angle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, _sweepPaint);

    // Leading edge line.
    final edge = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawLine(center, edge, _edgePaint);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.rings != rings;
}
