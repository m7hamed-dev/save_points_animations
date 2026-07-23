import 'package:flutter/widgets.dart';

/// A single destination for the animated bottom nav bars (`FxPillNavBar`,
/// `FxCurvedNavBar`).
class FxNavItem {
  const FxNavItem({required this.icon, required this.label});

  /// The icon widget (e.g. `Icon(Icons.home)`).
  final Widget icon;

  /// The label shown when the item is selected (pill) or for accessibility.
  final String label;
}
