@Tags(['benchmark'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// A lightweight, CI-runnable smoke benchmark. It builds a large staggered
/// grid of animated widgets, pumps the animation, and reports timing. Timing
/// is informational (wall-clock in CI is noisy) — the hard assertions are that
/// it builds, settles, and leaves no leaked tickers.
///
/// For real on-device frame timings under Impeller, see
/// `example/integration_test/` and `benchmark/README.md`.
void main() {
  testWidgets('200 staggered animated tiles build and settle', (tester) async {
    const count = 200;
    final stopwatch = Stopwatch()..start();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          // A non-lazy Wrap so every tile actually builds (GridView would
          // only build the visible ones).
          body: SingleChildScrollView(
            child: Wrap(
              children: List.generate(count, (i) => const _Tile())
                  .animateList()
                  .fade()
                  .scale(begin: 0.7)
                  .slideY(0.2)
                  .interval(const Duration(milliseconds: 8))
                  .build(),
            ),
          ),
        ),
      ),
    );
    final buildMs = stopwatch.elapsedMilliseconds;

    // Pump through the animation.
    var frames = 0;
    stopwatch.reset();
    for (var t = 0; t < 60; t++) {
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
    }
    final avgFrameMs = stopwatch.elapsedMilliseconds / frames;

    debugPrint(
      '[benchmark] $count tiles — initial build ${buildMs}ms, '
      'avg pump ${avgFrameMs.toStringAsFixed(2)}ms/frame',
    );

    expect(find.byType(FxBuilder), findsNWidgets(count));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(FxDebugRegistry.activeControllers, 0);
  });
}

class _Tile extends StatelessWidget {
  const _Tile();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(4),
    child: SizedBox(
      width: 32,
      height: 32,
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFF3F51B5))),
    ),
  );
}
