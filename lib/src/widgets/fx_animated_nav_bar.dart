import 'package:flutter/widgets.dart';

/// A bottom navigation bar with an indicator that glides behind the selected
/// item, which also lifts slightly.
///
/// ```dart
/// FxAnimatedNavBar(
///   items: const [Icon(Icons.home), Icon(Icons.search), Icon(Icons.person)],
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// );
/// ```
class FxAnimatedNavBar extends StatelessWidget {
  const FxAnimatedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 64,
    this.background = const Color(0xFFFFFFFF),
    this.indicatorColor = const Color(0x22448AFF),
    this.duration = const Duration(milliseconds: 300),
  });

  final List<Widget> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final Color background;
  final Color indicatorColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final n = items.length;
    final alignX = n <= 1 ? 0.0 : -1 + 2 * currentIndex / (n - 1);
    final indicator = height * 0.68;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(alignX, 0),
            duration: duration,
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: Center(
                child: Container(
                  width: indicator,
                  height: indicator,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Center(
                        child: AnimatedSlide(
                          offset: Offset(0, i == currentIndex ? -0.12 : 0),
                          duration: duration,
                          curve: Curves.easeOutCubic,
                          child: items[i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
