import 'package:flutter/widgets.dart';

/// A `{start, end}` pair of fractional values (each in `min..max`) chosen with
/// an [FxRangeSlider].
@immutable
class FxRange {
  const FxRange(this.start, this.end);

  final double start;
  final double end;

  FxRange copyWith({double? start, double? end}) =>
      FxRange(start ?? this.start, end ?? this.end);

  @override
  bool operator ==(Object other) =>
      other is FxRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// A dual-thumb range slider. Drag either thumb (they can't cross); the active
/// thumb grows and casts a soft glow while dragging.
///
/// ```dart
/// FxRangeSlider(values: r, onChanged: (v) => setState(() => r = v));
/// ```
class FxRangeSlider extends StatefulWidget {
  const FxRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.activeColor = const Color(0xFF448AFF),
    this.trackColor = const Color(0xFFE0E0E0),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.height = 44,
    this.trackHeight = 6,
  });

  final FxRange values;
  final ValueChanged<FxRange> onChanged;
  final double min;
  final double max;
  final Color activeColor;
  final Color trackColor;
  final Color thumbColor;
  final double height;
  final double trackHeight;

  @override
  State<FxRangeSlider> createState() => _FxRangeSliderState();
}

class _FxRangeSliderState extends State<FxRangeSlider> {
  int? _activeThumb; // 0 = start, 1 = end.

  double _fractionOf(double value) {
    final span = widget.max - widget.min;
    if (span <= 0) return 0;
    return ((value - widget.min) / span).clamp(0.0, 1.0);
  }

  double _valueAt(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    return widget.min + fraction * (widget.max - widget.min);
  }

  void _onStart(double dx, double width) {
    final v = _valueAt(dx, width);
    final dStart = (v - widget.values.start).abs();
    final dEnd = (v - widget.values.end).abs();
    setState(() => _activeThumb = dStart <= dEnd ? 0 : 1);
    _onUpdate(dx, width);
  }

  void _onUpdate(double dx, double width) {
    final v = _valueAt(dx, width);
    if (_activeThumb == 0) {
      widget.onChanged(
        widget.values.copyWith(start: v.clamp(widget.min, widget.values.end)),
      );
    } else if (_activeThumb == 1) {
      widget.onChanged(
        widget.values.copyWith(end: v.clamp(widget.values.start, widget.max)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fStart = _fractionOf(widget.values.start);
        final fEnd = _fractionOf(widget.values.end);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => _onStart(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) => _onUpdate(d.localPosition.dx, width),
          onHorizontalDragEnd: (_) => setState(() => _activeThumb = null),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Align(
                  child: Container(
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: widget.trackColor,
                      borderRadius: .circular(widget.trackHeight),
                    ),
                  ),
                ),
                Positioned(
                  left: fStart * width,
                  width: (fEnd - fStart) * width,
                  child: Container(
                    height: widget.trackHeight,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      borderRadius: .circular(widget.trackHeight),
                    ),
                  ),
                ),
                _thumb(fStart, width, active: _activeThumb == 0),
                _thumb(fEnd, width, active: _activeThumb == 1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _thumb(double fraction, double width, {required bool active}) {
    const base = 18.0;
    final size = active ? base + 8 : base;
    return Positioned(
      left: (fraction * width - size / 2).clamp(0.0, width - size),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.thumbColor,
          shape: BoxShape.circle,
          border: Border.all(color: widget.activeColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: widget.activeColor.withValues(alpha: active ? 0.4 : 0.2),
              blurRadius: active ? 12 : 4,
              spreadRadius: active ? 2 : 0,
            ),
          ],
        ),
      ),
    );
  }
}
