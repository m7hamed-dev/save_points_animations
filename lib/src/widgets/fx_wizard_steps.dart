import 'package:flutter/widgets.dart';

/// A horizontal, labelled step indicator. Completed steps fill with the accent
/// colour and show a check; the connectors between them fill as you progress.
///
/// ```dart
/// FxWizardSteps(steps: const ['Cart', 'Address', 'Pay'], currentStep: 1);
/// ```
class FxWizardSteps extends StatelessWidget {
  const FxWizardSteps({
    super.key,
    required this.steps,
    required this.currentStep,
    this.accent = const Color(0xFF448AFF),
    this.idleColor = const Color(0xFFD5DCE6),
    this.textColor = const Color(0xFF333333),
    this.circleSize = 30,
  });

  final List<String> steps;
  final int currentStep;
  final Color accent;
  final Color idleColor;
  final Color textColor;
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    final last = steps.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _connector(filled: i <= currentStep && i > 0),
                    ),
                    _circle(i),
                    Expanded(
                      child: _connector(filled: i < currentStep && i < last),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 260),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == currentStep
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i <= currentStep
                        ? textColor
                        : textColor.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  child: Text(steps[i]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _connector({required bool filled}) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 3,
    color: filled ? accent : idleColor,
  );

  Widget _circle(int i) {
    final done = i < currentStep;
    final active = i == currentStep;
    final filled = done || active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: circleSize,
      height: circleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? accent : const Color(0x00000000),
        shape: BoxShape.circle,
        border: Border.all(color: filled ? accent : idleColor, width: 2),
      ),
      child: done
          ? const Text(
              '✓',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            )
          : Text(
              '${i + 1}',
              style: TextStyle(
                color: active ? const Color(0xFFFFFFFF) : idleColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
