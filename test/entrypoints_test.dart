import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// The engine alone: `animate()` chains, without the widget catalog or the
// one-call `Widget` shortcuts.
import 'package:save_points_animations/core.dart';
import 'package:save_points_animations/widgets.dart' as catalog;

void main() {
  testWidgets('core.dart runs a chain on its own', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: const Text(
          'core',
        ).animate(duration: FxDurations.short4).fade().moveY(10),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('core'), findsOneWidget);
  });

  testWidgets('widgets.dart exposes the catalog', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: catalog.FxDotsLoader()),
      ),
    );
    expect(find.byType(catalog.FxDotsLoader), findsOneWidget);
  });
}
