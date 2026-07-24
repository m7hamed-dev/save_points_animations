import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Wraps [child] in a continuously rotating gradient border — the trendy
/// "glow outline" look for cards, avatars, or inputs.
///
/// ```dart
/// FxGradientBorder(
///   borderRadius: 20,
///   child: const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('AI'))),
/// );
/// ```
class FxGradientBorder extends StatefulWidget {
  const FxGradientBorder({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
      Color(0xFFFF512F),
    ],
    this.borderWidth = 3,
    this.borderRadius = 16,
    this.duration = const Duration(seconds: 3),
  });

  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final double borderRadius;
  final Duration duration;

  @override
  State<FxGradientBorder> createState() => _FxGradientBorderState();
}

class _FxGradientBorderState extends State<FxGradientBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
        painter: _GradientBorderPainter(
          animation: _controller,
          colors: widget.colors,
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

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.animation,
    required this.colors,
    required this.borderWidth,
    required this.borderRadius,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;
  final double borderWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;
    final shader = SweepGradient(
      colors: [...colors, colors.first],
      transform: GradientRotation(t * 2 * math.pi),
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GradientBorderPainter oldDelegate) =>
      oldDelegate.colors != colors ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderRadius != borderRadius;
}
