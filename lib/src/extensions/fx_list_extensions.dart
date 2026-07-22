import 'package:flutter/widgets.dart';
import 'package:save_points_animations/src/effects/fx_effect.dart';
import 'package:save_points_animations/src/effects/transform_effects.dart';
import 'package:save_points_animations/src/effects/visual_effects.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';

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
class FxListBuilder {
  const FxListBuilder._(this._children, this._effects, this._interval);

  final List<Widget> _children;
  final List<FxEffect> _effects;
  final Duration _interval;

  FxListBuilder _add(FxEffect e) =>
      FxListBuilder._(_children, <FxEffect>[..._effects, e], _interval);

  /// Fade each item in.
  FxListBuilder fade({double begin = 0.0, double end = 1.0}) =>
      _add(FadeEffect(begin: begin, end: end));

  /// Slide each item on Y (fraction of height).
  FxListBuilder slideY(double begin, {double end = 0}) =>
      _add(SlideEffect(beginY: begin, endY: end));

  /// Slide each item on X (fraction of width).
  FxListBuilder slideX(double begin, {double end = 0}) =>
      _add(SlideEffect(beginX: begin, endX: end));

  /// Scale each item in.
  FxListBuilder scale({double begin = 0.8, double end = 1.0}) =>
      _add(ScaleEffect(begin: begin, end: end));

  /// Add any custom effect.
  FxListBuilder effect(FxEffect e) => _add(e);

  /// Set the stagger interval between successive items.
  FxListBuilder interval(Duration value) =>
      FxListBuilder._(_children, _effects, value);

  /// Materialize the staggered children (drop-in for `children:`).
  List<Widget> build() => <Widget>[
    for (var i = 0; i < _children.length; i++) _buildItem(i),
  ];

  Widget _buildItem(int index) {
    var builder = _children[index].animate();
    final offset = _interval * index;
    for (final e in _effects) {
      builder = builder.addEffect(
        e.copyWithTiming(delay: (e.delay ?? Duration.zero) + offset),
      );
    }
    return builder;
  }
}
