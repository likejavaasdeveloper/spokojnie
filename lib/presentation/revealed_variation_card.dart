import 'package:flutter/material.dart';

class RevealedVariationCard extends StatelessWidget {
  const RevealedVariationCard({
    required this.answer,
    required this.translation,
    super.key,
  });

  final String answer;
  final String translation;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              answer,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(translation, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
