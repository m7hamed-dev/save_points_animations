import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A row of dots rippling up and down in a **traveling sine wave** — a calm,
/// continuous loading or "in progress" indicator. Unlike the bouncing dots in
/// `FxDotsLoader`, the motion sweeps smoothly across the row like a wave.
///
/// Honors the platform "reduce motion" setting (the dots rest in a flat line)
/// and repaints in isolation.
///
/// ```dart
/// FxWaveDots(color: Colors.indigo);
/// ```
class FxWaveDots extends StatefulWidget {
  const FxWaveDots({
    super.key,
    this.count = 5,
    this.color = const Color(0xFF448AFF),
    this.dotSize = 10,
    this.spacing = 8,
    this.amplitude = 8,
    this.duration = const Duration(milliseconds: 1200),
  });

  /// Number of dots.
  final int count;
  final Color color;

  /// Diameter of each dot.
  final double dotSize;

  /// Gap between dots.
  final double spacing;

  /// Peak vertical travel, in logical pixels.
  final double amplitude;

  /// Time for the wave to travel across the row once.
  final Duration duration;

  @override
  State<FxWaveDots> createState() => _FxWaveDotsState();
}

class _FxWaveDotsState extends State<FxWaveDots>
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
  void didUpdateWidget(covariant FxWaveDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
      _controller
        ..stop()
        ..value = 0;
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
    final width =
        widget.count * widget.dotSize + (widget.count - 1) * widget.spacing;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, widget.dotSize + widget.amplitude * 2),
        painter: _WaveDotsPainter(
          animation: _controller,
          count: widget.count,
          color: widget.color,
          dotSize: widget.dotSize,
          spacing: widget.spacing,
          amplitude: widget.amplitude,
        ),
      ),
    );
  }
}

class _WaveDotsPainter extends CustomPainter {
  _WaveDotsPainter({
    required this.animation,
    required this.count,
    required this.color,
    required this.dotSize,
    required this.spacing,
    required this.amplitude,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final int count;
  final Color color;
  final double dotSize;
  final double spacing;
  final double amplitude;

  late final Paint _paint = Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = dotSize / 2;
    final midY = size.height / 2;
    final phase = animation.value * 2 * math.pi;
    for (var i = 0; i < count; i++) {
      // Each dot is one step further along the wave.
      final offset = math.sin(phase - i * (math.pi / 3)) * amplitude;
      final cx = radius + i * (dotSize + spacing);
      canvas.drawCircle(Offset(cx, midY + offset), radius, _paint);
    }
  }

  @override
  bool shouldRepaint(_WaveDotsPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.count != count ||
      oldDelegate.dotSize != dotSize ||
      oldDelegate.spacing != spacing ||
      oldDelegate.amplitude != amplitude;
}
