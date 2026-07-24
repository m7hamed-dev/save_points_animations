import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

/// A shimmering skeleton placeholder for loading states.
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: [
///     FxSkeleton.circle(size: 48),
///     const SizedBox(height: 12),
///     const FxSkeleton(width: 200),
///     const SizedBox(height: 8),
///     const FxSkeleton(width: 140),
///   ],
/// );
/// ```
class FxSkeleton extends StatelessWidget {
  /// A rectangular (rounded) block — the default line/box shape.
  const FxSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor = const Color(0xFFE6E6E6),
    this.highlightColor = const Color(0xFFF4F4F4),
  });

  /// A circular avatar placeholder of the given [size].
  const FxSkeleton.circle({
    super.key,
    required double size,
    this.baseColor = const Color(0xFFE6E6E6),
    this.highlightColor = const Color(0xFFF4F4F4),
  }) : width = size,
       height = size,
       borderRadius = size;

  final double? width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: .circular(borderRadius),
      ),
    ).animate().shimmer(color: highlightColor).looping();
  }
}
