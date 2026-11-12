import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/core/fx_motion.dart';

/// A glowing "comet" beam that travels around [child]'s rounded border — the
/// trendy animated-outline accent for cards and inputs.
///
/// ```dart
/// FxBorderBeam(child: const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('New'))));
/// ```
class FxBorderBeam extends StatefulWidget {
  const FxBorderBeam({
    super.key,
    required this.child,
    this.color = const Color(0xFF2575FC),
    this.borderWidth = 2,
    this.borderRadius = 16,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final Color color;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;

  @override
  State<FxBorderBeam> createState() => _FxBorderBeamState();
}

class _FxBorderBeamState extends State<FxBorderBeam>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void didUpdateWidget(covariant FxBorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      // A running repeat keeps its old period until restarted; a
      // controller stopped for reduced motion stays stopped.
      if (_controller.isAnimating) _controller.repeat();
    }
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
      child: CustomPaint(
        painter: _BeamPainter(
          animation: _controller,
          color: widget.color,
          borderWidth: widget.borderWidth,
          borderRadius: widget.borderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.borderWidth),
          child: widget.child,
        ),
      ),
    );
  }
}

class _BeamPainter extends CustomPainter {
  _BeamPainter({
    required this.animation,
    required this.color,
    required this.borderWidth,
    required this.borderRadius,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double borderWidth;
  final double borderRadius;

  // Cached across frames; only the shader is reassigned each paint().
  final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;
    // A short bright band that clamps to transparent everywhere else, rotated
    // around the perimeter over time.
    _paint
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
        stops: const [0.0, 0.06, 0.12],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(rect)
      ..strokeWidth = borderWidth;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, _paint);
  }

  @override
  bool shouldRepaint(_BeamPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderRadius != borderRadius;
}
