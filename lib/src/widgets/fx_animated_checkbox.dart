import 'package:flutter/widgets.dart';

/// A checkbox whose box fills and whose check draws itself in on toggle.
///
/// ```dart
/// FxAnimatedCheckbox(value: on, onChanged: (v) => setState(() => on = v));
/// ```
class FxAnimatedCheckbox extends StatefulWidget {
  const FxAnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    this.activeColor = const Color(0xFF448AFF),
    this.borderColor = const Color(0xFFBDBDBD),
    this.checkColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 280),
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color activeColor;
  final Color borderColor;
  final Color checkColor;
  final Duration duration;

  @override
  State<FxAnimatedCheckbox> createState() => _FxAnimatedCheckboxState();
}

class _FxAnimatedCheckboxState extends State<FxAnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant FxAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
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
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _CheckboxPainter(
            t: Curves.easeOut.transform(_controller.value),
            activeColor: widget.activeColor,
            borderColor: widget.borderColor,
            checkColor: widget.checkColor,
          ),
        ),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({
    required this.t,
    required this.activeColor,
    required this.borderColor,
    required this.checkColor,
  });

  final double t;
  final Color activeColor;
  final Color borderColor;
  final Color checkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.25),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (t > 0) {
      canvas.drawRRect(
        rrect,
        Paint()..color = activeColor.withValues(alpha: t),
      );
    }

    final checkT = ((t - 0.35) / 0.65).clamp(0.0, 1.0);
    if (checkT > 0) {
      final path = Path()
        ..moveTo(size.width * 0.26, size.height * 0.52)
        ..lineTo(size.width * 0.42, size.height * 0.68)
        ..lineTo(size.width * 0.74, size.height * 0.32);
      final drawn = Path();
      for (final metric in path.computeMetrics()) {
        drawn.addPath(
          metric.extractPath(0, metric.length * checkT),
          Offset.zero,
        );
      }
      canvas.drawPath(
        drawn,
        Paint()
          ..color = checkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.checkColor != checkColor;
}
