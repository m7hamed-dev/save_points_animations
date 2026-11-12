import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations_example/playground_screen.dart';

void main() {
  testWidgets('playground plays, switches modes and shows its code', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PlaygroundScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('.slideFromStart()'), findsWidgets);
    expect(find.text('Completed 1 time'), findsOneWidget);

    await tester.tap(find.text('Replay'));
    await tester.pumpAndSettle();
    expect(find.text('Completed 2 times'), findsOneWidget);

    for (final label in ['Right-to-left', 'State-driven (target)']) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.textContaining('target: selected'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('target: selected ? 1 : 0'), findsOneWidget);

    await tester.tap(find.text('target: 1'));
    await tester.pumpAndSettle();
    expect(find.text('target: 0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
