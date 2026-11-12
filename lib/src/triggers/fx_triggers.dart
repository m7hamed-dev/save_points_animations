import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/controllers/fx_controller.dart';

/// How a triggered animation is (re)started.
enum FxTrigger {
  /// Play once when first mounted.
  appear,

  /// Replay on each tap.
  tap,

  /// Replay on each double tap.
  doubleTap,

  /// Replay on each long press.
  longPress,

  /// Replay when the pointer enters (desktop/web hover).
  hover,

  /// Play once when the widget first scrolls into the viewport.
  visible,
}

/// Attach event triggers to an animation chain.
///
/// ```dart
/// icon.animate().scale(begin: 0.6).curve(FxCurves.elastic).onTap();
/// card.animate().fadeIn().onVisible();
/// ```
extension FxTriggerExtension on FxBuilder {
  /// Replay this chain on tap.
  Widget onTap({VoidCallback? onTap}) =>
      _FxTriggered(builder: this, trigger: FxTrigger.tap, onEvent: onTap);

  /// Replay this chain on double tap.
  Widget onDoubleTap({VoidCallback? onDoubleTap}) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.doubleTap,
    onEvent: onDoubleTap,
  );

  /// Replay this chain on long press.
  Widget onLongPress({VoidCallback? onLongPress}) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.longPress,
    onEvent: onLongPress,
  );

  /// Replay this chain when the pointer hovers over it.
  Widget onHover() => _FxTriggered(builder: this, trigger: FxTrigger.hover);

  /// Play this chain once when it first mounts (explicit form of autoplay).
  Widget onAppear() => _FxTriggered(builder: this, trigger: FxTrigger.appear);

  /// Play this chain when it scrolls into the viewport.
  ///
  /// The widget counts as shown once at least [visibleFraction] of its area
  /// is on screen, and as hidden again once it has fully left. Works in any
  /// scroll view — lazy (`ListView.builder`) or eager
  /// (`SingleChildScrollView`), vertical or horizontal, nested or not.
  ///
  /// With [once] (the default) the chain plays the first time only; with
  /// `once: false` it rewinds whenever the widget leaves and replays each time
  /// it comes back. [onShown] and [onHidden] fire on every entry and exit.
  Widget onVisible({
    double visibleFraction = 0.1,
    bool once = true,
    VoidCallback? onShown,
    VoidCallback? onHidden,
  }) => _FxTriggered(
    builder: this,
    trigger: FxTrigger.visible,
    visibleFraction: visibleFraction,
    once: once,
    onEvent: onShown,
    onHidden: onHidden,
  );

  /// Alias for [onVisible].
  Widget animateOnVisible({
    double visibleFraction = 0.1,
    bool once = true,
    VoidCallback? onShown,
    VoidCallback? onHidden,
  }) => onVisible(
    visibleFraction: visibleFraction,
    once: once,
    onShown: onShown,
    onHidden: onHidden,
  );
}

class _FxTriggered extends StatefulWidget {
  const _FxTriggered({
    required this.builder,
    required this.trigger,
    this.onEvent,
    this.visibleFraction = 0.1,
    this.once = true,
    this.onHidden,
  }) : assert(
         visibleFraction > 0 && visibleFraction <= 1,
         'visibleFraction must be in (0, 1]',
       );

  final FxBuilder builder;
  final FxTrigger trigger;

  /// The trigger's callback (for `visible`: each time the widget is shown).
  final VoidCallback? onEvent;
  final double visibleFraction;
  final bool once;
  final VoidCallback? onHidden;

  @override
  State<_FxTriggered> createState() => _FxTriggeredState();
}

class _FxTriggeredState extends State<_FxTriggered> {
  final FxController _controller = FxController();
  bool _visibleCheckScheduled = false;
  Timer? _delayTimer;

  /// Whether the widget currently counts as on screen.
  bool _shown = false;

  /// Whether the chain has played at least once on visibility.
  bool _played = false;

  /// Whether visibility no longer matters (played once, no callbacks left).
  bool _doneWatching = false;

