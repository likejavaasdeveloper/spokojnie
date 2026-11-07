import 'package:flutter/material.dart';

import '../domain/learning_step.dart';
import 'lesson_step_segment.dart';

class LessonStepIndicator extends StatelessWidget {
  const LessonStepIndicator({required this.currentStep, super.key});

  final LearningStep currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        LessonStepSegment(
          label: 'درک',
          isActive: currentStep == LearningStep.understand,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        LessonStepSegment(
          label: 'یادآوری',
          isActive: currentStep == LearningStep.recall,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        LessonStepSegment(
          label: 'تغییر',
          isActive: currentStep == LearningStep.variation,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}
