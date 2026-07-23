import 'package:flutter/widgets.dart';

/// A text tab bar with an underline indicator that glides to the selected tab.
///
/// ```dart
/// FxAnimatedTabBar(
///   tabs: const ['Overview', 'Activity', 'Settings'],
///   selectedIndex: _tab,
///   onChanged: (i) => setState(() => _tab = i),
/// );
/// ```
class FxAnimatedTabBar extends StatelessWidget {
  const FxAnimatedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.color = const Color(0xFF448AFF),
    this.selectedTextColor = const Color(0xFF448AFF),
    this.textColor = const Color(0xFF777777),
    this.indicatorHeight = 3,
    this.duration = const Duration(milliseconds: 280),
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color color;
  final Color selectedTextColor;
  final Color textColor;
  final double indicatorHeight;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final n = tabs.length;
    final alignX = n <= 1 ? 0.0 : -1 + 2 * selectedIndex / (n - 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < n; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        style: TextStyle(
                          color: i == selectedIndex
                              ? selectedTextColor
                              : textColor,
                          fontWeight: i == selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        child: Text(tabs[i]),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: indicatorHeight,
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
                      color: color,
                      borderRadius: BorderRadius.circular(indicatorHeight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
