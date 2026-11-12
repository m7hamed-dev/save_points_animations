// On-device performance + Impeller harness.
//
// Run on a real device (frame timings are meaningless on a simulator):
//   flutter test integration_test/perf_test.dart --profile
//
// To validate rendering under Impeller specifically:
//   flutter test integration_test/perf_test.dart --profile --enable-impeller
//
// The captured timeline is written to `build/` and can be summarized with the
// `flutter_driver` `summarizeTimeline` helpers if you add a driver target.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations_example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling the animated showcase stays smooth', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;

    await binding.traceAction(() async {
      for (var i = 0; i < 5; i++) {
        await tester.fling(scrollable, const Offset(0, -500), 3000);
        await tester.pumpAndSettle();
        await tester.fling(scrollable, const Offset(0, 500), 3000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'scrolling_timeline');

    expect(tester.takeException(), isNull);
  });
}
