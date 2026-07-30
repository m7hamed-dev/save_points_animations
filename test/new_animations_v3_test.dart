import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('PopEffect', () {
    // storage[0] is the X scale of the composed Matrix4 (diagonal3Values).
    test('overshoots past 1 mid-flight then settles to 1', () {
      const effect = PopEffect();
      final mid = FxAccumulator();
      effect.apply(mid, 0.6);
      expect(mid.transform.storage[0], greaterThan(1.0));

      final end = FxAccumulator();
      effect.apply(end, 1.0);
      expect(end.transform.storage[0], closeTo(1.0, 1e-6));
      expect(end.opacity, closeTo(1.0, 1e-6));
    });

    test('starts fully transparent and small', () {
      final acc = FxAccumulator();
      const PopEffect().apply(acc, 0.0);
      expect(acc.opacity, 0.0);
      expect(acc.transform.storage[0], lessThan(0.5));
    });

    testWidgets('.pop() builds and renders', (tester) async {
      await tester.pumpWidget(_host(const Text('pop').animate().pop()));
      expect(find.text('pop'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });

  group('new widgets render & dispose cleanly', () {
    testWidgets('FxMeshGradient', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 200,
            height: 200,
            child: FxMeshGradient(child: Text('mesh')),
          ),
        ),
      );
      expect(find.text('mesh'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxGlowButton taps and disables', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(FxGlowButton(onPressed: () => taps++, child: const Text('Go'))),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);

      // Null onPressed → disabled, no callback.
      await tester.pumpWidget(
        _host(const FxGlowButton(child: Text('Go'))),
      );
      await tester.tap(find.text('Go'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxWaveDots', (tester) async {
      await tester.pumpWidget(_host(const FxWaveDots()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('reduced motion is honored', () {
    testWidgets('looping widgets settle without a running ticker', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _host(
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 100, height: 100, child: FxMeshGradient()),
                FxWaveDots(),
                FxGlowButton(child: Text('x')),
              ],
            ),
          ),
        ),
      );
      // With animations disabled these must reach a steady state (no pending
      // frames), so pumpAndSettle returns instead of timing out.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
