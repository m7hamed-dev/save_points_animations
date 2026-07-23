import 'package:flutter/widgets.dart';

/// A compact numeric stepper with `−` / `+` buttons that press in on tap and a
/// value that rolls vertically (up or down) when it changes.
///
/// ```dart
/// FxStepper(value: n, onChanged: (v) => setState(() => n = v));
/// ```
class FxStepper extends StatefulWidget {
  const FxStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.step = 1,
    this.color = const Color(0xFF448AFF),
    this.background = const Color(0xFFF0F3F8),
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final Color color;
  final Color background;

  @override
  State<FxStepper> createState() => _FxStepperState();
}

class _FxStepperState extends State<FxStepper> {
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant FxStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _lastValue = oldWidget.value;
  }

  void _bump(int delta) {
    final next = (widget.value + delta).clamp(widget.min, widget.max);
    if (next != widget.value) widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final goingUp = widget.value >= _lastValue;
    return Container(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: '−',
            color: widget.color,
            enabled: widget.value > widget.min,
            onTap: () => _bump(-widget.step),
          ),
          SizedBox(
            width: 44,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, animation) {
                final offset = goingUp ? 1.0 : -1.0;
                return ClipRect(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, offset),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Text(
                '${widget.value}',
                key: ValueKey<int>(widget.value),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: '+',
            color: widget.color,
            enabled: widget.value < widget.max,
            onTap: () => _bump(widget.step),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatefulWidget {
  const _StepButton({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_StepButton> createState() => _StepButtonState();
}

class _StepButtonState extends State<_StepButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: active ? (_) => setState(() => _down = true) : null,
      onTapUp: active ? (_) => setState(() => _down = false) : null,
      onTapCancel: active ? () => setState(() => _down = false) : null,
      onTap: active ? widget.onTap : null,
      child: AnimatedScale(
        scale: _down ? 0.85 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? widget.color.withValues(alpha: 0.12)
                : const Color(0x11000000),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.icon,
            style: TextStyle(
              color: active ? widget.color : const Color(0xFFBDBDBD),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
