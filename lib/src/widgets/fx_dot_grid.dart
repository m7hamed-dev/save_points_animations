import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// An animated grid of dots with a wave rippling diagonally across it — a
/// subtle, modern tech backdrop.
///
/// ```dart
/// FxDotGrid(child: const Center(child: Text('Dashboard')));
/// ```
class FxDotGrid extends StatefulWidget {
  const FxDotGrid({
    super.key,
    this.spacing = 26,
    this.dotRadius = 2,
    this.color = const Color(0x33448AFF),
    this.duration = const Duration(seconds: 4),
    this.child,
  });

  final double spacing;
  final double dotRadius;
  final Color color;
  final Duration duration;
  final Widget? child;

  @override
  State<FxDotGrid> createState() => _FxDotGridState();
}

class _FxDotGridState extends State<FxDotGrid>
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
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(
                repaint: _controller,
                spacing: widget.spacing,
                dotRadius: widget.dotRadius,
                color: widget.color,
              ),
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({
    required Animation<double> repaint,
    required this.spacing,
    required this.dotRadius,
    required this.color,
  }) : _animation = repaint,
       super(repaint: repaint);

  final Animation<double> _animation;
  final double spacing;
  final double dotRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = _animation.value * 2 * math.pi;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        final wave =
            (math.sin((x + y) / (spacing * 3) - phase) + 1) / 2; // 0..1
        final r = dotRadius * (0.4 + 0.8 * wave);
        canvas.drawCircle(
          Offset(x, y),
          r,
          Paint()
            ..color = color.withValues(alpha: color.a * (0.4 + 0.6 * wave)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}
