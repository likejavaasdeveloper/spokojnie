import 'package:flutter/material.dart';

class LessonStepSegment extends StatelessWidget {
  const LessonStepSegment({
    required this.label,
    required this.isActive,
    required this.colorScheme,
    super.key,
  });

  final String label;
  final bool isActive;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
