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
  });

  final List<Widget> cards;

  /// Called when a card leaves the deck (`toRight` = swiped rightward).
  final void Function(int index, bool toRight)? onSwiped;

  /// Fraction of width past which release dismisses the card.
  final double threshold;

  @override
  State<FxSwipeCards> createState() => _FxSwipeCardsState();
}

class _FxSwipeCardsState extends State<FxSwipeCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _top = 0;
  Offset _drag = Offset.zero;
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
    setState(() => _drag += d.delta);
  }

  void _end(DragEndDetails d) {
    final vx = d.velocity.pixelsPerSecond.dx;
    final past = _drag.dx.abs() > _width * widget.threshold || vx.abs() > 700;
    if (past) {
      final toRight = _drag.dx > 0 || vx > 0;
      _animateTo(
        Offset(toRight ? _width * 1.5 : -_width * 1.5, _drag.dy),
        onDone: () {
          widget.onSwiped?.call(_top, toRight);
          setState(() {
            _top++;
            _drag = Offset.zero;
          });
        },
      );
    } else {
      _animateTo(Offset.zero);
    }
  }

  void _animateTo(Offset target, {VoidCallback? onDone}) {
    final anim = Tween<Offset>(
      begin: _drag,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth.isFinite ? constraints.maxWidth : 300;
        final children = <Widget>[];

        if (_top + 1 < widget.cards.length) {
          final t = (_drag.dx.abs() / _width).clamp(0.0, 1.0);
          children.add(
            Transform.scale(
              scale: 0.92 + 0.08 * t,
              child: widget.cards[_top + 1],
            ),
          );
        }

        if (_top < widget.cards.length) {
          children.add(
            Transform.translate(
              offset: _drag,
              child: Transform.rotate(
                angle: _drag.dx / _width * 0.3,
                child: GestureDetector(
                  onPanUpdate: _update,
                  onPanEnd: _end,
                  child: widget.cards[_top],
                ),
              ),
            ),
          );
        }

        return Stack(alignment: Alignment.center, children: children);
      },
    );
  }
}
