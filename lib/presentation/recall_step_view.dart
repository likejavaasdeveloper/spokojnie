import 'package:flutter/material.dart';

import '../domain/answer_validation_result.dart';
import '../domain/recall_step.dart';
import 'answer_feedback_view.dart';
import 'revealed_answer_card.dart';

class RecallStepView extends StatelessWidget {
  const RecallStepView({
    required this.step,
    required this.answerController,
    required this.answerRevealed,
    required this.validationResult,
    required this.onRevealAnswer,
    required this.onCheckAnswer,
    required this.onRetry,
    required this.onContinue,
    super.key,
  });

  final RecallStep step;
  final TextEditingController answerController;
  final bool answerRevealed;
  final AnswerValidationResult? validationResult;
  final VoidCallback onRevealAnswer;
  final VoidCallback onCheckAnswer;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            step.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: answerController,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'پاسخ شما (اختیاری)',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onCheckAnswer,
            child: const Text('بررسی پاسخ'),
          ),
          if (validationResult != null) ...[
            const SizedBox(height: 16),
            AnswerFeedbackView(result: validationResult!),
          ],
          if (validationResult != null && !validationResult!.isCorrect)
            TextButton(onPressed: onRetry, child: const Text('تلاش دوباره')),
          const SizedBox(height: 20),
          if (answerRevealed)
            RevealedAnswerCard(answer: step.answer)
          else
            OutlinedButton(
              onPressed: onRevealAnswer,
              child: const Text('نمایش پاسخ'),
            ),
          const SizedBox(height: 20),
          FilledButton(onPressed: onContinue, child: const Text('ادامه')),
        ],
      ),
    );
  }
}
