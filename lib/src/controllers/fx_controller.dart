import 'package:flutter/widgets.dart';

/// A remote control for an animation created by `.animate()`.
///
/// The underlying [AnimationController] is owned and disposed by the internal
/// builder state (it needs a [TickerProvider]); this facade simply forwards
/// commands to it. Calling [dispose] here is therefore a no-op — you never
/// leak or double-dispose by holding an [FxController].
///
/// ```dart
/// final fx = FxController();
/// Widget build(context) => icon.animate(controller: fx).scale();
/// // later: fx.restart();
/// ```
class FxController {
  AnimationController? _controller;

  /// Whether this controller is currently attached to a live animation.
  bool get isAttached => _controller != null;

  /// The current progress in `0..1`, or `0` when detached.
  double get value => _controller?.value ?? 0.0;

  /// The animation status, or [AnimationStatus.dismissed] when detached.
  AnimationStatus get status =>
      _controller?.status ?? AnimationStatus.dismissed;

  /// Internal: bind to the state-owned controller.
  void attach(AnimationController controller) => _controller = controller;

  /// Internal: unbind when the state disposes.
  void detach(AnimationController controller) {
    if (identical(_controller, controller)) _controller = null;
  }

  /// Play forward from the current position.
  TickerFuture? play() => _controller?.forward();

  /// Alias for [play].
  TickerFuture? forward() => _controller?.forward();

  /// Pause at the current position.
  void pause() => _controller?.stop(canceled: false);

  /// Resume forward playback.
  TickerFuture? resume() => _controller?.forward();

  /// Restart from the beginning.
  TickerFuture? restart() {
    _controller?.reset();
    return _controller?.forward();
  }

  /// Play in reverse toward the start.
  TickerFuture? reverse() => _controller?.reverse();

  /// Stop the animation where it is.
  void stop() => _controller?.stop();

  /// Loop the animation, optionally mirroring on each cycle.
  TickerFuture? repeat({bool reverse = false}) =>
      _controller?.repeat(reverse: reverse);

  /// Jump to a normalized position in `0..1`.
  void seek(double t) {
    final c = _controller;
    if (c != null) c.value = t.clamp(0.0, 1.0);
  }

  /// Reset to the start without playing.
  void reset() => _controller?.reset();

  /// No-op — the controller lifecycle is owned by the builder state.
  void dispose() {}
}
