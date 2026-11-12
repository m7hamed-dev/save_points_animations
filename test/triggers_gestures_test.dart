import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: child),
);

void main() {
  group('triggers', () {
    testWidgets('onTap does not autoplay, then plays on tap', (tester) async {
      await tester.pumpWidget(
        _host(
          const Text('tap me')
              .animate()
              .fade()
              .duration(const Duration(milliseconds: 200))
              .onTap(),
        ),
      );
      await tester.pump();
      // Not started: fully transparent -> an Opacity(0) wrapper exists.
      expect(find.byType(Opacity), findsOneWidget);
      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        closeTo(0.0, 1e-3),
      );

      await tester.tap(find.text('tap me'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Played to the end: wrapper dropped (fully opaque).
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('onVisible plays when on screen at mount', (tester) async {
      await tester.pumpWidget(
        _host(
          const Text('seen')
              .animate()
              .fade()
              .duration(const Duration(milliseconds: 150))
              .onVisible(),
        ),
      );
      await tester.pump(); // post-frame visibility check fires restart
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(Opacity), findsNothing);
    });

    group('onVisible fires once scrolled into view', () {
      Finder opacityOf(String text) =>
          find.ancestor(of: find.text(text), matching: find.byType(Opacity));

      Widget target(String text) => Text(text)
          .animate()
          .fade()
          .duration(const Duration(milliseconds: 150))
          .onVisible();

      Future<void> scrollTo(
        WidgetTester tester,
        Finder scrollable,
        double offset,
      ) async {
        tester.state<ScrollableState>(scrollable).position.jumpTo(offset);
        // Frame 1: layout at the new offset, then the post-frame visibility
        // check restarts the chain; it ticks from the following frame on.
        await tester.pumpAndSettle();
      }

      testWidgets('in an eager vertical scroll view', (tester) async {
        await tester.pumpWidget(
          _host(
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 1500),
                  target('below'),
                  const SizedBox(height: 600),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        // Below the fold: not fired yet, still fully transparent.
        expect(tester.widget<Opacity>(opacityOf('below')).opacity, 0.0);

        await scrollTo(tester, find.byType(Scrollable), 1300);
        expect(opacityOf('below'), findsNothing);
      });

      testWidgets('in a horizontal scroll view', (tester) async {
        await tester.pumpWidget(
          _host(
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 1500, height: 10),
                  target('right'),
                  const SizedBox(width: 900, height: 10),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        // Off-screen to the right: must not fire just because it is
        // vertically within the screen.
        expect(tester.widget<Opacity>(opacityOf('right')).opacity, 0.0);

        await scrollTo(tester, find.byType(Scrollable), 1300);
        expect(opacityOf('right'), findsNothing);
      });

      testWidgets('when an outer (ancestor) scroll view moves', (tester) async {
        await tester.pumpWidget(
          _host(
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 1500),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        target('nested'),
                        const SizedBox(width: 2000, height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 600),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(tester.widget<Opacity>(opacityOf('nested')).opacity, 0.0);

        // Only the outer, vertical scroll view moves.
        await scrollTo(tester, find.byType(Scrollable).first, 1300);
        expect(opacityOf('nested'), findsNothing);
      });
    });

    testWidgets('onAppear renders and plays', (tester) async {
      await tester.pumpWidget(
        _host(const Text('hi').animate().fade().onAppear()),
      );
      expect(find.text('hi'), findsOneWidget);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('gestures', () {
    testWidgets('pressScale scales down while pressed and back on release', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 100, height: 100).pressScale(scale: 0.9)),
      );
      double scale() => tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;

      expect(scale(), closeTo(1.0, 1e-3));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ScaleTransition)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(scale(), lessThan(1.0));

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(scale(), closeTo(1.0, 1e-3));
    });

    testWidgets('hoverScale grows on pointer enter', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 100, height: 100).hoverScale(scale: 1.2)),
      );
      double scale() => tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;
      expect(scale(), closeTo(1.0, 1e-3));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(ScaleTransition)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(scale(), greaterThan(1.0));
    });

    testWidgets('gesture widgets dispose their tickers cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(_host(const SizedBox().pressScale()));
      await tester.pumpWidget(_host(const SizedBox()));
      expect(tester.takeException(), isNull);
    });
  });
}
