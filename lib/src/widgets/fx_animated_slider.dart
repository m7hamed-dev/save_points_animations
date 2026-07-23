import 'package:flutter/widgets.dart';

/// A self-contained slider with an animated thumb that grows and casts a soft
/// glow while dragging, plus a value bubble that floats above it.
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

  void _updateFromDx(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    widget.onChanged(widget.min + fraction * (widget.max - widget.min));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = _fraction;
        const thumbBase = 18.0;
        final thumbSize = _dragging ? thumbBase + 8 : thumbBase;
        final thumbCenter = fraction * width;
        return GestureDetector(
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
                      borderRadius: BorderRadius.circular(widget.trackHeight),
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
                        borderRadius: BorderRadius.circular(widget.trackHeight),
                      ),
                    ),
                  ),
                ),
                // Value bubble.
                if (widget.showBubble && _dragging)
                  Positioned(
                    left: (thumbCenter - 18).clamp(0.0, width - 36),
                    top: 0,
                    child: _Bubble(
                      color: widget.activeColor,
                      text: widget.value.toStringAsFixed(
                        widget.max - widget.min <= 1 ? 2 : 0,
                      ),
                    ),
                  ),
                // Thumb.
                Positioned(
                  left: (thumbCenter - thumbSize / 2).clamp(
                    0.0,
                    width - thumbSize,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.activeColor, width: 3),
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
              ],
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
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