  bool get _keepWatching =>
      !widget.once || widget.onEvent != null || widget.onHidden != null;

  /// Every enclosing scroll position, nearest first. Scroll notifications only
  /// bubble *up* from a `Scrollable`, so a listener placed inside the scrolled
  /// content never hears them — the positions are observed directly instead.
  /// Outer positions matter too (e.g. a carousel inside a scrolling page).
  List<ScrollPosition> _positions = const <ScrollPosition>[];

  bool get _playOnMount => widget.trigger == FxTrigger.appear;

  void _fire() {
    _play();
    widget.onEvent?.call();
  }

  /// Restart the chain, after the chain's `animate(delay:)` if it has one.
  void _play() {
    _delayTimer?.cancel();
    final delay = widget.builder.startDelay ?? Duration.zero;
    if (delay <= Duration.zero) {
      _controller.restart();
      return;
    }
    _controller.reset();
    _delayTimer = Timer(delay, () {
      if (mounted) _controller.restart();
    });
  }

  void _subscribeToScrolling() {
    final next = <ScrollPosition>[];
    var scrollable = Scrollable.maybeOf(context);
    while (scrollable != null) {
      next.add(scrollable.position);
      scrollable = Scrollable.maybeOf(scrollable.context);
    }
    if (next.length == _positions.length) {
      var same = true;
      for (var i = 0; i < next.length; i++) {
        if (!identical(next[i], _positions[i])) {
          same = false;
          break;
        }
      }
      if (same) return;
    }
    _unsubscribeFromScrolling();
    _positions = next;
    for (final position in _positions) {
      position.addListener(_scheduleVisibleCheck);
    }
  }

  void _unsubscribeFromScrolling() {
    for (final position in _positions) {
      position.removeListener(_scheduleVisibleCheck);
    }
    _positions = const <ScrollPosition>[];
  }

  /// Measure after the next layout, when the scrolled offset is applied —
  /// reading geometry inside the scroll listener would lag one frame behind.
  void _scheduleVisibleCheck() {
    if (_doneWatching || _visibleCheckScheduled) return;
    _visibleCheckScheduled = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        _visibleCheckScheduled = false;
        if (mounted) _checkVisible();
      })
      ..ensureVisualUpdate();
  }

  void _checkVisible() {
    if (_doneWatching) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final size = box.size;
    final area = size.width * size.height;
    if (area <= 0) return;
    final bounds = box.localToGlobal(Offset.zero) & size;
    final visible = bounds.intersect(Offset.zero & MediaQuery.sizeOf(context));
    final fraction = visible.width <= 0 || visible.height <= 0
        ? 0.0
        : (visible.width * visible.height) / area;
    if (!_shown && fraction >= widget.visibleFraction) {
      _shown = true;
      if (!widget.once || !_played) _play();
      _played = true;
      widget.onEvent?.call();
      if (!_keepWatching) {
        _doneWatching = true;
        _unsubscribeFromScrolling();
      }
    } else if (_shown && fraction <= 0) {
      _shown = false;
      // Rewind while off screen so the next entry replays from the start.
      if (!widget.once) {
        _delayTimer?.cancel();
        _controller.reset();
      }
      widget.onHidden?.call();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.trigger == .visible && !_doneWatching) {
      _subscribeToScrolling();
      _scheduleVisibleCheck();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _unsubscribeFromScrolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animated = widget.builder.configure(
      controller: _controller,
      autoPlay: _playOnMount,
    );

    switch (widget.trigger) {
      case .appear:
        return animated;
      case .tap:
        return GestureDetector(onTap: _fire, child: animated);
      case .doubleTap:
        return GestureDetector(onDoubleTap: _fire, child: animated);
      case .longPress:
        return GestureDetector(onLongPress: _fire, child: animated);
      case .hover:
        return MouseRegion(onEnter: (_) => _fire(), child: animated);
      case .visible:
        // Scroll positions are observed directly (see _subscribeToScrolling).
        return animated;
    }
  }
}
