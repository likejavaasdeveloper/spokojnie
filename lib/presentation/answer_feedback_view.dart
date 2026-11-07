import 'package:flutter/material.dart';

import '../domain/answer_validation_result.dart';

class AnswerFeedbackView extends StatelessWidget {
  const AnswerFeedbackView({required this.result, super.key});

  final AnswerValidationResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final incorrectIndices = {
      for (final difference in result.differences)
        if (difference.actualIndex != null) difference.actualIndex!,
    };
    final actualCharacters = result.normalizedLearnerAnswer.runes.toList();

    return Card(
      color: result.isCorrect
          ? colorScheme.primaryContainer
          : colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                result.isCorrect ? 'پاسخ درست است' : 'چند تفاوت وجود دارد',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    for (
                      var index = 0;
                      index < actualCharacters.length;
                      index++
                    )
                      TextSpan(
                        text: String.fromCharCode(actualCharacters[index]),
                        style: incorrectIndices.contains(index)
                            ? TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w700,
                                backgroundColor: colorScheme.errorContainer,
                              )
                            : null,
                      ),
                  ],
                ),
              ),
              if (!result.isCorrect) ...[
                const SizedBox(height: 12),
                for (final difference in result.differences)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${difference.expectedFragment.isEmpty ? '∅' : difference.expectedFragment} ← ${difference.actualFragment.isEmpty ? '∅' : difference.actualFragment}',
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
