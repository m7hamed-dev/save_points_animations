import 'package:material_ui/material_ui.dart';

/// A simple colored square used throughout the gallery to show off effects.
class DemoChip extends StatelessWidget {
  const DemoChip({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
