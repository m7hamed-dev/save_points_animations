import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_nav_item.dart';

/// A bottom nav bar with a curved notch that slides to the selected item, whose
/// icon floats in a circle above the dip.
///
/// ```dart
/// FxCurvedNavBar(
///   items: const [
///     FxNavItem(icon: Icon(Icons.home), label: 'Home'),
///     FxNavItem(icon: Icon(Icons.search), label: 'Search'),
///     FxNavItem(icon: Icon(Icons.person), label: 'Profile'),
///   ],
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// );
/// ```
class FxCurvedNavBar extends StatelessWidget {
  const FxCurvedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.color = const Color(0xFFFFFFFF),
    this.buttonColor = const Color(0xFF448AFF),
    this.iconColor = const Color(0xFF888888),
    this.selectedIconColor = const Color(0xFFFFFFFF),
    this.height = 64,
    this.duration = const Duration(milliseconds: 350),
  });

  final List<FxNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color color;
  final Color buttonColor;
  final Color iconColor;
  final Color selectedIconColor;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final itemWidth = width / items.length;
          final targetX = itemWidth * (currentIndex + 0.5);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: targetX),
                  duration: duration,
                  curve: Curves.easeOut,
                  builder: (context, x, _) => RepaintBoundary(
                    child: CustomPaint(
                      painter: _CurvedBarPainter(color: color, notchX: x),
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: targetX),
                duration: duration,
                curve: Curves.easeOut,
                builder: (context, x, _) => Positioned(
                  left: x - 26,
                  bottom: height - 22,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: buttonColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 8),
                      ],
                    ),
                    child: IconTheme.merge(
                      data: IconThemeData(color: selectedIconColor),
                      child: Center(child: items[currentIndex].icon),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: height,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == currentIndex,
                          label: items[i].label,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(i),
                            child: Opacity(
                              opacity: i == currentIndex ? 0 : 1,
                              child: IconTheme.merge(
                                data: IconThemeData(color: iconColor),
                                child: Center(child: items[i].icon),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CurvedBarPainter extends CustomPainter {
  _CurvedBarPainter({required this.color, required this.notchX});

  final Color color;
  final double notchX;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 32.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(notchX - r * 1.2, 0)
      ..cubicTo(notchX - r * 0.6, 0, notchX - r * 0.9, r, notchX, r)
      ..cubicTo(notchX + r * 0.9, r, notchX + r * 0.6, 0, notchX + r * 1.2, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawShadow(path, const Color(0xFF000000), 6, false)
      ..drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CurvedBarPainter oldDelegate) =>
      oldDelegate.notchX != notchX || oldDelegate.color != color;
}
