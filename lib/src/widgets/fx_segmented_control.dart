import 'package:flutter/widgets.dart';

/// An animated segmented control — a sliding pill glides under the selected
/// segment while the labels cross-fade their color.
///
/// ```dart
/// FxSegmentedControl(
///   segments: const ['Day', 'Week', 'Month'],
///   selectedIndex: _index,
///   onChanged: (i) => setState(() => _index = i),
/// );
/// ```
class FxSegmentedControl extends StatelessWidget {
  const FxSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 40,
    this.selectedColor = const Color(0xFF448AFF),
    this.backgroundColor = const Color(0x22448AFF),
    this.selectedTextColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF555555),
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final Color selectedColor;
  final Color backgroundColor;
  final Color selectedTextColor;
  final Color textColor;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final n = segments.length;
    final alignX = n <= 1 ? 0.0 : -1 + 2 * selectedIndex / (n - 1);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(alignX, 0),
            duration: duration,
            curve: curve,
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        style: TextStyle(
                          color: i == selectedIndex
                              ? selectedTextColor
                              : textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        child: Text(segments[i]),
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
