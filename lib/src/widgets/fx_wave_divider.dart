import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A horizontal band with an animated sine-wave top edge — a flowing section
/// divider or header base.
///
/// ```dart
/// FxWaveDivider(color: Colors.blue);
/// ```
class FxWaveDivider extends StatefulWidget {
  const FxWaveDivider({
    super.key,
    this.height = 40,
    this.color = const Color(0xFF2575FC),
    this.waveHeight = 8,
    this.waveCount = 2,
    this.duration = const Duration(seconds: 3),
  });

  final double height;
  final Color color;
  final double waveHeight;

  /// Number of wave crests across the width.
  final double waveCount;
  final Duration duration;

  @override
  State<FxWaveDivider> createState() => _FxWaveDividerState();
}

class _FxWaveDividerState extends State<FxWaveDivider>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WaveDividerPainter(
            repaint: _controller,
            color: widget.color,
            waveHeight: widget.waveHeight,
            waveCount: widget.waveCount,
            controller: _controller,
          ),
        ),
      ),
    );
  }
}

class _WaveDividerPainter extends CustomPainter {
  _WaveDividerPainter({
    required Listenable repaint,
    required this.color,
    required this.waveHeight,
    required this.waveCount,
    required this.controller,
  }) : super(repaint: repaint);

  final Color color;
  final double waveHeight;
  final double waveCount;
  final Animation<double> controller;

  // Cached across frames; only the color is reassigned each paint().
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final phase = controller.value * 2 * math.pi;
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, waveHeight);
    for (var x = 0.0; x <= size.width; x += 2) {
      final y =
          waveHeight +
          math.sin(x / size.width * waveCount * 2 * math.pi + phase) *
              waveHeight;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, _paint..color = color);
  }

  @override
  bool shouldRepaint(_WaveDividerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.waveHeight != waveHeight ||
      oldDelegate.waveCount != waveCount;
}
