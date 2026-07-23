import 'package:flutter/widgets.dart';

/// A numeric keypad (dial-pad layout) where each key dips and ripples on tap.
/// Emits digits via [onDigit] and the delete key via [onBackspace]. Layout and
/// behaviour only — you hold the entered value.
///
/// ```dart
/// FxNumberPad(onDigit: (d) => append(d), onBackspace: removeLast);
/// ```
class FxNumberPad extends StatelessWidget {
  const FxNumberPad({
    super.key,
    required this.onDigit,
    this.onBackspace,
    this.color = const Color(0xFF222222),
    this.keyColor = const Color(0xFFF0F3F8),
    this.spacing = 14,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback? onBackspace;
  final Color color;
  final Color keyColor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> children) => Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(mainAxisAlignment: .spaceEvenly, children: children),
    );

    Widget digit(int n) => _PadKey(
      color: color,
      keyColor: keyColor,
      onTap: () => onDigit(n),
      child: Text(
        '$n',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit(1), digit(2), digit(3)]),
        row([digit(4), digit(5), digit(6)]),
        row([digit(7), digit(8), digit(9)]),
        row([
          const SizedBox(width: 64),
          digit(0),
          _PadKey(
            color: color,
            keyColor: const Color(0x00000000),
            onTap: onBackspace ?? () {},
            child: Text('⌫', style: TextStyle(fontSize: 22, color: color)),
          ),
        ]),
      ],
    );
  }
}

class _PadKey extends StatefulWidget {
  const _PadKey({
    required this.child,
    required this.onTap,
    required this.color,
    required this.keyColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final Color keyColor;

  @override
  State<_PadKey> createState() => _PadKeyState();
}

class _PadKeyState extends State<_PadKey> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.88 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _down
                ? widget.color.withValues(alpha: 0.12)
                : widget.keyColor,
            shape: BoxShape.circle,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
