import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;
    // A short bright band that clamps to transparent everywhere else, rotated
    // around the perimeter over time.
    final shader = SweepGradient(
      colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)],
      stops: const [0.0, 0.06, 0.12],
      transform: GradientRotation(t * 2 * math.pi),
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_BeamPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderRadius != borderRadius;
}
