import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A radio button whose inner dot scales in and ring tints when selected.
/// While enabled it is keyboard-focusable; Enter / Space select it.
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

  /// Called when this option is tapped. Pass `null` to render a dimmed,
  /// non-interactive radio button.
  final ValueChanged<T>? onChanged;
  final double size;
  final Color color;
  final Color borderColor;
  final Duration duration;

  @override
  State<FxAnimatedRadio<T>> createState() => _FxAnimatedRadioState<T>();
}

class _FxAnimatedRadioState<T> extends State<FxAnimatedRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value == widget.groupValue ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant FxAnimatedRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
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

  void _select() {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    HapticFeedback.lightImpact();
    onChanged(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    return RepaintBoundary(
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: widget.value == widget.groupValue,
        enabled: enabled,
        // Focusable (and Enter / Space select it) only while enabled.
        child: FxFocusableControl(
          enabled: enabled,
          onActivate: _select,
          builder: (context, showFocus) => Opacity(
            opacity: enabled ? 1 : 0.4,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _select : null,
              child: FxFocusRing(
                visible: showFocus,
                color: widget.color,
                circle: true,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _RadioPainter(
                    animation: _controller,
                    color: widget.color,
                    borderColor: widget.borderColor,
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

class _RadioPainter extends CustomPainter {
  _RadioPainter({
    required this.animation,
    required this.color,
    required this.borderColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOut.transform(animation.value);
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
      oldDelegate.color != color || oldDelegate.borderColor != borderColor;
}
