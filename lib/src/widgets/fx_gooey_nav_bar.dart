import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_nav_item.dart';

/// A bottom nav bar with a "gooey" blob highlight that stretches as it travels
/// between the selected items, then settles.
///
/// ```dart
/// FxGooeyNavBar(items: navItems, currentIndex: i, onTap: setIndex);
/// ```
class FxGooeyNavBar extends StatefulWidget {
  const FxGooeyNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.color = const Color(0xFF448AFF),
    this.iconColor = const Color(0xFF9E9E9E),
    this.selectedIconColor = const Color(0xFFFFFFFF),
    this.background = const Color(0xFFFFFFFF),
    this.height = 64,
    this.duration = const Duration(milliseconds: 420),
  });

  final List<FxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color color;
  final Color iconColor;
  final Color selectedIconColor;
  final Color background;
  final double height;
  final Duration duration;

  @override
  State<FxGooeyNavBar> createState() => _FxGooeyNavBarState();
}

class _FxGooeyNavBarState extends State<FxGooeyNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  late int _previous = widget.currentIndex;

  @override
  void didUpdateWidget(covariant FxGooeyNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previous = oldWidget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / n;
            const blob = 46.0;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_controller.value);
                final oldX = (_previous + 0.5) * itemWidth;
                final newX = (widget.currentIndex + 0.5) * itemWidth;
                final x = oldX + (newX - oldX) * t;
                // Bulge horizontally at the midpoint of travel.
                final travel = (newX - oldX).abs() / itemWidth;
                final stretch = 1 + math.sin(t * math.pi) * travel * 0.6;
                final w = blob * stretch;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: x - w / 2,
                      top: (widget.height - blob) / 2,
                      child: Container(
                        width: w,
                        height: blob,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: .circular(blob / 2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => widget.onTap(i),
                              child: Center(
                                child: IconTheme.merge(
                                  data: IconThemeData(
                                    color: i == widget.currentIndex
                                        ? widget.selectedIconColor
                                        : widget.iconColor,
                                  ),
                                  child: widget.items[i].icon,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
