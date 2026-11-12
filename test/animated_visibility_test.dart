import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:save_points_animations/save_points_animations.dart';

class _Harness extends StatefulWidget {
  const _Harness();
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool _show = true;
  int _dismissed = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _show = !_show),
            child: const Text('toggle'),
          ),
          Text('dismissed:$_dismissed'),
          FxAnimatedVisibility(
            visible: _show,
            onDismissed: () => setState(() => _dismissed++),
            effects: (a) => a
                .fade()
                .scale(begin: 0.8)
                .duration(const Duration(milliseconds: 200)),
            child: const Text('content'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('animates in on mount and stays present', (tester) async {
    await tester.pumpWidget(const _Harness());
    expect(find.text('content'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('stays in the tree during exit, then is removed', (tester) async {
    await tester.pumpWidget(const _Harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Hide it.
    await tester.tap(find.text('toggle'));
    await tester.pump();
    // Mid-exit: still present.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('content'), findsOneWidget);
    expect(find.text('dismissed:0'), findsOneWidget);

    // Exit completes -> removed + callback fired.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('content'), findsNothing);
    expect(find.text('dismissed:1'), findsOneWidget);
  });

  testWidgets('re-shows after being dismissed', (tester) async {
    await tester.pumpWidget(const _Harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('toggle')); // hide
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('content'), findsNothing);

    await tester.tap(find.text('toggle')); // show again
    await tester.pump();
    expect(find.text('content'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('no leaked tickers after dismissal', (tester) async {
    await tester.pumpWidget(const _Harness());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('toggle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(FxDebugRegistry.activeControllers, 0);
  });
}
