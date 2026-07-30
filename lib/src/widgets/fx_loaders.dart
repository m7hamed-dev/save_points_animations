import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Three (or more) dots that bounce in sequence.
class FxDotsLoader extends StatefulWidget {
  const FxDotsLoader({
    super.key,
    this.color = const Color(0xFF448AFF),
    this.size = 10,
    this.count = 3,
    this.duration = const Duration(milliseconds: 900),
  });

  final Color color;
  final double size;
  final int count;
  final Duration duration;

  @override
  State<FxDotsLoader> createState() => _FxDotsLoaderState();
}

class _FxDotsLoaderState extends State<FxDotsLoader>
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
  void didUpdateWidget(covariant FxDotsLoader oldWidget) {
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.count; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.size * 0.25),
                  child: Transform.translate(
                    offset: Offset(0, -_bounce(i) * widget.size),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _bounce(int i) {
    final phase = (_controller.value - i / (widget.count * 1.6)) % 1.0;
    return math.max(0, math.sin(phase * math.pi));
  }
}

/// Equalizer-style pulsing bars.
class FxBarsLoader extends StatefulWidget {
  const FxBarsLoader({
    super.key,
    this.color = const Color(0xFF448AFF),
    this.barWidth = 6,
    this.height = 28,
    this.count = 4,
    this.duration = const Duration(milliseconds: 900),
  });

  final Color color;
  final double barWidth;
  final double height;
  final int count;
  final Duration duration;

  @override
  State<FxBarsLoader> createState() => _FxBarsLoaderState();
}

class _FxBarsLoaderState extends State<FxBarsLoader>
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
  void didUpdateWidget(covariant FxBarsLoader oldWidget) {
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SizedBox(
            height: widget.height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.count; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.barWidth * 0.3,
                    ),
                    child: Container(
                      width: widget.barWidth,
                      height: widget.height * _scale(i),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: .circular(widget.barWidth / 2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _scale(int i) {
    final phase = (_controller.value + i / widget.count) % 1.0;
    return 0.3 + 0.7 * (0.5 - 0.5 * math.cos(phase * 2 * math.pi));
  }
}

/// An indeterminate rotating arc (a progress ring).
class FxProgressRing extends StatefulWidget {
  const FxProgressRing({
    super.key,
    this.color = const Color(0xFF448AFF),
    this.size = 32,
    this.strokeWidth = 3,
    this.sweep = 0.75,
    this.duration = const Duration(milliseconds: 1000),
  });

  final Color color;
  final double size;
  final double strokeWidth;

  /// Arc length as a fraction of a full circle.
  final double sweep;
  final Duration duration;

  @override
  State<FxProgressRing> createState() => _FxProgressRingState();
}

class _FxProgressRingState extends State<FxProgressRing>
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
  void didUpdateWidget(covariant FxProgressRing oldWidget) {
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
        child: CustomPaint(
          painter: _RingPainter(
            repaint: _controller,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
            controller: _controller,
            sweep: widget.sweep * 2 * math.pi,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required Listenable repaint,
    required this.color,
    required this.strokeWidth,
    required this.controller,
    required this.sweep,
  }) : _paint = Paint()
         ..color = color
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeWidth = strokeWidth,
       super(repaint: repaint);

  final Color color;
  final double strokeWidth;
  final Animation<double> controller;
  final double sweep;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = controller.value * 2 * math.pi;
    final rect = Offset.zero & size;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      sweep,
      false,
      _paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.sweep != sweep;
}
