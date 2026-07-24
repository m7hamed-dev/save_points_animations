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
  });

  final Widget child;

  /// Called once the child has flung off-screen.
  final VoidCallback? onDismissed;

  /// Fraction of the width past which release dismisses (default 40%).
  final double threshold;

  @override
  State<FxSwipeToDismiss> createState() => _FxSwipeToDismissState();
}

class _FxSwipeToDismissState extends State<FxSwipeToDismiss>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _drag = 0;
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
    setState(() => _drag += details.primaryDelta ?? 0);
  }

  void _onEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final past =
        _drag.abs() > _width * widget.threshold || velocity.abs() > 700;
    if (past) {
      final toLeft = _drag < 0 || velocity < 0;
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
    final tween = Tween<double>(begin: _drag, end: target);
    final anim = tween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    void listener() => setState(() => _drag = anim.value);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _width = constraints.maxWidth.isFinite ? constraints.maxWidth : 300;
          final opacity = (1 - (_drag.abs() / _width)).clamp(0.0, 1.0);
          return GestureDetector(
            onHorizontalDragUpdate: _onUpdate,
            onHorizontalDragEnd: _onEnd,
            child: Transform.translate(
              offset: Offset(_drag, 0),
              child: Opacity(opacity: opacity, child: widget.child),
            ),
          );
        },
      ),
    );
  }
}
