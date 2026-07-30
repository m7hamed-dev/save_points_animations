import 'dart:async';

import 'package:flutter/widgets.dart';

/// A swipeable card deck (Tinder-style) — drag the top card away and the next
/// scales up into place.
///
/// ```dart
/// FxSwipeCards(
///   cards: profiles.map((p) => ProfileCard(p)).toList(),
///   onSwiped: (index, toRight) => record(index, toRight),
/// );
/// ```
class FxSwipeCards extends StatefulWidget {
  const FxSwipeCards({
    super.key,
    required this.cards,
    this.onSwiped,
    this.threshold = 0.32,
    this.flingVelocity = 700,
  });

  final List<Widget> cards;

  /// Called when a card leaves the deck (`toRight` = swiped rightward).
  final void Function(int index, bool toRight)? onSwiped;

  /// Fraction of width past which release dismisses the card.
  final double threshold;

  /// Release speed, in logical pixels/second, above which the card is flung
  /// regardless of how far it was dragged (default 700).
  final double flingVelocity;

  @override
  State<FxSwipeCards> createState() => _FxSwipeCardsState();
}

class _FxSwipeCardsState extends State<FxSwipeCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _top = 0;
  // Drives the moving card without rebuilding the card widgets each frame.
  final ValueNotifier<Offset> _drag = ValueNotifier(Offset.zero);
  double _width = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _update(DragUpdateDetails d) {
    _controller.stop();
    _drag.value += d.delta;
  }

  void _end(DragEndDetails d) {
    final vx = d.velocity.pixelsPerSecond.dx;
    final fling = vx.abs() > widget.flingVelocity;
    final past = _drag.value.dx.abs() > _width * widget.threshold || fling;
    if (past) {
      // Prefer the fling direction when a fling is present, otherwise fall
      // back to the drag direction.
      final toRight = fling ? vx > 0 : _drag.value.dx > 0;
      _animateTo(
        Offset(toRight ? _width * 1.5 : -_width * 1.5, _drag.value.dy),
        onDone: () {
          widget.onSwiped?.call(_top, toRight);
          _drag.value = Offset.zero;
          setState(() => _top++);
        },
      );
    } else {
      _animateTo(Offset.zero);
    }
  }

  void _animateTo(Offset target, {VoidCallback? onDone}) {
    final anim = Tween<Offset>(
      begin: _drag.value,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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

          final nextCard = _top + 1 < widget.cards.length
              ? widget.cards[_top + 1]
              : null;
          final topCard = _top < widget.cards.length
              ? widget.cards[_top]
              : null;

          return ValueListenableBuilder<Offset>(
            valueListenable: _drag,
            builder: (context, drag, _) {
              final children = <Widget>[];

              if (nextCard != null) {
                final t = (drag.dx.abs() / _width).clamp(0.0, 1.0);
                children.add(
                  Transform.scale(scale: 0.92 + 0.08 * t, child: nextCard),
                );
              }

              if (topCard != null) {
                children.add(
                  Transform.translate(
                    offset: drag,
                    child: Transform.rotate(
                      angle: drag.dx / _width * 0.3,
                      child: GestureDetector(
                        onPanUpdate: _update,
                        onPanEnd: _end,
                        child: topCard,
                      ),
                    ),
                  ),
                );
              }

              return Stack(alignment: Alignment.center, children: children);
            },
          );
        },
      ),
    );
  }
}
