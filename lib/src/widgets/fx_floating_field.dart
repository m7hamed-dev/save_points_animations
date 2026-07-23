import 'package:flutter/widgets.dart';

/// A text field whose label floats up and shrinks when the field is focused or
/// non-empty, with an underline that animates to the accent colour on focus.
/// Material-free (built on `EditableText`).
///
/// ```dart
/// FxFloatingField(label: 'Email', onChanged: (v) => email = v);
/// ```
class FxFloatingField extends StatefulWidget {
  const FxFloatingField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.accentColor = const Color(0xFF448AFF),
    this.idleColor = const Color(0xFFBDBDBD),
    this.textColor = const Color(0xFF222222),
    this.fontSize = 16,
  });

  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Color accentColor;
  final Color idleColor;
  final Color textColor;
  final double fontSize;

  @override
  State<FxFloatingField> createState() => _FxFloatingFieldState();
}

class _FxFloatingFieldState extends State<FxFloatingField> {
  final FocusNode _focus = FocusNode();
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onChange);
    _controller.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onChange)
      ..dispose();
    _controller.removeListener(_onChange);
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floating = _focus.hasFocus || _controller.text.isNotEmpty;
    final active = _focus.hasFocus;
    return GestureDetector(
      onTap: _focus.requestFocus,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 46,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: 0,
                  top: floating ? 0 : 20,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      fontSize: floating ? 12 : widget.fontSize,
                      color: active ? widget.accentColor : widget.idleColor,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(widget.label),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: EditableText(
                    controller: _controller,
                    focusNode: _focus,
                    obscureText: widget.obscureText,
                    onChanged: widget.onChanged,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.textColor,
                    ),
                    cursorColor: widget.accentColor,
                    backgroundCursorColor: widget.idleColor,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(height: 2, color: widget.idleColor),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                widthFactor: active ? 1 : 0,
                child: Container(height: 2, color: widget.accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
