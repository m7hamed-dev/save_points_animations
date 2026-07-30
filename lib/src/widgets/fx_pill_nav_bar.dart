import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_nav_item.dart';

/// A bottom nav bar where the selected destination expands into a tinted pill
/// that reveals its label beside the icon (the "Salomon" style).
///
/// ```dart
/// FxPillNavBar(
///   items: const [
///     FxNavItem(icon: Icon(Icons.home), label: 'Home'),
///     FxNavItem(icon: Icon(Icons.search), label: 'Search'),
///     FxNavItem(icon: Icon(Icons.person), label: 'Profile'),
///   ],
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// );
/// ```
class FxPillNavBar extends StatelessWidget {
  const FxPillNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.color = const Color(0xFF888888),
    this.selectedColor = const Color(0xFF448AFF),
    this.background = const Color(0xFFFFFFFF),
    this.height = 66,
    this.duration = const Duration(milliseconds: 300),
  });

  final List<FxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color color;
  final Color selectedColor;
  final Color background;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [for (var i = 0; i < items.length; i++) _item(i)],
      ),
    );
  }

  Widget _item(int index) {
    final selected = index == currentIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: items[index].label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.15)
                : const Color(0x00000000),
            borderRadius: .circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme.merge(
                data: IconThemeData(color: selected ? selectedColor : color),
                child: items[index].icon,
              ),
              AnimatedSize(
                duration: duration,
                curve: Curves.easeOut,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          items[index].label,
                          style: TextStyle(
                            color: selectedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
