import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _WaveDividerPainter(
            color: widget.color,
            waveHeight: widget.waveHeight,
            waveCount: widget.waveCount,
            phase: _controller.value * 2 * math.pi,
          ),
        ),
      ),
    );
  }
}

class _WaveDividerPainter extends CustomPainter {
  _WaveDividerPainter({
    required this.color,
    required this.waveHeight,
    required this.waveCount,
    required this.phase,
  });

  final Color color;
  final double waveHeight;
  final double waveCount;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
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
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WaveDividerPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.color != color ||
      oldDelegate.waveHeight != waveHeight ||
      oldDelegate.waveCount != waveCount;
}
