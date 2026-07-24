import 'package:flutter/widgets.dart';

/// A wrap of selectable filter chips whose fill and text color animate as they
/// toggle. Supports multi-select via the [selected] set.
///
/// ```dart
/// FxTagChips(
///   tags: const ['All', 'Design', 'Code'],
///   selected: _selected,
///   onToggle: (i) => setState(() => _selected.toggle(i)),
/// );
/// ```
class FxTagChips extends StatelessWidget {
  const FxTagChips({
    super.key,
    required this.tags,
    required this.selected,
    required this.onToggle,
    this.color = const Color(0x22448AFF),
    this.selectedColor = const Color(0xFF448AFF),
    this.textColor = const Color(0xFF444444),
    this.selectedTextColor = const Color(0xFFFFFFFF),
    this.spacing = 8,
    this.duration = const Duration(milliseconds: 220),
  });

  final List<String> tags;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final Color color;
  final Color selectedColor;
  final Color textColor;
  final Color selectedTextColor;
  final double spacing;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var i = 0; i < tags.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onToggle(i),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected.contains(i) ? selectedColor : color,
                borderRadius: .circular(20),
              ),
              child: AnimatedDefaultTextStyle(
                duration: duration,
                style: TextStyle(
                  color: selected.contains(i) ? selectedTextColor : textColor,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(tags[i]),
              ),
            ),
          ),
      ],
    );
  }
}
