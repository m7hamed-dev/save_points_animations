import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

void main() {
  group('num duration extensions', () {
    test('.ms builds milliseconds', () {
      expect(300.ms, const Duration(milliseconds: 300));
    });

    test('.seconds supports fractions', () {
      expect(1.5.seconds, const Duration(milliseconds: 1500));
    });

    test('.minutes builds minutes', () {
      expect(2.minutes, const Duration(minutes: 2));
    });

    test('.s is an alias for seconds', () {
      expect(3.s, 3.seconds);
    });
  });
}
