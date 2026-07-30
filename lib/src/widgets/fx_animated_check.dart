import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A success indicator that draws a circle then a checkmark stroke-by-stroke.
///
/// ```dart
/// FxAnimatedCheck(color: Colors.green, size: 72);
/// ```
class FxAnimatedCheck extends StatefulWidget {
  const FxAnimatedCheck({
    super.key,
    this.size = 64,
    this.color = const Color(0xFF43A047),
    this.strokeWidth = 4,
    this.autoPlay = true,
    this.play,
    this.duration = const Duration(milliseconds: 700),
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final bool autoPlay;

  /// Optional replay trigger. Each time this flips from `false` to `true` the
  /// draw-in animation restarts from the beginning. Leave `null` to rely on
  /// [autoPlay] alone.
  final bool? play;
  final Duration duration;

  @override
  State<FxAnimatedCheck> createState() => _FxAnimatedCheckState();
}

class _FxAnimatedCheckState extends State<FxAnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
          _controller.value = 1;
        } else {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant FxAnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.play == true && oldWidget.play != true) {
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
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
          painter: _CheckPainter(
            animation: _controller,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = Curves.easeOut.transform(animation.value);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;

    // Circle draws over the first 60% of the animation.
    final circleT = (progress / 0.6).clamp(0.0, 1.0);
    if (circleT > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * circleT,
        false,
        paint,
      );
    }

    // Checkmark draws over the last 40%.
    final checkT = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
    if (checkT > 0) {
      final path = Path()
        ..moveTo(size.width * 0.28, size.height * 0.52)
        ..lineTo(size.width * 0.44, size.height * 0.68)
        ..lineTo(size.width * 0.72, size.height * 0.34);
      final drawn = Path();
      for (final metric in path.computeMetrics()) {
        drawn.addPath(
          metric.extractPath(0, metric.length * checkT),
          Offset.zero,
        );
      }
      canvas.drawPath(drawn, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
