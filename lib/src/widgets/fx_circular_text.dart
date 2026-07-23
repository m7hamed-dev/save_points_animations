import 'dart:math' as math;

import 'package:flutter/widgets.dart';

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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.spinDuration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.spin) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = (widget.radius + (widget.style.fontSize ?? 14)) * 2;
    return SizedBox.square(
      dimension: dimension,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _CircularTextPainter(
            text: widget.text,
            radius: widget.radius,
            style: widget.style,
            rotation: _controller.value * 2 * math.pi,
          ),
        ),
      ),
    );
  }
}

class _CircularTextPainter extends CustomPainter {
  _CircularTextPainter({
    required this.text,
    required this.radius,
    required this.style,
    required this.rotation,
  });

  final String text;
  final double radius;
  final TextStyle style;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final n = text.length;
    if (n == 0) return;
    final step = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * step + rotation;
      final painter = TextPainter(
        text: TextSpan(text: text[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
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
      oldDelegate.rotation != rotation ||
      oldDelegate.text != text ||
      oldDelegate.radius != radius;
}
