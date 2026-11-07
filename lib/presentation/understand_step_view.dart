import 'package:flutter/material.dart';

import '../domain/understand_step.dart';

class UnderstandStepView extends StatelessWidget {
  const UnderstandStepView({
    required this.step,
    required this.onContinue,
    super.key,
  });

  final UnderstandStep step;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            step.sentence,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.translation,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(height: 1.7),
          ),
          const SizedBox(height: 28),
          Text(
            'واژگان',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final entry in step.vocabulary)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.meaning, textAlign: TextAlign.right),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        entry.word,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onContinue, child: const Text('ادامه')),
        ],
      ),
    );
  }
}
