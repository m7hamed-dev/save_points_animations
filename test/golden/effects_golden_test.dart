@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// A plain colored square — pure geometry keeps goldens as portable as
/// possible (no text glyph rendering).
Widget _box([Color color = const Color(0xFF3F51B5)]) =>
    Container(width: 120, height: 120, color: color);

Widget _stage(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: const Color(0xFFFFFFFF),
    body: Center(child: child),
  ),
);

/// Pump [builder] to a deterministic animation value and golden the frame.
/// Goldening a fixed `t` (never a live mid-flight frame) is what makes these
/// stable and reproducible.
Future<void> _goldenAt(
  WidgetTester tester, {
  required FxBuilder Function(FxController c) builder,
  required double t,
  required String name,
}) async {
  final controller = FxController();
  await tester.pumpWidget(_stage(builder(controller)));
  await tester.pump();
  controller.seek(t);
  await tester.pump();
  await expectLater(
    find.byType(FxBuilder),
    matchesGoldenFile('goldens/$name.png'),
  );
}

void main() {
  testWidgets('fade at 50%', (tester) async {
    await _goldenAt(
      tester,
      t: 0.5,
      name: 'fade_50',
      builder: (c) => _box().animate(controller: c, autoPlay: false).fade(),
    );
  });

  testWidgets('scale at 50%', (tester) async {
    await _goldenAt(
      tester,
      t: 0.5,
      name: 'scale_50',
      builder: (c) => _box().animate(controller: c, autoPlay: false).scale(),
    );
  });

  testWidgets('rotate at 100%', (tester) async {
    await _goldenAt(
      tester,
      t: 1.0,
      name: 'rotate_100',
      builder: (c) => _box(
        const Color(0xFFE91E63),
      ).animate(controller: c, autoPlay: false).rotate(45),
    );
  });

  testWidgets('composed fade+scale+move at 30%', (tester) async {
    await _goldenAt(
      tester,
      t: 0.3,
      name: 'composed_30',
      builder: (c) => _box(const Color(0xFF009688))
          .animate(controller: c, autoPlay: false)
          .fade()
          .scale(begin: 0.4)
          .moveY(40),
    );
  });
}
