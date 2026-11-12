import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

import 'catalog_harness.dart';

// Accessibility guideline checks for every interactive widget.
//
// Each (widget, guideline) pair is its own test so failures can be skipped
// individually. A skipped test is an accessibility backlog item: its reason
// names the guideline and what is wrong. Remove the entry from [_backlog] once
// fixed.

enum _Check {
  /// Every tappable semantics node has a label.
  labeled('labeledTapTargetGuideline'),

  /// Every tappable node is at least 48x48 (Android guideline).
  tapTarget('androidTapTargetGuideline'),

  /// Text meets WCAG contrast (4.5:1, or 3:1 for large text).
  contrast('textContrastGuideline');

  const _Check(this.guidelineName);

  final String guidelineName;

  AccessibilityGuideline get guideline => switch (this) {
    _Check.labeled => labeledTapTargetGuideline,
    _Check.tapTarget => androidTapTargetGuideline,
    _Check.contrast => textContrastGuideline,
  };
}

const _tap = {_Check.labeled, _Check.tapTarget};
const _tapAndText = {_Check.labeled, _Check.tapTarget, _Check.contrast};

class _Case {
  const _Case(this.name, this.build, {this.checks = _tap});

  final String name;
  final Widget Function() build;
  final Set<_Check> checks;
}

void _noop() {}

Widget _wide(Widget child) => SizedBox(width: 360, child: child);

/// Known failures: `'<Widget>/<check>'` -> reason. This is the a11y backlog;
/// delete an entry once the widget is fixed.
const Map<String, String> _backlog = {
  'FxAnimatedSlider/labeled':
      'labeledTapTargetGuideline: the slider node has a value but no label, '
      'and the widget has no semanticLabel parameter.',
  'FxAnimatedSlider/tapTarget':
      'androidTapTargetGuideline: the slider is 44px tall (default height); '
      'needs >= 48.',
  'FxAnimatedToggle/labeled':
      'labeledTapTargetGuideline: the tappable switch node (button, toggled) '
      'has no label and the widget has no semanticLabel parameter, so it is '
      'announced only as "button, on".',
  'FxAnimatedToggle/tapTarget':
      'androidTapTargetGuideline: tap target is 52x30 (default width x '
      'height); needs >= 48x48 (pad the hit area or raise the default height).',
  'FxThemeToggle/tapTarget':
      'androidTapTargetGuideline: tap target is 76x36 (default height 36); '
      'needs >= 48 tall.',
  'FxAnimatedCheckbox/labeled':
      'labeledTapTargetGuideline: the 24x24 checkbox node has only a checked '
      'state, no label, and no semanticLabel parameter.',
  'FxAnimatedCheckbox/tapTarget':
      'androidTapTargetGuideline: hit area equals the painted box, 24x24 '
      '(default size); needs >= 48x48.',
  'FxAnimatedRadio/labeled':
      'labeledTapTargetGuideline: the 22x22 radio node has no label and no '
      'semanticLabel parameter.',
  'FxAnimatedRadio/tapTarget':
      'androidTapTargetGuideline: hit area equals the painted circle, 22x22 '
      '(default size); needs >= 48x48.',
  'FxSegmentedControl/tapTarget':
      'androidTapTargetGuideline: each segment is 40px tall (default height '
      '40); needs >= 48.',
  'FxAnimatedTabBar/tapTarget':
      'androidTapTargetGuideline: tabs are only 34px tall (10px vertical '
      'padding around the text); needs >= 48.',
  'FxStepper/tapTarget':
      'androidTapTargetGuideline: the decrease/increase buttons are 34x34; '
      'needs >= 48x48.',
  'FxStepper/contrast':
      'textContrastGuideline: the value text (default color #448AFF, 18px '
      'bold) on the default #F0F3F8 background is 2.99:1, below 3:1 for large '
      'text.',
  'FxRating/tapTarget':
      'androidTapTargetGuideline: each star is 32x28 (size 28 + 2px spacing '
      'each side); needs >= 48x48.',
  'FxHeartButton/labeled':
      'labeledTapTargetGuideline: the toggle button has no label and no '
      'semanticLabel parameter; announced only as "button, not toggled".',
  'FxTagChips/tapTarget':
      'androidTapTargetGuideline: chips are 30px tall (8px vertical padding); '
      'needs >= 48.',
  'FxReactionBar/tapTarget':
      'androidTapTargetGuideline: each reaction is ~68x45 (26px emoji + hidden '
      'label row); needs >= 48 tall.',
  'FxWheelPicker/contrast':
      'textContrastGuideline: unselected items (default textColor #888888, '
      '17px) on white are 3.54:1, below 4.5:1.',
  'FxExpandable/tapTarget':
      'androidTapTargetGuideline: the header row has no minimum height (240x14 '
      'with a Text header); needs >= 48.',
  'FxMorphIcon/labeled':
      'labeledTapTargetGuideline: tappable 24x24 icon with no semantics at all '
      '(no label, no button flag) and no semanticLabel parameter.',
  'FxMorphIcon/tapTarget':
      'androidTapTargetGuideline: hit area equals the 24x24 icon; needs >= '
      '48x48.',
  'FxJellyButton/tapTarget':
      'androidTapTargetGuideline: 44px tall with the default padding (14 '
      'vertical); needs >= 48.',
  'FxShimmerButton/tapTarget':
      'androidTapTargetGuideline: 42px tall with the default padding (14 '
      'vertical); needs >= 48.',
  'FxProgressButton/contrast':
      'textContrastGuideline: a white label on the default color #448AFF is '
      '3.32:1, below 4.5:1. Also note the semantics node spans the whole '
      'parent (220x600 here) because Semantics wraps an expanding Align, so '
      'the focus rect does not match the 48px button.',
  'FxAnimatedNavBar/labeled':
      'labeledTapTargetGuideline: items are bare widgets and each Semantics '
      '(button, selected) has no label; the API (List<Widget> items) gives no '
      'way to provide one, unlike the FxNavItem-based bars.',
  'FxPillNavBar/tapTarget':
      'androidTapTargetGuideline: pills are 38px tall (10px vertical '
      'padding); unselected ones are also only 42px wide. Needs >= 48x48.',
  'FxPageIndicator/labeled':
      'labeledTapTargetGuideline: with onDotTapped set, every dot (8x8, active '
      '24x8) is tappable but has no label (e.g. "Page 2 of 3").',
  'FxPageIndicator/tapTarget':
      'androidTapTargetGuideline: tappable dots are 8x8 (active 24x8); needs '
      '>= 48x48.',
  'FxToast/tapTarget':
      'androidTapTargetGuideline: a tappable toast (onTap) is 42px tall with '
      'the default padding; needs >= 48.',
};

