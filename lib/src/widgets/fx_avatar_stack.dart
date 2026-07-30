import 'package:flutter/widgets.dart';

/// Overlapping circular avatars that spread apart on hover.
///
/// ```dart
/// FxAvatarStack(avatars: users.map((u) => Image.network(u.photo)).toList());
/// ```
class FxAvatarStack extends StatefulWidget {
  const FxAvatarStack({
    super.key,
    required this.avatars,
    this.size = 40,
    this.overlap = 0.4,
    this.borderColor = const Color(0xFFFFFFFF),
    this.borderWidth = 2,
    this.spreadOnHover = true,
    this.duration = const Duration(milliseconds: 240),
  });

  final List<Widget> avatars;
  final double size;

  /// Fraction each avatar overlaps the previous one (0 = touching edges).
  final double overlap;
  final Color borderColor;
  final double borderWidth;
  final bool spreadOnHover;
  final Duration duration;

  @override
  State<FxAvatarStack> createState() => _FxAvatarStackState();
}

class _FxAvatarStackState extends State<FxAvatarStack> {
  bool _hover = false;
  bool _focused = false;
  bool _tapped = false;

  void _toggleTapped() => setState(() => _tapped = !_tapped);

  @override
  Widget build(BuildContext context) {
    final n = widget.avatars.length;
    final collapsed = widget.size * (1 - widget.overlap);
    // Spread when hovered, focused (keyboard), or tapped — so the interaction
    // is reachable without a pointer/hover.
    final spread = widget.spreadOnHover && (_hover || _focused || _tapped);
    final spacing = spread ? widget.size + 6 : collapsed;
    final width = n == 0 ? 0.0 : widget.size + (n - 1) * spacing;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: GestureDetector(
          onTap: _toggleTapped,
          child: SizedBox(
            width: width,
            height: widget.size,
            child: Stack(
              children: [
                for (var i = 0; i < n; i++)
                  AnimatedPositioned(
                    duration: widget.duration,
                    curve: Curves.easeOut,
                    left: i * spacing,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEEEEEE),
                        border: Border.all(
                          color: widget.borderColor,
                          width: widget.borderWidth,
                        ),
                      ),
                      child: ClipOval(child: widget.avatars[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
