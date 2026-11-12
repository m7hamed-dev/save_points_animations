import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// A scrolling **ECG / heart-monitor line** — a flat baseline punctuated by a
/// repeating PQRST heartbeat spike that sweeps across, with a glowing dot on
/// the leading edge. A distinctive "alive"/loading indicator for health, audio,
/// or status UIs.
///
/// Honors "reduce motion" (shows a static trace) and repaints in isolation.
///
/// ```dart
/// SizedBox(height: 60, child: FxHeartbeatLine(color: Colors.redAccent));
/// ```
class FxHeartbeatLine extends StatefulWidget {
  const FxHeartbeatLine({
    super.key,
    this.color = const Color(0xFFFF4D6D),
    this.lineWidth = 2.5,
    this.beatsAcross = 2,
    this.duration = const Duration(milliseconds: 1600),
  });

  final Color color;

  /// Stroke width of the trace.
  final double lineWidth;

  /// How many heartbeats are visible across the width at once.
  final double beatsAcross;

  /// Time for the trace to scroll by one beat.
  final Duration duration;

  @override
  State<FxHeartbeatLine> createState() => _FxHeartbeatLineState();
}

class _FxHeartbeatLineState extends State<FxHeartbeatLine>
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
  void didUpdateWidget(covariant FxHeartbeatLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void onReduceMotionChanged(bool reduce) {
    if (reduce) {
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
      child: CustomPaint(
        size: Size.infinite,
        painter: _HeartbeatPainter(
          animation: _controller,
          color: widget.color,
          lineWidth: widget.lineWidth,
          beatsAcross: widget.beatsAcross.clamp(1, 6),
        ),
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  _HeartbeatPainter({
    required this.animation,
    required this.color,
    required this.lineWidth,
    required this.beatsAcross,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double lineWidth;
  final double beatsAcross;

  late final Paint _stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = lineWidth
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  // A sum of narrow gaussians approximating a PQRST complex, p ∈ 0..1.
  double _beat(double p) {
    double bump(double c, double w, double h) =>
        h * math.exp(-((p - c) * (p - c)) / (2 * w * w));
    return bump(0.30, 0.020, 0.18) - // P
        bump(0.44, 0.012, 0.30) + // Q
        bump(0.50, 0.013, 1.00) - // R
        bump(0.56, 0.013, 0.42) + // S
        bump(0.72, 0.035, 0.26); // T
  }

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final amp = size.height * 0.36;
    final phase = animation.value; // 0..1, one beat of travel
    final step = size.width / 160;

    final path = Path();
    var started = false;
    for (double x = 0; x <= size.width; x += step) {
      final pos = x / size.width * beatsAcross + phase;
      final p = pos - pos.floorToDouble();
      final y = mid - _beat(p) * amp;
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, _stroke);

    // Leading pulse dot on the right edge.
    final endPos = beatsAcross + phase;
    final endP = endPos - endPos.floorToDouble();
    final endY = mid - _beat(endP) * amp;
    canvas.drawCircle(
      Offset(size.width, endY),
      lineWidth * 1.8,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HeartbeatPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.lineWidth != lineWidth ||
      oldDelegate.beatsAcross != beatsAcross;
}
