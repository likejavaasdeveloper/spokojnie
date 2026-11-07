import 'package:flutter/material.dart';

class RevealedAnswerCard extends StatelessWidget {
  const RevealedAnswerCard({required this.answer, super.key});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          answer,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
