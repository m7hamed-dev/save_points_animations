import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A checkbox whose box fills and whose check draws itself in on toggle.
/// While enabled it is keyboard-focusable; Enter / Space toggle it.
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

  /// Called when the box is tapped. Pass `null` to render a dimmed,
  /// non-interactive checkbox.
  final ValueChanged<bool>? onChanged;
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant FxAnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.value != widget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    HapticFeedback.lightImpact();
    onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    return RepaintBoundary(
      child: Semantics(
        checked: widget.value,
        enabled: enabled,
        // Focusable (and Enter / Space toggle it) only while enabled.
        child: FxFocusableControl(
          enabled: enabled,
          onActivate: _toggle,
          builder: (context, showFocus) => Opacity(
            opacity: enabled ? 1 : 0.4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _toggle : null,
              child: FxFocusRing(
                visible: showFocus,
                color: widget.activeColor,
                borderRadius: .circular(widget.size * 0.25),
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _CheckboxPainter(
                    animation: _controller,
                    activeColor: widget.activeColor,
                    borderColor: widget.borderColor,
                    checkColor: widget.checkColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({
    required this.animation,
    required this.activeColor,
    required this.borderColor,
    required this.checkColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color activeColor;
  final Color borderColor;
  final Color checkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOut.transform(animation.value);
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
      oldDelegate.activeColor != activeColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.checkColor != checkColor;
}
