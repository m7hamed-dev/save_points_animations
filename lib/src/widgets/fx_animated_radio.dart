import 'package:flutter/widgets.dart';

/// A radio button whose inner dot scales in and ring tints when selected.
///
/// ```dart
/// FxAnimatedRadio<int>(value: 1, groupValue: _sel, onChanged: (v) => …);
/// ```
class FxAnimatedRadio<T> extends StatefulWidget {
  const FxAnimatedRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.size = 22,
    this.color = const Color(0xFF448AFF),
    this.borderColor = const Color(0xFFBDBDBD),
    this.duration = const Duration(milliseconds: 220),
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T> onChanged;
  final double size;
  final Color color;
  final Color borderColor;
  final Duration duration;

  @override
  State<FxAnimatedRadio<T>> createState() => _FxAnimatedRadioState<T>();
}

class _FxAnimatedRadioState<T> extends State<FxAnimatedRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.value == widget.groupValue ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant FxAnimatedRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.value == widget.groupValue;
    final wasSelected = oldWidget.value == oldWidget.groupValue;
    if (selected != wasSelected) {
      selected ? _controller.forward() : _controller.reverse();
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
      onTap: () => widget.onChanged(widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _RadioPainter(
            t: Curves.easeOut.transform(_controller.value),
            color: widget.color,
            borderColor: widget.borderColor,
          ),
        ),
      ),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({
    required this.t,
    required this.color,
    required this.borderColor,
  });

  final double t;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = Color.lerp(borderColor, color, t)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (t > 0) {
      canvas.drawCircle(center, r * 0.55 * t, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_RadioPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor;
}
