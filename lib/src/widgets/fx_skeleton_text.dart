import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/widgets/fx_skeleton.dart';

/// A multi-line shimmering placeholder paragraph, with a shorter last line.
///
/// ```dart
/// FxSkeletonText(lines: 3);
/// ```
class FxSkeletonText extends StatelessWidget {
  const FxSkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = 8,
    this.lastLineFraction = 0.6,
    this.baseColor = const Color(0xFFE6E6E6),
    this.highlightColor = const Color(0xFFF4F4F4),
  });

  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineFraction;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == lines - 1 ? 0 : spacing),
            child: i == lines - 1 && lines > 1
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: lastLineFraction,
                      child: _line(),
                    ),
                  )
                : _line(),
          ),
      ],
    );
  }

  Widget _line() => FxSkeleton(
    height: lineHeight,
    borderRadius: lineHeight / 2,
    baseColor: baseColor,
    highlightColor: highlightColor,
  );
}
