import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
      await tester.pumpWidget(_host(const FxGlowButton(child: Text('Go'))));
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

  group('BlinkEffect', () {
    test('off in the second half of a cycle, on at the ends', () {
      const effect = BlinkEffect(count: 1);
      final on = FxAccumulator();
      effect.apply(on, 0.2);
      expect(on.opacity, 1.0);

      final off = FxAccumulator();
      effect.apply(off, 0.7);
      expect(off.opacity, 0.0);

      final end = FxAccumulator();
      effect.apply(end, 1.0);
      expect(end.opacity, 1.0);
    });

    testWidgets('.blink() builds and renders', (tester) async {
      await tester.pumpWidget(
        _host(const Text('blink').animate().blink().looping()),
      );
      expect(find.text('blink'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('batch 2 widgets render & dispose cleanly', () {
    testWidgets('FxPlasma', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 160, height: 160, child: FxPlasma())),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxShinyText', (tester) async {
      await tester.pumpWidget(_host(const FxShinyText('SHINY')));
      expect(find.text('SHINY'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxBouncingBall', (tester) async {
      await tester.pumpWidget(_host(const FxBouncingBall()));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxRippleGrid reacts to a tap', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 200, height: 200, child: FxRippleGrid())),
      );
      await tester.tapAt(const Offset(400, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });

  group('SheenEffect', () {
    test('adds a ShaderMask wrap mid-sweep', () {
      final acc = FxAccumulator();
      const SheenEffect().apply(acc, 0.5);
      expect(acc.wraps, hasLength(1));
    });

    testWidgets('.sheen() builds and renders', (tester) async {
      await tester.pumpWidget(
        _host(
          const ColoredBox(
            color: Color(0xFF448AFF),
            child: SizedBox(width: 60, height: 40),
          ).animate().sheen().looping(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });

  group('batch 3 widgets render & dispose cleanly', () {
    testWidgets('FxRain', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 160,
            height: 160,
            child: FxRain(seed: 7, child: ColoredBox(color: Color(0xFF10131A))),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxJellyButton wobbles on tap and disables', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(FxJellyButton(onPressed: () => taps++, child: const Text('J'))),
      );
      await tester.tap(find.text('J'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(taps, 1);

      await tester.pumpWidget(_host(const FxJellyButton(child: Text('J'))));
      await tester.tap(find.text('J'));
      expect(taps, 1);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxHeartbeatLine', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 200, height: 60, child: FxHeartbeatLine())),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    testWidgets('FxDnaLoader', (tester) async {
      await tester.pumpWidget(_host(const FxDnaLoader()));
      await tester.pump(const Duration(milliseconds: 200));
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
                SizedBox(width: 100, height: 100, child: FxPlasma()),
                SizedBox(width: 100, height: 100, child: FxRain(seed: 1)),
                FxWaveDots(),
                FxBouncingBall(),
                FxShinyText('x'),
                FxGlowButton(child: Text('x')),
                FxJellyButton(child: Text('x')),
                SizedBox(width: 120, height: 40, child: FxDnaLoader()),
                SizedBox(width: 120, height: 60, child: FxHeartbeatLine()),
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
