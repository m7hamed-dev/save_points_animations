import 'dart:async';

import 'package:flutter/widgets.dart';

/// Swipe [child] horizontally to dismiss it — it fades as it moves, flings
/// away when past [threshold] (or with enough velocity), and springs back
/// otherwise.
///
/// ```dart
/// FxSwipeToDismiss(
///   onDismissed: () => removeItem(),
///   child: const Card(child: ListTile(title: Text('Swipe me away'))),
/// );
/// ```
class FxSwipeToDismiss extends StatefulWidget {
  const FxSwipeToDismiss({
    super.key,
    required this.child,
    this.onDismissed,
    this.threshold = 0.4,
    this.flingVelocity = 700,
  });

  final Widget child;

  /// Called once the child has flung off-screen.
  final VoidCallback? onDismissed;

  /// Fraction of the width past which release dismisses (default 40%).
  final double threshold;

  /// Release speed, in logical pixels/second, above which the child is flung
  /// off regardless of how far it was dragged (default 700).
  final double flingVelocity;

  @override
  State<FxSwipeToDismiss> createState() => _FxSwipeToDismissState();
}

class _FxSwipeToDismissState extends State<FxSwipeToDismiss>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // Drives the moving card without rebuilding widget.child each frame.
  final ValueNotifier<double> _drag = ValueNotifier(0);
  double _width = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  void _onUpdate(DragUpdateDetails details) {
    _controller.stop();
    _drag.value += details.primaryDelta ?? 0;
  }

  void _onEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final fling = velocity.abs() > widget.flingVelocity;
    final past = _drag.value.abs() > _width * widget.threshold || fling;
    if (past) {
      // Prefer the fling direction when a fling is present, otherwise fall
      // back to the drag direction.
      final toLeft = fling ? velocity < 0 : _drag.value < 0;
      _animateTo(
        toLeft ? -_width * 1.2 : _width * 1.2,
        onDone: () {
          if (mounted) widget.onDismissed?.call();
        },
      );
    } else {
      _animateTo(0);
    }
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    final tween = Tween<double>(begin: _drag.value, end: target);
    final anim = tween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    void listener() => _drag.value = anim.value;
    anim.addListener(listener);
    unawaited(
      _controller.forward(from: 0).whenComplete(() {
        anim.removeListener(listener);
        onDone?.call();
      }),
    );
  }

  @override
  void dispose() {
    _drag.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _width = constraints.maxWidth.isFinite ? constraints.maxWidth : 300;
          return Semantics(
            // Lets screen-reader users dismiss without performing the drag.
            onDismiss: widget.onDismissed == null
                ? null
                : () => _animateTo(
                    -_width * 1.2,
                    onDone: () {
                      if (mounted) widget.onDismissed?.call();
                    },
                  ),
            child: GestureDetector(
              onHorizontalDragUpdate: _onUpdate,
              onHorizontalDragEnd: _onEnd,
              child: ValueListenableBuilder<double>(
                valueListenable: _drag,
                child: widget.child,
                builder: (context, drag, child) {
                  final opacity = (1 - (drag.abs() / _width)).clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(drag, 0),
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
