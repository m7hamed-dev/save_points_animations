import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A single ball bouncing with **squash-and-stretch** — it flattens on impact
/// and stretches as it rises. A characterful alternative to the dot/bar/ring
/// spinners for a small "loading" cue.
///
/// Honors "reduce motion" (rests at the floor) and repaints in isolation.
///
/// ```dart
/// FxBouncingBall(color: Colors.orange);
/// ```
class FxBouncingBall extends StatefulWidget {
  const FxBouncingBall({
    super.key,
    this.color = const Color(0xFF448AFF),
    this.size = 22,
    this.amplitude = 34,
    this.duration = const Duration(milliseconds: 700),
  });

  final Color color;

  /// Ball diameter at rest.
  final double size;

  /// Peak bounce height above the floor.
  final double amplitude;

  /// Time for one full down-up-down bounce.
  final Duration duration;

  @override
  State<FxBouncingBall> createState() => _FxBouncingBallState();
}

class _FxBouncingBallState extends State<FxBouncingBall>
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
  void didUpdateWidget(covariant FxBouncingBall oldWidget) {
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
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size * 1.6, widget.size + widget.amplitude),
        painter: _BallPainter(
          animation: _controller,
          color: widget.color,
          ballSize: widget.size,
          amplitude: widget.amplitude,
        ),
      ),
    );
  }
}

class _BallPainter extends CustomPainter {
  _BallPainter({
    required this.animation,
    required this.color,
    required this.ballSize,
    required this.amplitude,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double ballSize;
  final double amplitude;

  late final Paint _paint = Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    // height ∈ 0..1: 0 at the floor (v=0,1), 1 at the apex (v=0.5).
    final height = math.sin(animation.value * math.pi).abs();
    final impact = 1 - height; // strongest squash at the floor.

    final r = ballSize / 2;
    // Squash near the floor: wider and shorter; slight stretch mid-air.
    final sx = 1 + 0.28 * impact - 0.1 * height;
    final sy = 1 - 0.28 * impact + 0.1 * height;
    final rx = r * sx;
    final ry = r * sy;

    final floorY = size.height - ry;
    final cy = floorY - height * amplitude;
    final cx = size.width / 2;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_BallPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.ballSize != ballSize ||
      oldDelegate.amplitude != amplitude;
}
