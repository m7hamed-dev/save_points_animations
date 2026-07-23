import 'package:flutter/widgets.dart';

/// An iOS-style scrolling wheel picker. Items curve away with perspective and
/// snap to the center; a highlight band marks the selection.
///
/// ```dart
/// FxWheelPicker(
///   items: const ['Low', 'Medium', 'High'],
///   selectedIndex: level,
///   onChanged: (i) => setState(() => level = i),
/// );
/// ```
class FxWheelPicker extends StatefulWidget {
  const FxWheelPicker({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 160,
    this.itemExtent = 40,
    this.textColor = const Color(0xFF888888),
    this.selectedColor = const Color(0xFF222222),
    this.highlightColor = const Color(0x11448AFF),
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final double itemExtent;
  final Color textColor;
  final Color selectedColor;
  final Color highlightColor;

  @override
  State<FxWheelPicker> createState() => _FxWheelPickerState();
}

class _FxWheelPickerState extends State<FxWheelPicker> {
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.selectedIndex);
  late int _current = widget.selectedIndex;

  @override
  void didUpdateWidget(covariant FxWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _current &&
        widget.selectedIndex != oldWidget.selectedIndex) {
      _current = widget.selectedIndex;
      _controller.animateToItem(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              height: widget.itemExtent,
              decoration: BoxDecoration(
                color: widget.highlightColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: widget.itemExtent,
            perspective: 0.004,
            diameterRatio: 1.4,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              setState(() => _current = i);
              widget.onChanged(i);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, i) {
                final selected = i == _current;
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: selected ? 20 : 17,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? widget.selectedColor : widget.textColor,
                    ),
                    child: Text(widget.items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
