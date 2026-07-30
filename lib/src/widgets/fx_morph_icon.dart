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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.isOpen ? 1 : 0,
    );
  }

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
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _MorphIconPainter(
            animation: _controller,
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
    required this.animation,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  // Hoisted out of paint() so they aren't reallocated every frame. The bar
  // paint is fully static; only the middle bar's alpha is reassigned per frame.
  late final Paint _barPaint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;
  late final Paint _middlePaint = Paint()
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOut.transform(animation.value);
    double lerp(double a, double b) => a + (b - a) * t;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final half = w * 0.35;

    // Top bar -> one diagonal of the X.
    canvas
      ..save()
      ..translate(cx, lerp(h * 0.28, cy))
      ..rotate(lerp(0, math.pi / 4))
      ..drawLine(Offset(-half, 0), Offset(half, 0), _barPaint)
      ..restore();

    // Bottom bar -> other diagonal.
    canvas
      ..save()
      ..translate(cx, lerp(h * 0.72, cy))
      ..rotate(lerp(0, -math.pi / 4))
      ..drawLine(Offset(-half, 0), Offset(half, 0), _barPaint)
      ..restore();

    // Middle bar fades and shrinks away.
    canvas.drawLine(
      Offset(cx - half, cy),
      Offset(cx + half * (1 - t), cy),
      _middlePaint..color = color.withValues(alpha: 1 - t),
    );
  }

  @override
  bool shouldRepaint(_MorphIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
