import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';
import 'package:save_points_animations_example/glow_screen.dart';

void main() {
  // The glows loop forever, so time moves in fixed steps, never to settle.
  Future<void> frames(WidgetTester tester, [int count = 10]) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('every style glows around each sample, in dark and light', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: GlowScreen()));
    await frames(tester);

    for (final style in FxGlowStyle.values) {
      final chip = find.widgetWithText(ChoiceChip, style.name);
      await tester.scrollUntilVisible(
        chip,
        100,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('styles')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(chip);
      await frames(tester);
      final glows = tester.widgetList<FxGlow>(find.byType(FxGlow));
      expect(glows, hasLength(3));
      expect(glows.map((g) => g.style).toSet(), {style}, reason: style.name);
    }

    await tester.tap(find.byTooltip('Light mode'));
    await frames(tester);
    await tester.tap(find.text('Mint'));
    await frames(tester);
    expect(
      tester.widget<FxGlow>(find.byType(FxGlow).first).color,
      const Color(0xFF00B894),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the hover style follows the mouse', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GlowScreen()));
    await frames(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'hover'));
    await frames(tester);
    expect(
      find.text('Point at a sample with the mouse, or press it.'),
      findsOneWidget,
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Ask AI')));
    await frames(tester);
    await mouse.moveTo(Offset.zero);
    await frames(tester);
    expect(tester.takeException(), isNull);
  });
}
