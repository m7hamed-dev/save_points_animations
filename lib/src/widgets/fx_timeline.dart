import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

/// A vertical timeline — dots joined by a connector line, with each entry's
/// content revealing in, staggered.
///
/// ```dart
/// FxTimeline(items: const [Text('Ordered'), Text('Shipped'), Text('Delivered')]);
/// ```
class FxTimeline extends StatelessWidget {
  const FxTimeline({
    super.key,
    required this.items,
    this.color = const Color(0xFF448AFF),
    this.dotSize = 14,
    this.lineWidth = 2,
    this.spacing = 20,
    this.interval = const Duration(milliseconds: 90),
  });

  final List<Widget> items;
  final Color color;
  final double dotSize;
  final double lineWidth;
  final double spacing;
  final Duration interval;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: dotSize,
                  child: Column(
                    children: [
                      Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < items.length - 1)
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: lineWidth,
                              child: ColoredBox(
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: items[i]
                        .animate()
                        .fadeIn()
                        .slideX(0.12)
                        .delay(interval * i),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
