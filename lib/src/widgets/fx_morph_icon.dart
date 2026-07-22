import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// An icon that morphs between a hamburger (☰) and a close (✕) as [isOpen]
/// changes — the classic app-bar menu toggle.
///
/// ```dart
/// FxMorphIcon(isOpen: _open, onTap: () => setState(() => _open = !_open));
/// ```
class FxMorphIcon extends StatefulWidget {
  const FxMorphIcon({
    super.key,
    required this.isOpen,
    this.size = 24,
    this.color = const Color(0xFF333333),
    this.strokeWidth = 2,
    this.duration = const Duration(milliseconds: 300),
    this.onTap,
  });

  final bool isOpen;
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  State<FxMorphIcon> createState() => _FxMorphIconState();
}

class _FxMorphIconState extends State<FxMorphIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.isOpen ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant FxMorphIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOpen != widget.isOpen) {
      widget.isOpen ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _MorphIconPainter(
            t: Curves.easeInOut.transform(_controller.value),
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _MorphIconPainter extends CustomPainter {
  _MorphIconPainter({
    required this.t,
    required this.color,
    required this.strokeWidth,
  });

  final double t;
  final Color color;
  final double strokeWidth;

  double _lerp(double a, double b) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final half = w * 0.35;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Top bar -> one diagonal of the X.
    canvas
      ..save()
      ..translate(cx, _lerp(h * 0.28, cy))
      ..rotate(_lerp(0, math.pi / 4))
      ..drawLine(Offset(-half, 0), Offset(half, 0), paint)
      ..restore();

    // Bottom bar -> other diagonal.
    canvas
      ..save()
      ..translate(cx, _lerp(h * 0.72, cy))
      ..rotate(_lerp(0, -math.pi / 4))
      ..drawLine(Offset(-half, 0), Offset(half, 0), paint)
      ..restore();

    // Middle bar fades and shrinks away.
    canvas.drawLine(
      Offset(cx - half, cy),
      Offset(cx + half * (1 - t), cy),
      Paint()
        ..color = color.withValues(alpha: 1 - t)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MorphIconPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
