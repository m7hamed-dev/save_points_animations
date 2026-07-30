import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// An animated arc gauge / speedometer that sweeps to [value] (`0..1`) and
/// eases smoothly whenever the value changes.
///
/// ```dart
/// FxGauge(value: 0.72, child: const Text('72%'));
/// ```
class FxGauge extends StatelessWidget {
  const FxGauge({
    super.key,
    required this.value,
    this.size = 140,
    this.strokeWidth = 12,
    this.color = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.startAngle = 3 * math.pi / 4,
    this.sweepAngle = 3 * math.pi / 2,
    this.duration = const Duration(milliseconds: 700),
    this.child,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final double startAngle;
  final double sweepAngle;
  final Duration duration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: SizedBox.square(
        dimension: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value.clamp(0.0, 1.0)),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(
                    value: v,
                    color: color,
                    backgroundColor: backgroundColor,
                    strokeWidth: strokeWidth,
                    startAngle: startAngle,
                    sweepAngle: sweepAngle,
                  ),
                ),
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  final double value;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle;
}
