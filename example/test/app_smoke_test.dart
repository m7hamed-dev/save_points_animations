// Runtime smoke test: drives the REAL example app the way a user would —
// scrolls the whole animated showcase (forcing every widget, incl. FxOdometer,
// FxMarquee, FxSwipeCards and FxSlideToConfirm, to lay out and build), then
// force-unmounts everything to exercise disposal.
//
// This guards the fixes for:
//   • the "Looking up a deactivated widget's ancestor is unsafe" ticker crashes
//     (FxSwipeCards / FxSwipeToDismiss / FxSlideToConfirm disposed before use);
//   • the FxOdometer vertical + FxMarquee horizontal RenderFlex overflows.
// Any recurrence is reported through tester.takeException().
//
// Uses fixed-duration pumps (never pumpAndSettle) because the showcase has
// continuously-looping animations that never settle.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations_example/main.dart' as app;

void main() {
  testWidgets('example app scrolls end-to-end and disposes cleanly', (
    tester,
  ) async {
    // Capture the FULL error (with the crashing widget's dispose stack).
    final captured = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = (details) {
      captured.add(details);
      prev?.call(details);
    };
    addTearDown(() => FlutterError.onError = prev);

    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final scrollable = find.byType(Scrollable).first;

    // Traverse the full list top-to-bottom, building every showcase widget as
    // it scrolls into view. An overflow (odometer/marquee) or any other layout
    // assertion fires during a pump and is caught here.
    for (var i = 0; i < 40; i++) {
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 60));
      if (captured.isNotEmpty) {
        for (final d in captured) {
          debugPrint('CAUGHT at step $i: ${d.exception}');
          debugPrint('STACK:\n${d.stack}');
        }
        fail('exception while scrolling (step $i) — see stacks above');
      }
      tester.takeException();
    }

    // Force-unmount the entire app → disposes every animated widget, including
    // ones that were built but never interacted with. This is the exact path
    // that used to throw the ticker "deactivated ancestor" crash.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(
      tester.takeException(),
      isNull,
      reason: 'exception during widget disposal',
    );
  });
}
