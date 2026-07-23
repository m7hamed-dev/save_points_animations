import 'package:flutter/widgets.dart';

/// A custom animated switch — the thumb slides and the track colour morphs.
///
/// ```dart
/// FxAnimatedToggle(value: on, onChanged: (v) => setState(() => on = v));
/// ```
class FxAnimatedToggle extends StatelessWidget {
  const FxAnimatedToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 30,
    this.activeColor = const Color(0xFF448AFF),
    this.inactiveColor = const Color(0xFFBDBDBD),
    this.thumbColor = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 220),
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final inset = height * 0.12;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOut,
        width: width,
        height: height,
        padding: EdgeInsets.all(inset),
        decoration: BoxDecoration(
          color: value ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: AnimatedAlign(
          duration: duration,
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: height - inset * 2,
            height: height - inset * 2,
            decoration: BoxDecoration(
              color: thumbColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
