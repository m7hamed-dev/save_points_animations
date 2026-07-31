import 'package:flutter/material.dart';
import 'package:save_points_animations/save_points_animations.dart';

/// The destination pushed by the page-transition and Hero demos.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Hero grows from the list tile's small square.
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(28),
              ),
            ).heroAnimate('detail-hero'),
            const SizedBox(height: 24),
            const Text(
              'Arrived via shared-axis',
            ).animate().fadeIn().slideY(0.3).duration(500.ms),
          ],
        ),
      ),
    );
  }
}
