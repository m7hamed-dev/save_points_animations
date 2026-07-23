import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_nav_item.dart';

/// A minimal bottom nav bar: the selected icon scales up and tints while a dot
/// slides beneath it.
///
/// ```dart
/// FxDotNavBar(items: navItems, currentIndex: i, onTap: setIndex);
/// ```
class FxDotNavBar extends StatelessWidget {
  const FxDotNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.color = const Color(0xFF9E9E9E),
    this.selectedColor = const Color(0xFF448AFF),
    this.background = const Color(0xFFFFFFFF),
    this.height = 64,
    this.duration = const Duration(milliseconds: 280),
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
    final n = items.length;
    final alignX = n <= 1 ? 0.0 : -1 + 2 * currentIndex / (n - 1);
    return Container(
      height: height,
      color: background,
      child: Stack(
        children: [
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Center(
                      child: AnimatedScale(
                        scale: i == currentIndex ? 1.18 : 1,
                        duration: duration,
                        curve: Curves.easeOut,
                        child: IconTheme.merge(
                          data: IconThemeData(
                            color: i == currentIndex ? selectedColor : color,
                          ),
                          child: items[i].icon,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            height: 6,
            child: AnimatedAlign(
              alignment: Alignment(alignX, 0),
              duration: duration,
              curve: Curves.easeOutCubic,
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                child: Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
