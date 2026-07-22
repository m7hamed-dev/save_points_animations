import 'package:flutter/widgets.dart';

import 'package:save_points_animations/src/builders/fx_builder.dart';
import 'package:save_points_animations/src/core/fx_curves.dart';
import 'package:save_points_animations/src/extensions/fx_widget_extensions.dart';
import 'package:save_points_animations/src/extensions/num_duration_extensions.dart';

/// Ready-made, professionally tuned animations composed from the core effects.
///
/// ```dart
/// icon.success();
/// field.error();
/// spinner.loading();
/// ```
extension FxPresets on Widget {
  /// Confident elastic pop — good for confirmations.
  FxBuilder success() => animate()
      .fade()
      .scale(begin: 0.5)
      .curve(FxCurves.elastic)
      .duration(500.ms);

  /// Sharp horizontal shake — good for invalid input.
  FxBuilder error() => animate().shake(amplitude: 12).duration(500.ms);

  /// Amber-ish pulse to draw the eye.
  FxBuilder warning() => animate().pulse(amount: 0.15).duration(500.ms);

  /// Continuous spinner (loops).
  FxBuilder loading() =>
      animate().rotate(0, 360).curve(Curves.linear).duration(900.ms).looping();

  /// Fade + rise + subtle scale — a polished hero entrance.
  FxBuilder heroEntry() => animate()
      .fade()
      .moveY(40)
      .scale(begin: 0.85)
      .curve(FxCurves.snappy)
      .duration(650.ms);

  /// Fade + shrink exit.
  FxBuilder heroExit() =>
      animate().fadeOut().scale(begin: 1, end: 0.9).duration(400.ms);

  /// Dialog appearance: quick scale-in from 0.85.
  FxBuilder dialog() => animate()
      .fade()
      .scale(begin: 0.85)
      .curve(FxCurves.snappy)
      .duration(300.ms);

  /// Tooltip appearance: fade + tiny rise.
  FxBuilder tooltip() => animate().fade().moveY(6).duration(180.ms);

  /// Toast appearance: rise from the bottom.
  FxBuilder toast() =>
      animate().fade().slideY(0.4).curve(FxCurves.snappy).duration(350.ms);

  /// Snackbar appearance (alias of [toast]).
  FxBuilder snackbar() => toast();

  /// Card entrance: fade + rise + subtle scale.
  FxBuilder cardEntry() => animate()
      .fade()
      .moveY(24)
      .scale(begin: 0.96)
      .curve(FxCurves.soft)
      .duration(500.ms);

  /// List item entrance: fade + slide from the side.
  FxBuilder listItem() =>
      animate().fade().slideX(0.12).curve(FxCurves.soft).duration(400.ms);

  /// Page-transition style entrance: fade + horizontal slide.
  FxBuilder pageTransition() =>
      animate().fade().slideX(0.1).curve(FxCurves.snappy).duration(400.ms);

  /// Modal appearance: fade + rise.
  FxBuilder modal() =>
      animate().fade().slideY(0.15).curve(FxCurves.snappy).duration(350.ms);

  /// Popup appearance: elastic scale-in.
  FxBuilder popup() => animate()
      .fade()
      .scale(begin: 0.7)
      .curve(FxCurves.elastic)
      .duration(450.ms);

  /// Empty-state illustration: gentle fade + scale.
  FxBuilder emptyState() =>
      animate().fade().scale(begin: 0.9).curve(FxCurves.soft).duration(600.ms);

  /// Onboarding entrance: fade + rise.
  FxBuilder onboarding() =>
      animate().fade().moveY(30).curve(FxCurves.snappy).duration(600.ms);

  /// FAB entrance: elastic scale from zero.
  FxBuilder fab() => animate().scale().curve(FxCurves.elastic).duration(500.ms);

  /// Notification banner: drop in from the top.
  FxBuilder notification() =>
      animate().fade().slideY(-0.5).curve(FxCurves.snappy).duration(400.ms);
}
