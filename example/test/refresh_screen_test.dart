import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';
import 'package:save_points_animations_example/refresh_screen.dart';

void main() {
  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.fling(
      find.text('Ava Thompson').first,
      const Offset(0, 400),
      1000,
    );
    // Snap, then the 1.6s fake fetch, then the finish animation.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('every style refreshes the list, in light/dark and LTR/RTL', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RefreshScreen()));
    await tester.pumpAndSettle();
    expect(find.text('now'), findsNothing);

    var fetched = 0;
    for (final style in FxRefreshStyle.values) {
      await tester.tap(find.widgetWithText(ChoiceChip, style.name));
      await tester.pumpAndSettle();
      await pullToRefresh(tester);
      expect(find.text('now'), findsNWidgets(++fetched), reason: style.name);
    }

    await tester.tap(find.byTooltip('Dark mode'));
    await tester.tap(find.byTooltip('Right to left'));
    await tester.pumpAndSettle();
    expect(find.text('السحب للتحديث'), findsOneWidget);

    await tester.tap(find.byTooltip('Refresh from code'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.text('now'), findsNWidgets(++fetched));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a mouse drag pulls to refresh on desktop',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RefreshScreen()));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Ava Thompson').first),
        kind: PointerDeviceKind.mouse,
      );
      // Bouncing (macOS) overscroll has friction, so the mouse travels far.
      for (var i = 0; i < 50; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('now'), findsOneWidget);
    },
  );
}
