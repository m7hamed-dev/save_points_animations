import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('debug overlays (debug build)', () {
    testWidgets('showBounds renders the child inside a bounds overlay', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const Text('bounded').showBounds()));
      expect(find.text('bounded'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('showFPS renders and ticks without error', (tester) async {
      await tester.pumpWidget(_host(const Text('fps').showFPS()));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('fps'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Tear down cleanly (ticker must dispose).
      await tester.pumpWidget(_host(const SizedBox()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('showPerformance shows the live controller count', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('a').animate().fade(),
              const Text('b').animate().fade(),
            ],
          ).showPerformance(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      // The two .animate() children register controllers.
      expect(find.textContaining('ctrls: 2'), findsOneWidget);
    });
  });

  group('FxDebugRegistry', () {
    testWidgets('tracks controllers as widgets mount and unmount', (
      tester,
    ) async {
      expect(FxDebugRegistry.activeControllers, 0);
      await tester.pumpWidget(
        _host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('x').animate().fade(),
              const Text('y').animate().scale(),
              const Text('z').animate().rotate(),
            ],
          ),
        ),
      );
      expect(FxDebugRegistry.activeControllers, 3);

      await tester.pumpWidget(_host(const SizedBox()));
      expect(FxDebugRegistry.activeControllers, 0);
    });
  });
}
