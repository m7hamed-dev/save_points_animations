import 'package:flutter/widgets.dart';

/// A row of emoji reactions (Facebook-style). The selected reaction pops up
/// larger with its label; the others stay small. Tapping a reaction selects it
/// (tapping the selected one again clears it, emitting `null`).
///
/// ```dart
/// FxReactionBar(
///   reactions: const ['👍', '❤️', '😂', '😮', '😢'],
///   labels: const ['Like', 'Love', 'Haha', 'Wow', 'Sad'],
///   selected: reaction,
///   onChanged: (i) => setState(() => reaction = i),
/// );
/// ```
class FxReactionBar extends StatelessWidget {
  const FxReactionBar({
    super.key,
    required this.reactions,
    required this.onChanged,
    this.labels,
    this.selected,
    this.background = const Color(0xFFFFFFFF),
  });

  final List<String> reactions;
  final ValueChanged<int?> onChanged;
  final List<String>? labels;
  final int? selected;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < reactions.length; i++)
            _Reaction(
              emoji: reactions[i],
              label: labels != null && i < labels!.length ? labels![i] : null,
              isSelected: selected == i,
              onTap: () => onChanged(selected == i ? null : i),
            ),
        ],
      ),
    );
  }
}

class _Reaction extends StatelessWidget {
  const _Reaction({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  final String emoji;
  final String? label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              opacity: isSelected && label != null ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xE6222222),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label ?? '',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            AnimatedScale(
              scale: isSelected ? 1.5 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ],
        ),
      ),
    );
  }
}
