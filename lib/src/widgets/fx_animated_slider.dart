import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/widgets/fx_focusable.dart';

/// A self-contained slider with an animated thumb that grows and casts a soft
/// glow while dragging, plus a value bubble that floats above it. It is
/// keyboard-focusable; the arrow keys step it by [step].
///
/// ```dart
/// FxAnimatedSlider(value: v, onChanged: (x) => setState(() => v = x));
/// ```
class FxAnimatedSlider extends StatefulWidget {
  const FxAnimatedSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.activeColor = const Color(0xFF448AFF),
    this.trackColor = const Color(0xFFE0E0E0),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.height = 44,
    this.trackHeight = 6,
    this.showBubble = true,
    this.step,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final Color activeColor;
  final Color trackColor;
  final Color thumbColor;
  final double height;
  final double trackHeight;
  final bool showBubble;

  /// Amount to move the value by when a screen reader or keyboard requests an
  /// increase/decrease. Defaults to 10% of the range.
  final double? step;

  @override
  State<FxAnimatedSlider> createState() => _FxAnimatedSliderState();
}

class _FxAnimatedSliderState extends State<FxAnimatedSlider> {
  bool _dragging = false;

  double get _fraction {
    final span = widget.max - widget.min;
    if (span <= 0) return 0;
    return ((widget.value - widget.min) / span).clamp(0.0, 1.0);
  }

  double get _step {
    final span = widget.max - widget.min;
    return widget.step ?? (span == 0 ? 0 : span / 10);
  }

  void _updateFromDx(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    final next = widget.min + fraction * (widget.max - widget.min);
    final step = _step;
    // Tick when crossing a step boundary, so drags feel notched.
    if (step > 0) {
      final before = (widget.value - widget.min) ~/ step;
      final after = (next - widget.min) ~/ step;
      if (before != after) HapticFeedback.selectionClick();
    }
    widget.onChanged(next);
  }

  double _nudged(double delta) =>
      (widget.value + delta).clamp(widget.min, widget.max);

  void _nudge(double delta) {
    final next = _nudged(delta);
    if (next != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(next);
    }
  }

  String _format(double value) =>
      value.toStringAsFixed(widget.max - widget.min <= 1 ? 2 : 0);

  // Arrow keys step exactly like the semantics increase/decrease actions.
  late final Map<Type, Action<Intent>> _keyActions = {
    FxAdjustIntent: CallbackAction<FxAdjustIntent>(
      onInvoke: (intent) {
        _nudge(intent.increase ? _step : -_step);
        return null;
      },
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = _fraction;
        const thumbBase = 18.0;
        final thumbSize = _dragging ? thumbBase + 8 : thumbBase;
        // The thumb's logical center sits exactly on the track point; only the
        // painted position is clamped so it never overflows the box edges.
        final thumbCenter = fraction * width;
        final paintCenter = thumbCenter.clamp(
          thumbSize / 2,
          width - thumbSize / 2,
        );
        final label = _format(widget.value);
        return Semantics(
          slider: true,
          value: label,
          // Screen readers announce the value an increase/decrease would
          // produce; Flutter asserts these accompany `value` and the actions.
          increasedValue: _format(_nudged(_step)),
          decreasedValue: _format(_nudged(-_step)),
          onIncrease: () => _nudge(_step),
          onDecrease: () => _nudge(-_step),
          child: FxFocusableControl(
            enabled: true,
            shortcuts: fxAdjustShortcuts,
            actions: _keyActions,
            builder: (context, showFocus) => RepaintBoundary(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) => setState(() => _dragging = true),
                onHorizontalDragEnd: (_) => setState(() => _dragging = false),
                onHorizontalDragUpdate: (d) =>
                    _updateFromDx(d.localPosition.dx, width),
                onTapDown: (d) => _updateFromDx(d.localPosition.dx, width),
                child: SizedBox(
                  height: widget.height,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Inactive track.
                      Align(
                        child: Container(
                          height: widget.trackHeight,
                          decoration: BoxDecoration(
                            color: widget.trackColor,
                            borderRadius: .circular(widget.trackHeight),
                          ),
                        ),
                      ),
                      // Active track.
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: widget.trackHeight,
                            decoration: BoxDecoration(
                              color: widget.activeColor,
                              borderRadius: .circular(widget.trackHeight),
                            ),
                          ),
                        ),
                      ),
                      // Value bubble (also shown while keyboard-focused, so
                      // arrow-key changes are visible).
                      if (widget.showBubble && (_dragging || showFocus))
                        Positioned(
                          left: (paintCenter - 18).clamp(0.0, width - 36),
                          top: 0,
                          child: _Bubble(
                            color: widget.activeColor,
                            text: label,
                          ),
                        ),
                      // Thumb.
                      Positioned(
                        left: paintCenter - thumbSize / 2,
                        child: FxFocusRing(
                          visible: showFocus,
                          color: widget.activeColor,
                          circle: true,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: widget.thumbColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.activeColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.activeColor.withValues(
                                    alpha: _dragging ? 0.4 : 0.2,
                                  ),
                                  blurRadius: _dragging ? 12 : 4,
                                  spreadRadius: _dragging ? 2 : 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      padding: const EdgeInsets.symmetric(vertical: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: .circular(8)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
