import 'package:flutter/widgets.dart';

/// An expanding action menu — tap the main button and the [children] fan out
/// (staggered) above it while the main icon rotates.
///
/// ```dart
/// FxSpeedDial(
///   icon: const Icon(Icons.add, color: Colors.white),
///   children: [shareButton, editButton, deleteButton],
/// );
/// ```
class FxSpeedDial extends StatefulWidget {
  const FxSpeedDial({
    super.key,
    required this.icon,
    required this.children,
    this.backgroundColor = const Color(0xFF448AFF),
    this.size = 56,
    this.spacing = 12,
    this.duration = const Duration(milliseconds: 320),
  });

  final Widget icon;

  /// The mini action widgets, ordered nearest-to-main first.
  final List<Widget> children;
  final Color backgroundColor;
  final double size;
  final double spacing;
  final Duration duration;

  @override
  State<FxSpeedDial> createState() => _FxSpeedDialState();
}

class _FxSpeedDialState extends State<FxSpeedDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  void _toggle() {
    if (_controller.isCompleted || _controller.value > 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _staggered(int indexFromBottom) {
    final n = widget.children.length;
    final start = n <= 1 ? 0.0 : (indexFromBottom / n) * 0.5;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      // Top item is furthest from the main button -> largest stagger.
      final fromBottom = widget.children.length - 1 - i;
      final anim = _staggered(fromBottom);
      items.add(
        SizeTransition(
          sizeFactor: anim,
          child: FadeTransition(
            opacity: anim,
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.spacing),
              child: ScaleTransition(scale: anim, child: widget.children[i]),
            ),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ...items,
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: RotationTransition(
                  turns: Tween<double>(
                    begin: 0,
                    end: 0.125,
                  ).animate(_controller),
                  child: widget.icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
