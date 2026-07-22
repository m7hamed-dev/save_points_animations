import 'package:flutter/widgets.dart';

/// A rolling-digit number display — each digit scrolls vertically to its new
/// value when [value] changes (odometer / slot-machine style).
///
/// ```dart
/// FxOdometer(value: score);
/// ```
class FxOdometer extends StatelessWidget {
  const FxOdometer({
    super.key,
    required this.value,
    this.textStyle = const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  final int value;
  final TextStyle textStyle;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final fontSize = textStyle.fontSize ?? 26;
    final height = fontSize * 1.25;
    final width = fontSize * 0.62;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final ch in value.toString().split(''))
          if (_isDigit(ch))
            _OdometerDigit(
              digit: int.parse(ch),
              height: height,
              width: width,
              style: textStyle,
              duration: duration,
              curve: curve,
            )
          else
            Text(ch, style: textStyle),
      ],
    );
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

class _OdometerDigit extends StatelessWidget {
  const _OdometerDigit({
    required this.digit,
    required this.height,
    required this.width,
    required this.style,
    required this.duration,
    required this.curve,
  });

  final int digit;
  final double height;
  final double width;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: digit.toDouble()),
          duration: duration,
          curve: curve,
          builder: (context, v, child) =>
              Transform.translate(offset: Offset(0, -v * height), child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 10; i++)
                SizedBox(
                  width: width,
                  height: height,
                  child: Center(child: Text('$i', style: style)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
