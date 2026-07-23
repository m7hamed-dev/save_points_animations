import 'package:flutter/widgets.dart';

/// A horizontally-scrolling strip of day chips. The selected day animates to a
/// filled pill; tapping a day selects it. Purely presentational — you own the
/// [selected] date and the [days] to show.
///
/// ```dart
/// FxDateStrip(
///   days: List.generate(14, (i) => start.add(Duration(days: i))),
///   selected: picked,
///   onChanged: (d) => setState(() => picked = d),
/// );
/// ```
class FxDateStrip extends StatelessWidget {
  const FxDateStrip({
    super.key,
    required this.days,
    required this.selected,
    required this.onChanged,
    this.accent = const Color(0xFF448AFF),
    this.textColor = const Color(0xFF333333),
    this.height = 76,
    this.weekdayLabels = const [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ],
  });

  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;
  final Color accent;
  final Color textColor;
  final double height;
  final List<String> weekdayLabels;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = _sameDay(day, selected);
          // DateTime.weekday is 1..7 (Mon..Sun).
          final label = weekdayLabels[(day.weekday - 1) % weekdayLabels.length];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? accent : const Color(0x00000000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? accent : const Color(0xFFE0E0E0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFFFFFFF)
                          : textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 260),
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFFFFFFFF) : textColor,
                    ),
                    child: Text('${day.day}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
