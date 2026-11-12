// Shared fixtures for the widget catalog tests (goldens, accessibility and
// interaction). Not a test file itself — it has no `_test` suffix.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// Light stage background used by most goldens and a11y checks.
const Color kCatalogLight = Color(0xFFFFFFFF);

/// Dark stage background for effects that paint light-on-dark.
const Color kCatalogDark = Color(0xFF101828);

/// A neutral, font-free stand-in for an icon. It paints a rounded square in the
/// ambient [IconTheme] color, so nav bars still show their selected/unselected
/// tint without depending on the Material icon font (which isn't loaded in
/// tests and would make goldens platform-sensitive).
class CatalogGlyph extends StatelessWidget {
  const CatalogGlyph({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? const Color(0xFF444444);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 4),
      ),
    );
  }
}

/// Labels for [catalogNavItems]; item `i`'s icon has key `ValueKey('nav-$i')`.
const List<String> kCatalogNavLabels = ['Home', 'Search', 'Likes', 'Profile'];

/// Four nav items whose icons are keyed `nav-0` … `nav-3` for tapping.
List<FxNavItem> catalogNavItems() => [
  for (var i = 0; i < kCatalogNavLabels.length; i++)
    FxNavItem(
      icon: CatalogGlyph(key: ValueKey('nav-$i')),
      label: kCatalogNavLabels[i],
    ),
];

/// A solid swatch (cards, avatars, images, carousel pages …).
Widget catalogSwatch(
  Color color, {
  double? width,
  double? height,
  double radius = 12,
  Widget? child,
  Key? key,
}) => Container(
  key: key,
  width: width,
  height: height,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
  ),
  child: child,
);

/// Wraps [child] in the minimal, deterministic ambient environment the
/// widgets need: a fixed [MediaQuery] (no text scaling; motion enabled unless
/// [disableAnimations]), left-to-right [Directionality], a neutral
/// [DefaultTextStyle] (default test font) and an opaque [background].
///
/// No Material/Cupertino ancestors are added on purpose — the package's
/// widgets are built on `package:flutter/widgets.dart` only, so the catalog
/// also verifies they work without an app shell.
Widget catalogHost(
  Widget child, {
  Color background = kCatalogLight,
  bool disableAnimations = false,
  bool center = true,
}) {
  return MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.noScaling,
      disableAnimations: disableAnimations,
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
        child: ColoredBox(
          color: background,
          child: center ? Center(child: child) : child,
        ),
      ),
    ),
  );
}

/// When true, tests registered with a `skip` reason run anyway. Use it to
/// re-check the bug / accessibility backlog after fixing widgets:
///
///     flutter test test/catalog --dart-define=CATALOG_RUN_SKIPPED=true
///
/// A backlog test that now passes means its `skip` can be removed.
const bool kCatalogRunSkipped = bool.fromEnvironment('CATALOG_RUN_SKIPPED');

/// Like [testWidgets], but when [skip] is non-null the test is registered as
/// skipped with that human-readable reason.
///
/// `testWidgets` only accepts a boolean `skip`, so the reason is attached to an
/// enclosing [group] instead, which `package:test` reports as
/// `Skip: <reason>`. The body still compiles and is analyzed, so it can be
/// un-skipped as soon as the underlying bug is fixed (see [kCatalogRunSkipped]).
void catalogTestWidgets(
  String description,
  WidgetTesterCallback callback, {
  String? skip,
  bool semanticsEnabled = true,
}) {
  void register() =>
      testWidgets(description, callback, semanticsEnabled: semanticsEnabled);
  if (skip == null || kCatalogRunSkipped) {
    register();
  } else {
    group(description, register, skip: skip);
  }
}
