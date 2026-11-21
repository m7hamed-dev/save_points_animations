import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child, {bool reduceMotion = false}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: child),
    ),
  );
}

Widget _glow({
  FxGlowStyle style = FxGlowStyle.pulse,
  BoxShape shape = BoxShape.rectangle,
  Duration? duration,
  Widget child = const SizedBox(width: 120, height: 60),
}) => FxGlow(style: style, shape: shape, duration: duration, child: child);

/// The glow's painter, which paints both the halo and the border lights.
RenderObject _painter(WidgetTester tester) => tester.renderObject(
  find.descendant(of: find.byType(FxGlow), matching: find.byType(CustomPaint)),
);

Future<void> _frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('every style', () {
    for (final style in FxGlowStyle.values) {
      for (final shape in BoxShape.values) {
        testWidgets('${style.name} (${shape.name}) glows around the child '
            'without resizing it', (tester) async {
          await tester.pumpWidget(_host(_glow(style: style, shape: shape)));
          await _frames(tester);
          expect(tester.getSize(find.byType(FxGlow)), const Size(120, 60));
          expect(_painter(tester), paints..rrect());
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('${style.name} holds a still frame under reduced motion', (
        tester,
      ) async {
        await tester.pumpWidget(_host(_glow(style: style), reduceMotion: true));
        await tester.pump();
        expect(tester.hasRunningAnimations, isFalse);
        expect(_painter(tester), paints..rrect());
      });
    }
  });

  testWidgets('the looping styles keep animating, hover rests until pointed '
      'at', (tester) async {
    for (final style in FxGlowStyle.values) {
      await tester.pumpWidget(_host(_glow(style: style)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.hasRunningAnimations,
        style != FxGlowStyle.hover,
        reason: style.name,
      );
    }
  });

  testWidgets('turning reduced motion on and off stops and restarts the loop', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_glow(style: FxGlowStyle.aurora)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(
      _host(_glow(style: FxGlowStyle.aurora), reduceMotion: true),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(_host(_glow(style: FxGlowStyle.aurora)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('switching the style swaps the loop', (tester) async {
    await tester.pumpWidget(_host(_glow()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(_host(_glow(style: FxGlowStyle.hover)));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(
      _host(
        _glow(
          style: FxGlowStyle.orbit,
          duration: const Duration(milliseconds: 600),
        ),
      ),
    );
    await _frames(tester, 5);
    expect(tester.hasRunningAnimations, isTrue);
    expect(tester.takeException(), isNull);
  });

  group('hover', () {
    testWidgets('lights up under the mouse and fades when it leaves', (
      tester,
    ) async {
      await tester.pumpWidget(_host(_glow(style: FxGlowStyle.hover)));
      // At rest: only the faint halo.
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 1));

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(FxGlow)));
      await tester.pumpAndSettle();
      // The halo, the glow under the pointer and the lit border.
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 3));

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 1));
    });

    testWidgets('flares on a touch press', (tester) async {
      await tester.pumpWidget(_host(_glow(style: FxGlowStyle.hover)));
      final touch = await tester.startGesture(
        tester.getCenter(find.byType(FxGlow)),
      );
      await tester.pumpAndSettle();
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 3));

      await touch.up();
      await tester.pumpAndSettle();
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 1));
    });

    testWidgets('changes at once under reduced motion', (tester) async {
      await tester.pumpWidget(
        _host(_glow(style: FxGlowStyle.hover), reduceMotion: true),
      );
      final touch = await tester.startGesture(
        tester.getCenter(find.byType(FxGlow)),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(_painter(tester), paintsExactlyCountTimes(#drawRRect, 3));
      await touch.up();
    });
  });

  testWidgets('animating the glow does not repaint the child', (tester) async {
    final paints = <int>[0];
    await tester.pumpWidget(
      _host(_glow(style: FxGlowStyle.aurora, child: _CountPaints(paints))),
    );
    await _frames(tester, 20);
    expect(paints.single, 1);
  });

  testWidgets('keeps the child interactive and its semantics', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        FxGlow(
          style: FxGlowStyle.neon,
          child: GestureDetector(
            onTap: () => taps++,
            child: const SizedBox(width: 120, height: 60, child: Text('Go')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Go'), findsOneWidget);
  });

  testWidgets('.fxGlow() wraps the child', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 40,
          height: 40,
        ).fxGlow(style: FxGlowStyle.beacon, shape: BoxShape.circle),
      ),
    );
    final glow = tester.widget<FxGlow>(find.byType(FxGlow));
    expect(glow.style, FxGlowStyle.beacon);
    expect(glow.shape, BoxShape.circle);
    expect(glow.child, isA<SizedBox>());
  });

  test('rejects a negative spread or intensity', () {
    expect(
      () => FxGlow(spread: -1, child: const SizedBox()),
      throwsAssertionError,
    );
    expect(
      () => FxGlow(intensity: -1, child: const SizedBox()),
      throwsAssertionError,
    );
  });
}

/// Counts its own paints in [count]'s single slot.
class _CountPaints extends LeafRenderObjectWidget {
  const _CountPaints(this.count);

  final List<int> count;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCountPaints(count);
}

class _RenderCountPaints extends RenderBox {
  _RenderCountPaints(this.count);

  final List<int> count;

  @override
  void performLayout() => size = constraints.constrain(const Size(120, 60));

  @override
  void paint(PaintingContext context, Offset offset) => count[0]++;
}
