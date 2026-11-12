import 'package:save_points_animations/src/core/fx_curves.dart';

/// Material 3 motion duration tokens, so timing can be named rather than
/// guessed and stays consistent with the rest of a Material app.
///
/// Pair the short tokens with small, utility-sized motion (selection, toggles,
/// icons), the medium ones with components entering or leaving, and the long
/// ones with large surfaces and full-screen transitions. See the [FxCurves]
/// `emphasized*` / `standard*` curves for the matching easing tokens.
///
/// ```dart
/// card.animate(duration: FxDurations.medium2, curve: FxCurves.emphasized)
///     .fadeIn();
/// ```
abstract final class FxDurations {
  /// 50ms.
  static const Duration short1 = Duration(milliseconds: 50);

  /// 100ms.
  static const Duration short2 = Duration(milliseconds: 100);

  /// 150ms.
  static const Duration short3 = Duration(milliseconds: 150);

  /// 200ms.
  static const Duration short4 = Duration(milliseconds: 200);

  /// 250ms.
  static const Duration medium1 = Duration(milliseconds: 250);

  /// 300ms.
  static const Duration medium2 = Duration(milliseconds: 300);

  /// 350ms — the package's default effect duration.
  static const Duration medium3 = Duration(milliseconds: 350);

  /// 400ms.
  static const Duration medium4 = Duration(milliseconds: 400);

  /// 450ms.
  static const Duration long1 = Duration(milliseconds: 450);

  /// 500ms.
  static const Duration long2 = Duration(milliseconds: 500);

  /// 550ms.
  static const Duration long3 = Duration(milliseconds: 550);

  /// 600ms.
  static const Duration long4 = Duration(milliseconds: 600);

  /// 700ms.
  static const Duration extraLong1 = Duration(milliseconds: 700);

  /// 800ms.
  static const Duration extraLong2 = Duration(milliseconds: 800);

  /// 900ms.
  static const Duration extraLong3 = Duration(milliseconds: 900);

  /// 1000ms.
  static const Duration extraLong4 = Duration(milliseconds: 1000);
}
