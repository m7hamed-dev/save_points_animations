import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_nav_item.dart';

/// A floating, frosted-glass bottom nav bar — a blurred translucent pill with a
/// sliding highlight behind the selected item. Place it over content (e.g. in a
/// `Stack` or with a margin) so the blur shows through.
///
/// ```dart
/// FxFrostedNavBar(items: navItems, currentIndex: i, onTap: setIndex);
/// ```
class FxFrostedNavBar extends StatelessWidget {
  const FxFrostedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 64,
    this.tint = const Color(0x66FFFFFF),
    this.highlightColor = const Color(0x33448AFF),
    this.iconColor = const Color(0xFF444444),
    this.selectedIconColor = const Color(0xFF448AFF),
    this.blur = 18,
    this.borderRadius = 32,
    this.duration = const Duration(milliseconds: 280),
  });

  final List<FxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final Color tint;
  final Color highlightColor;
  final Color iconColor;
  final Color selectedIconColor;
  final double blur;
  final double borderRadius;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final n = items.length;
    final alignX = n <= 1 ? 0.0 : -1 + 2 * currentIndex / (n - 1);
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: .circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            height: height,
            color: tint,
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(alignX, 0),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: 1 / n,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: .circular(borderRadius),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == currentIndex,
                          label: items[i].label,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(i),
                            child: Center(
                              child: IconTheme.merge(
                                data: IconThemeData(
                                  color: i == currentIndex
                                      ? selectedIconColor
                                      : iconColor,
                                ),
                                child: items[i].icon,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
