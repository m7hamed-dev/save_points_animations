import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A tiny line chart that draws itself in, with an optional filled area — for
/// dashboards, stats cards, and trends.
///
/// ```dart
/// FxSparkline(values: const [3, 5, 4, 8, 6, 9, 7]);
/// ```
class FxSparkline extends StatefulWidget {
  const FxSparkline({
    super.key,
    required this.values,
    this.color = const Color(0xFF448AFF),
    this.strokeWidth = 2,
    this.fill = true,
    this.height = 60,
    this.duration = const Duration(milliseconds: 900),
  });

  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;
  final double height;
  final Duration duration;

  @override
  State<FxSparkline> createState() => _FxSparklineState();
}

class _FxSparklineState extends State<FxSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FxSparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) _controller.forward(from: 0);
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
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: _SparkPainter(
            repaint: _controller,
            animation: _controller,
            values: widget.values,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            fill: widget.fill,
          ),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required super.repaint,
    required this.animation,
    required this.values,
    required this.color,
    required this.strokeWidth,
    required this.fill,
  });

  final Animation<double> animation;
  final List<double> values;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final progress = Curves.easeOut.transform(animation.value);
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          size.height -
              ((values[i] - minV) / range) * (size.height - strokeWidth) -
              strokeWidth / 2,
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    if (fill) {
      final area = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()..color = color.withValues(alpha: 0.15 * progress),
      );
    }

    final drawn = Path();
    for (final metric in line.computeMetrics()) {
      drawn.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }
    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.fill != fill;
}
