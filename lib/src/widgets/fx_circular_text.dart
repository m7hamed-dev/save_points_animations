import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/core/fx_motion.dart';

/// Lays [text] out around a circle and (optionally) spins it — a rotating seal,
/// badge, or "•  NOW OPEN  •" ring.
///
/// ```dart
/// FxCircularText('• SAVE POINTS • ANIMATIONS ');
/// ```
class FxCircularText extends StatefulWidget {
  const FxCircularText(
    this.text, {
    super.key,
    this.radius = 60,
    this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.spin = true,
    this.spinDuration = const Duration(seconds: 8),
  });

  final String text;
  final double radius;
  final TextStyle style;
  final bool spin;
  final Duration spinDuration;

  @override
  State<FxCircularText> createState() => _FxCircularTextState();
}

class _FxCircularTextState extends State<FxCircularText>
    with SingleTickerProviderStateMixin, FxMotionAware {
  late final AnimationController _controller;
  List<TextPainter> _painters = const [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.spinDuration,
    );
    _buildPainters();
  }

  @override
  void onReduceMotionChanged(bool reduceMotion) {
    if (reduceMotion || !widget.spin) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FxCircularText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spinDuration != widget.spinDuration) {
      _controller.duration = widget.spinDuration;
    }
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _buildPainters();
    }
    if (oldWidget.spin != widget.spin) {
      if (widget.spin && !reduceMotion) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  void _buildPainters() {
    for (final p in _painters) {
      p.dispose();
    }
    _painters = [
      for (final glyph in widget.text.characters)
        TextPainter(
          text: TextSpan(text: glyph, style: widget.style),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
  }

  @override
  void dispose() {
    for (final p in _painters) {
      p.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = (widget.radius + (widget.style.fontSize ?? 14)) * 2;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: dimension,
        child: CustomPaint(
          painter: _CircularTextPainter(
            animation: _controller,
            painters: _painters,
            radius: widget.radius,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}

class _CircularTextPainter extends CustomPainter {
  _CircularTextPainter({
    required this.animation,
    required this.painters,
    required this.radius,
    required this.style,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<TextPainter> painters;
  final double radius;
  final TextStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rotation = animation.value * 2 * math.pi;
    final center = size.center(Offset.zero);
    final n = painters.length;
    if (n == 0) return;
    final step = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * step + rotation;
      final painter = painters[i];
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(angle + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CircularTextPainter oldDelegate) =>
      oldDelegate.painters != painters ||
      oldDelegate.radius != radius ||
      oldDelegate.style != style;
}
