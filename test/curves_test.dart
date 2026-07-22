import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('FxCurves modern easing', () {
    final curves = <String, Curve>{
      'emphasized': FxCurves.emphasized,
      'emphasizedDecelerate': FxCurves.emphasizedDecelerate,
      'emphasizedAccelerate': FxCurves.emphasizedAccelerate,
      'standardDecelerate': FxCurves.standardDecelerate,
    };

    curves.forEach((name, curve) {
      test('$name has clean 0/1 endpoints', () {
        expect(curve.transform(0), 0.0, reason: name);
        expect(curve.transform(1), 1.0, reason: name);
      });

      test('$name stays within a sane range (no wild overshoot)', () {
        for (var i = 0; i <= 20; i++) {
          final v = curve.transform(i / 20);
          expect(v, greaterThanOrEqualTo(-0.05), reason: name);
          expect(v, lessThanOrEqualTo(1.05), reason: name);
        }
      });
    });

    test('emphasized is the package default curve', () {
      // A default .animate() effect eases with the modern emphasized curve.
      expect(const FxThemeData().curve, same(FxCurves.emphasized));
    });

    test('decelerate front-loads progress (fast in, smooth settle)', () {
      // At the one-third mark a decelerate curve is already well past a third.
      expect(FxCurves.emphasizedDecelerate.transform(0.33), greaterThan(0.5));
    });
  });
}
