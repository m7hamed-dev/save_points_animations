import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An animated donut chart whose segments sweep in on build (and re-sweep when
/// the data changes).
///
/// ```dart
/// FxPieChart(values: const [3, 5, 2], colors: const [red, green, blue]);
/// ```
class FxPieChart extends StatefulWidget {
  const FxPieChart({
    super.key,
    required this.values,
    required this.colors,
    this.size = 140,
    this.strokeWidth = 22,
    this.duration = const Duration(milliseconds: 900),
    this.child,
  });

  final List<double> values;
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final Duration duration;

  /// Optional center content (donut hole).
  final Widget? child;

  @override
  State<FxPieChart> createState() => _FxPieChartState();
}

class _FxPieChartState extends State<FxPieChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FxPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.values, widget.values)) {
      _controller.forward(from: 0);
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PiePainter(
                  repaint: _controller,
                  animation: _controller,
                  values: widget.values,
                  colors: widget.colors,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            ),
            ?widget.child,
          ],
        ),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required super.repaint,
    required this.animation,
    required this.values,
    required this.colors,
    required this.strokeWidth,
  });

  final Animation<double> animation;
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    final progress = Curves.easeOutCubic.transform(animation.value);
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final revealed = 2 * math.pi * progress;
    var start = -math.pi / 2;
    var drawn = 0.0;
    for (var i = 0; i < values.length; i++) {
      final full = values[i] / total * 2 * math.pi;
      final remaining = revealed - drawn;
      if (remaining <= 0) break;
      final sweep = math.min(full, remaining);
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
      start += full;
      drawn += full;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      !listEquals(oldDelegate.values, values) ||
      !listEquals(oldDelegate.colors, colors) ||
      oldDelegate.strokeWidth != strokeWidth;
}