final List<_Case> _cases = [
  // ── Controls ──────────────────────────────────────────────────────────
  _Case(
    'FxAnimatedSlider',
    () => SizedBox(
      width: 240,
      child: FxAnimatedSlider(value: 0.4, onChanged: (_) {}),
    ),
  ),
  _Case(
    'FxRangeSlider',
    () => SizedBox(
      width: 240,
      child: FxRangeSlider(values: const FxRange(0.2, 0.7), onChanged: (_) {}),
    ),
  ),
  _Case(
    'FxAnimatedToggle',
    () => FxAnimatedToggle(value: true, onChanged: (_) {}),
  ),
  _Case('FxThemeToggle', () => FxThemeToggle(isDark: false, onChanged: (_) {})),
  _Case(
    'FxAnimatedCheckbox',
    () => FxAnimatedCheckbox(value: true, onChanged: (_) {}),
  ),
  _Case(
    'FxAnimatedRadio',
    () => FxAnimatedRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
  ),
  _Case(
    'FxSegmentedControl',
    () => SizedBox(
      width: 300,
      child: FxSegmentedControl(
        segments: const ['Day', 'Week', 'Month'],
        selectedIndex: 1,
        onChanged: (_) {},
      ),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxAnimatedTabBar',
    () => _wide(
      FxAnimatedTabBar(
        tabs: const ['One', 'Two', 'Three'],
        selectedIndex: 1,
        onChanged: (_) {},
      ),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxStepper',
    () => FxStepper(value: 3, onChanged: (_) {}),
    checks: _tapAndText,
  ),
  _Case('FxRating', () => FxRating(value: 3, onChanged: (_) {})),
  _Case(
    'FxNumberPad',
    () => FxNumberPad(onDigit: (_) {}, onBackspace: _noop),
    checks: _tapAndText,
  ),
  _Case(
    'FxHeartButton',
    () => FxHeartButton(isLiked: false, onChanged: (_) {}),
  ),
  _Case(
    'FxHoldButton',
    () => const FxHoldButton(onConfirmed: _noop, child: Text('Hold')),
    checks: _tapAndText,
  ),
  _Case(
    'FxSlideToConfirm',
    () => const SizedBox(
      width: 280,
      child: FxSlideToConfirm(label: Text('Slide to pay'), onConfirmed: _noop),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxTagChips',
    () => FxTagChips(
      tags: const ['Flutter', 'Dart', 'Motion'],
      selected: const {1},
      onToggle: (_) {},
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxReactionBar',
    () => FxReactionBar(
      reactions: const ['A', 'B', 'C'],
      labels: const ['Like', 'Love', 'Wow'],
      onChanged: (_) {},
    ),
  ),
  _Case(
    'FxDateStrip',
    () => _wide(
      FxDateStrip(
        days: [for (var d = 2; d <= 6; d++) DateTime(2026, 3, d)],
        selected: DateTime(2026, 3, 4),
        onChanged: (_) {},
      ),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxWheelPicker',
    () => SizedBox(
      width: 200,
      child: FxWheelPicker(
        items: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        selectedIndex: 2,
        onChanged: (_) {},
      ),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxColorWheel',
    () => FxColorWheel(color: const Color(0xFF448AFF), onChanged: (_) {}),
  ),
  _Case(
    'FxExpandable',
    () => const SizedBox(
      width: 240,
      child: FxExpandable(header: Text('Details'), body: Text('Body')),
    ),
    checks: _tapAndText,
  ),
  _Case('FxMorphIcon', () => const FxMorphIcon(isOpen: false, onTap: _noop)),
  _Case(
    'FxFloatingField',
    () => const SizedBox(width: 240, child: FxFloatingField(label: 'Email')),
    checks: _tapAndText,
  ),

  // ── Buttons ───────────────────────────────────────────────────────────
  _Case(
    'FxGlowButton',
    () => const FxGlowButton(onPressed: _noop, child: Text('Glow')),
    checks: _tapAndText,
  ),
  _Case(
    'FxGradientButton',
    () => const FxGradientButton(onPressed: _noop, child: Text('Gradient')),
    checks: _tapAndText,
  ),
  _Case(
    'FxJellyButton',
    () => const FxJellyButton(onPressed: _noop, child: Text('Jelly')),
    checks: _tapAndText,
  ),
  _Case(
    'FxShimmerButton',
    () => const FxShimmerButton(onPressed: _noop, child: Text('Shimmer')),
    checks: _tapAndText,
  ),
  _Case(
    'FxMagneticButton',
    () => FxMagneticButton(
      onTap: _noop,
      child: catalogSwatch(
        const Color(0xFF6A11CB),
        width: 120,
        height: 48,
        child: const Text('Magnet', style: TextStyle(color: Color(0xFFFFFFFF))),
      ),
    ),
    checks: _tapAndText,
  ),
  _Case(
    'FxProgressButton',
    () => const SizedBox(
      width: 220,
      child: FxProgressButton(
        state: FxButtonState.idle,
        onPressed: _noop,
        child: Text('Submit', style: TextStyle(color: Color(0xFFFFFFFF))),
      ),
    ),
    checks: _tapAndText,
  ),

  // ── Navigation ────────────────────────────────────────────────────────
  _Case(
    'FxAnimatedNavBar',
    () => _wide(
      FxAnimatedNavBar(
        items: [for (final i in catalogNavItems()) i.icon],
        currentIndex: 0,
        onTap: (_) {},
      ),
    ),
  ),
  _Case(
    'FxCurvedNavBar',
    () => _wide(
      FxCurvedNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
    ),
  ),
  _Case(
    'FxDotNavBar',
    () => _wide(
      FxDotNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
    ),
  ),
  _Case(
    'FxFrostedNavBar',
    () => _wide(
      FxFrostedNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
    ),
  ),
  _Case(
    'FxGooeyNavBar',
    () => _wide(
      FxGooeyNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
    ),
  ),
  _Case(
    'FxPillNavBar',
    () => _wide(
      FxPillNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
    ),
    checks: _tapAndText,
  ),
  _Case('FxPageIndicator', () => const _OwnedPageIndicator()),
  _Case(
    'FxCircularMenu',
    () => FxCircularMenu(
      icon: const CatalogGlyph(),
      children: [
        for (var i = 0; i < 3; i++)
          GestureDetector(
            onTap: _noop,
            child: catalogSwatch(
              const Color(0xFFEC008C),
              width: 48,
              height: 48,
              child: Text('A$i'),
            ),
          ),
      ],
    ),
  ),
  _Case(
    'FxSpeedDial',
    () => const FxSpeedDial(icon: CatalogGlyph(), children: [Text('Share')]),
  ),
  _Case(
    'FxToast',
    () => const FxToast(visible: true, onTap: _noop, child: Text('Saved')),
    checks: _tapAndText,
  ),
  _Case(
    'FxRipple',
    () => FxRipple(
      onTap: _noop,
      child: catalogSwatch(
        const Color(0xFF00C9A7),
        width: 160,
        height: 80,
        child: const Text('Tap'),
      ),
    ),
  ),
  _Case(
    'FxFlipCard',
    () => FxFlipCard(
      front: catalogSwatch(
        const Color(0xFF6A11CB),
        width: 160,
        height: 90,
        child: const Text('Front', style: TextStyle(color: Color(0xFFFFFFFF))),
      ),
      back: const Text('Back'),
    ),
  ),
];

/// Owns (and disposes) the [PageController] an [FxPageIndicator] needs.
class _OwnedPageIndicator extends StatefulWidget {
  const _OwnedPageIndicator();

  @override
  State<_OwnedPageIndicator> createState() => _OwnedPageIndicatorState();
}

class _OwnedPageIndicatorState extends State<_OwnedPageIndicator> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FxPageIndicator(controller: _controller, count: 3, onDotTapped: (_) {});
}

/// Pumps [child] with semantics enabled and lets entrance animations settle.
Future<SemanticsHandle> _pumpSemantics(
  WidgetTester tester,
  Widget child,
) async {
  final handle = tester.ensureSemantics();
  await tester.pumpWidget(catalogHost(child));
  await tester.pump(const Duration(milliseconds: 600));
  return handle;
}

/// What a screen reader would actually get — beyond the generic guidelines.
void _semanticsBehavior() {
  // ── Expected to pass: state is exposed correctly ──────────────────────
  testWidgets('FxAnimatedToggle exposes button + toggled state', (
    tester,
  ) async {
    final handle = await _pumpSemantics(
      tester,
      FxAnimatedToggle(value: true, onChanged: (_) {}),
    );
    expect(
      tester.getSemantics(find.byType(FxAnimatedToggle)),
      isSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('FxAnimatedCheckbox exposes checked/enabled state', (
    tester,
  ) async {
    final handle = await _pumpSemantics(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FxAnimatedCheckbox(
            key: const ValueKey('on'),
            value: true,
            onChanged: (_) {},
          ),
          const FxAnimatedCheckbox(
            key: ValueKey('disabled'),
            value: false,
            onChanged: null,
          ),
        ],
      ),
    );
    // The widget's own render object (a RepaintBoundary) sits above its
    // Semantics, so resolve the node from the painted box inside it.
    Finder painted(String key) => find
        .descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(CustomPaint),
        )
        .last; // the control's own painter (the focus ring paints above it)
    expect(
      tester.getSemantics(painted('on')),
      isSemantics(
        hasCheckedState: true,
        isChecked: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(painted('disabled')),
      isSemantics(
        hasCheckedState: true,
        isChecked: false,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('FxAnimatedRadio is in a mutually exclusive group', (
    tester,
  ) async {
    final handle = await _pumpSemantics(
      tester,
      FxAnimatedRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}),
    );
    expect(
      tester.getSemantics(
        find
            .descendant(
              of: find.byType(FxAnimatedRadio<int>),
              matching: find.byType(CustomPaint),
            )
            .last,
      ),
      isSemantics(
        isInMutuallyExclusiveGroup: true,
        hasCheckedState: true,
        isChecked: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('FxNavItem-based bars mark the current item selected', (
    tester,
  ) async {
    final handle = await _pumpSemantics(
      tester,
      _wide(
        FxDotNavBar(items: catalogNavItems(), currentIndex: 1, onTap: (_) {}),
      ),
    );
    expect(
      find.semantics.byLabel('Search'),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );
    expect(
      find.semantics.byLabel('Home'),
      isSemantics(isButton: true, isSelected: false),
    );
    handle.dispose();
  });

  testWidgets('FxExpandable exposes and updates its expanded state', (
    tester,
  ) async {
    final handle = await _pumpSemantics(
      tester,
      const SizedBox(
        width: 240,
        child: FxExpandable(header: Text('Details'), body: Text('Body')),
      ),
    );
    final header = find.semantics.byLabel('Details');
    expect(header, isSemantics(hasExpandedState: true, isExpanded: false));
    tester.semantics.tap(header);
    await tester.pumpAndSettle();
    expect(header, isSemantics(hasExpandedState: true, isExpanded: true));
    handle.dispose();
  });

  testWidgets('FxSwipeToDismiss offers a dismiss action that dismisses', (
    tester,
  ) async {
    var dismissed = 0;
    final handle = await _pumpSemantics(
      tester,
      SizedBox(
        width: 200,
        child: FxSwipeToDismiss(
          onDismissed: () => dismissed++,
          child: const Text('Swipe me'),
        ),
      ),
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Swipe me'),
      SemanticsAction.dismiss,
    );
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    handle.dispose();
  });

  testWidgets('FxProgressButton announces its busy state', (tester) async {
    final handle = await _pumpSemantics(
      tester,
      const SizedBox(
        width: 220,
        child: FxProgressButton(
          state: FxButtonState.loading,
          onPressed: _noop,
          child: Text('Submit'),
        ),
      ),
    );
    expect(
      find.semantics.byLabel('Loading'),
      isSemantics(
        isButton: true,
        isEnabled: false,
        isLiveRegion: true,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  // ── Backlog: expected to fail today ───────────────────────────────────
  for (final (name, label, build) in <(String, String, Widget Function())>[
    (
      'FxSegmentedControl',
      'Week',
      () => SizedBox(
        width: 300,
        child: FxSegmentedControl(
          segments: const ['Day', 'Week', 'Month'],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      ),
    ),
    (
      'FxAnimatedTabBar',
      'Two',
      () => _wide(
        FxAnimatedTabBar(
          tabs: const ['One', 'Two', 'Three'],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
      ),
    ),
    (
      'FxTagChips',
      'Dart',
      () => FxTagChips(
        tags: const ['Flutter', 'Dart'],
        selected: const {1},
        onToggle: (_) {},
      ),
    ),
    (
      'FxPillNavBar',
      'Home',
      () => _wide(
        FxPillNavBar(items: catalogNavItems(), currentIndex: 0, onTap: (_) {}),
      ),
    ),
    ('FxNumberPad', '7', () => FxNumberPad(onDigit: (_) {})),
  ]) {
    catalogTestWidgets(
      '$name announces "$label" once',
      (tester) async {
        final handle = await _pumpSemantics(tester, build());
        expect(
          find.semantics.byLabel(label),
          findsOne,
          reason: 'the tappable node label should be exactly "$label"',
        );
        handle.dispose();
      },
      skip:
          'BUG $name: the label is announced twice ("$label\\n$label"). The '
          'item wraps a Text("$label") in Semantics(label: "$label") without '
          'excludeSemantics, so the visible text is merged into the explicit '
          'label.${name == 'FxNumberPad' ? ' Every key is affected (the '
                    'backspace key reads "Backspace\\n⌫").' : ''}',
    );
  }

  catalogTestWidgets(
    'FxStepper buttons are announced as "Increase" / "Decrease"',
    (tester) async {
      final handle = await _pumpSemantics(
        tester,
        FxStepper(value: 3, onChanged: (_) {}),
      );
      expect(find.semantics.byLabel('Increase'), findsOne);
      expect(find.semantics.byLabel('Decrease'), findsOne);
      handle.dispose();
    },
    skip:
        'FxStepper: the glyph text is merged into the button labels, giving '
        '"Increase\\n+" and "Decrease\\n−" (the minus sign is read aloud). '
        'The glyph should be excluded from semantics.',
  );

  catalogTestWidgets(
    'FxHoldButton can be confirmed via the semantics tap action',
    (tester) async {
      var confirmed = 0;
      final handle = await _pumpSemantics(
        tester,
        FxHoldButton(
          onConfirmed: () => confirmed++,
          child: const Text('Delete'),
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Delete'));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(confirmed, 1);
      handle.dispose();
    },
  );

  catalogTestWidgets(
    'FxSlideToConfirm exposes an action that confirms',
    (tester) async {
      final handle = await _pumpSemantics(
        tester,
        const SizedBox(
          width: 280,
          child: FxSlideToConfirm(
            label: Text('Slide to pay'),
            onConfirmed: _noop,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(FxSlideToConfirm)),
        isSemantics(isButton: true, hasTapAction: true),
      );
      handle.dispose();
    },
    skip:
        'FxSlideToConfirm: the node is an enabled button labelled "Slide to '
        'confirm" but its only actions are scrollLeft/scrollRight, synthesized '
        'from the thumb drag recognizer; each moves the thumb ~0.8 thumb-widths '
        'and releases, so it springs back below the 90% threshold. A screen '
        'reader user cannot confirm. The hard-coded label also ignores the '
        'visible `label` widget.',
  );

  catalogTestWidgets(
    'FxColorWheel can be adjusted without dragging',
    (tester) async {
      final handle = await _pumpSemantics(
        tester,
        FxColorWheel(color: const Color(0xFF448AFF), onChanged: (_) {}),
      );
      expect(
        tester.getSemantics(find.byType(FxColorWheel)),
        isSemantics(hasIncreaseAction: true, hasDecreaseAction: true),
      );
      handle.dispose();
    },
    skip:
        'FxColorWheel: pan-only control. Its node has no label, value, or '
        'increase/decrease actions, only the generic scrollUp/Down/Left/Right '
        'synthesized from the pan recognizer, so it cannot be operated '
        'meaningfully with a screen reader or keyboard.',
  );

  catalogTestWidgets('FxMagneticButton is exposed as a button', (tester) async {
    final handle = await _pumpSemantics(
      tester,
      const FxMagneticButton(onTap: _noop, child: Text('Magnet')),
    );
    expect(
      find.semantics.byLabel('Magnet'),
      isSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  catalogTestWidgets(
    'read-only FxRating (onChanged: null) exposes no tap action',
    (tester) async {
      final handle = await _pumpSemantics(tester, const FxRating(value: 3));
      expect(
        find.semantics.byLabel('Rate 2'),
        isSemantics(hasTapAction: false),
      );
      handle.dispose();
    },
    skip:
        'FxRating: with onChanged == null each star still wraps a '
        'GestureDetector(onTap: …) (the handler just returns), so screen '
        'readers announce a tappable "Rate N" that does nothing.',
  );

  catalogTestWidgets(
    'FxProgressButton semantics rect matches the visible button',
    (tester) async {
      final handle = await _pumpSemantics(
        tester,
        const SizedBox(
          width: 220,
          child: FxProgressButton(
            state: FxButtonState.idle,
            onPressed: _noop,
            child: Text('Submit'),
          ),
        ),
      );
      final node = find.semantics.byLabel('Submit').evaluate().single;
      expect(node.rect.size, const Size(220, 48));
      handle.dispose();
    },
    skip:
        'FxProgressButton: Semantics wraps an expanding Align, so the node '
        '(focus rect / tap target) fills the parent — 220x600 in a Center — '
        'instead of the 220x48 button.',
  );
}

// FxScrollToTop only exists in the semantics tree once visible, so it gets a
// dedicated scrolling setup below.

void main() {
  for (final c in _cases) {
    group(c.name, () {
      for (final check in _Check.values.where(c.checks.contains)) {
        catalogTestWidgets(check.guidelineName, (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(catalogHost(c.build()));
          await tester.pump(const Duration(milliseconds: 600));
          await expectLater(tester, meetsGuideline(check.guideline));
          handle.dispose();
        }, skip: _backlog['${c.name}/${check.name}']);
      }
    });
  }

  group('semantics behavior', _semanticsBehavior);

  group('FxScrollToTop (visible after scrolling)', () {
    for (final check in [_Check.labeled, _Check.tapTarget]) {
      catalogTestWidgets(check.guidelineName, (tester) async {
        final handle = tester.ensureSemantics();
        final controller = ScrollController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          catalogHost(
            Stack(
              children: [
                ListView(
                  controller: controller,
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(height: 50, child: Text('Row $i')),
                  ],
                ),
                FxScrollToTop(controller: controller),
              ],
            ),
            center: false,
          ),
        );
        controller.jumpTo(600);
        await tester.pumpAndSettle();
        expect(find.semantics.byLabel(RegExp('Scroll to top')), findsOne);
        await expectLater(tester, meetsGuideline(check.guideline));
        handle.dispose();
      }, skip: _backlog['FxScrollToTop/${check.name}']);
    }
  });
}
