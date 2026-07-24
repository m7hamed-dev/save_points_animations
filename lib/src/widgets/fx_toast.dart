import 'package:flutter/widgets.dart';

/// Where an [FxToast] slides in from.
enum FxToastSide { top, bottom }

/// A declarative toast/banner that slides and fades in when [visible] is true
/// and animates back out when it becomes false. It manages no overlay of its
/// own — place it in a `Stack` (typically aligned to the top or bottom) and
/// drive [visible] from your state.
///
/// ```dart
/// Stack(children: [content, FxToast(visible: show, child: Text('Saved'))]);
/// ```
class FxToast extends StatelessWidget {
  const FxToast({
    super.key,
    required this.visible,
    required this.child,
    this.side = FxToastSide.bottom,
    this.background = const Color(0xFF2B2B2B),
    this.textColor = const Color(0xFFFFFFFF),
    this.icon,
    this.margin = const EdgeInsets.all(16),
    this.duration = const Duration(milliseconds: 320),
    this.onTap,
  });

  final bool visible;
  final Widget child;
  final FxToastSide side;
  final Color background;
  final Color textColor;
  final Widget? icon;
  final EdgeInsets margin;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fromTop = side == FxToastSide.top;
    return Align(
      alignment: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : Offset(0, fromTop ? -1.4 : 1.4),
        duration: duration,
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          child: Padding(
            padding: margin,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: .circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(color: textColor, size: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[icon!, const SizedBox(width: 10)],
                        Flexible(child: child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
