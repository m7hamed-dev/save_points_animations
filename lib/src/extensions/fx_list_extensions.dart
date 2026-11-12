import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';
import 'package:save_points_animations/src/effects/transform_effects.dart';
import 'package:save_points_animations/src/effects/visual_effects.dart';

/// Turn a list of widgets into a staggered animation group.
extension FxAnimateList on List<Widget> {
  /// Begin a staggered list animation.
  ///
  /// ```dart
  /// children.animateList().fade().slideY(0.2).interval(80.ms).build();
  /// ```
  FxListBuilder animateList() => FxListBuilder._(
    this,
    const <FxEffect>[],
    const Duration(milliseconds: 50),
  );
}

/// A chainable builder that applies the same effects to every child, offset by
/// a per-index [interval].
///
/// Item `i` starts `delay + interval * i` after mounting. Children keep their
/// keys: a keyed child's animation follows it when the list is reordered.
class FxListBuilder {
  const FxListBuilder._(
    this._children,
    this._effects,
    this._interval, {
    this._duration,
    this._delay = Duration.zero,
    this._curve,
  });

  final List<Widget> _children;
  final List<FxEffect> _effects;
  final Duration _interval;
  final Duration? _duration;
  final Duration _delay;
  final Curve? _curve;

  FxListBuilder _copy({
    List<FxEffect>? effects,
    Duration? interval,
    Duration? duration,
    Duration? delay,
    Curve? curve,
  }) => FxListBuilder._(
    _children,
    effects ?? _effects,
    interval ?? _interval,
    duration: duration ?? _duration,
    delay: delay ?? _delay,
    curve: curve ?? _curve,
  );

  FxListBuilder _add(FxEffect e) => _copy(effects: <FxEffect>[..._effects, e]);

  /// Fade each item in.
  FxListBuilder fade({double begin = 0.0, double end = 1.0}) =>
      _add(FadeEffect(begin: begin, end: end));

  /// Slide each item on Y (fraction of height).
  FxListBuilder slideY(double begin, {double end = 0}) =>
      _add(SlideEffect(beginY: begin, endY: end));

  /// Slide each item on X (fraction of width). With [directional], positive
  /// values point toward the trailing edge and mirror in right-to-left text.
  FxListBuilder slideX(
    double begin, {
    double end = 0,
    bool directional = false,
  }) => _add(SlideEffect(beginX: begin, endX: end, directional: directional));

  /// Move each item on Y (pixels).
  FxListBuilder moveY(double begin, {double end = 0}) =>
      _add(MoveEffect(beginY: begin, endY: end));

  /// Scale each item in.
  FxListBuilder scale({double begin = 0.8, double end = 1.0}) =>
      _add(ScaleEffect(begin: begin, end: end));

  /// Add any custom effect.
  FxListBuilder effect(FxEffect e) => _add(e);

  /// Set the stagger interval between successive items.
  FxListBuilder interval(Duration value) => _copy(interval: value);

  /// Set the duration of every effect that doesn't set its own.
  FxListBuilder duration(Duration value) => _copy(duration: value);

  /// Set the curve of every effect that doesn't set its own.
  FxListBuilder curve(Curve value) => _copy(curve: value);

  /// Wait [value] before the first item starts (the stagger follows).
  FxListBuilder delay(Duration value) => _copy(delay: value);

  /// Materialize the staggered children (drop-in for `children:`).
  List<Widget> build() => <Widget>[
    for (var i = 0; i < _children.length; i++) _buildItem(i),
  ];

  Widget _buildItem(int index) {
    final child = _children[index];
    final key = child.key;
    var builder = FxBuilder(
      key: key == null ? null : _FxListItemKey(key),
      duration: _duration,
      delay: _delay + _interval * index,
      curve: _curve,
      child: child,
    );
    for (final e in _effects) {
      builder = builder.addEffect(e);
    }
    return builder;
  }
}

/// Keys a staggered item by its child's key, so a `Row` / `Column` /
/// `ListView` reconciles the animated wrapper (and its running state) with
/// the child it belongs to — distinct from the child's own key, which stays
/// on the child.
class _FxListItemKey extends ValueKey<Key> {
  const _FxListItemKey(super.value);
}
