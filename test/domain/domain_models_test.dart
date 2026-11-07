import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/domain/domain_validation_exception.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson_catalog.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';

void main() {
  test('rejects an empty lesson identifier', () {
    expect(
      () => Lesson(id: ' ', items: [_learningItem()]),
      throwsA(isA<DomainValidationException>()),
    );
  });

  test('rejects blank recall content', () {
    expect(
      () => RecallStep(prompt: 'Prompt.', answer: ' '),
      throwsA(isA<DomainValidationException>()),
    );
  });

  test('requires all learning item steps', () {
    expect(
      () => LearningItem(
        id: 'item_001',
        understand: UnderstandStep(
          sentence: 'Sentence.',
          translation: 'Translation.',
          vocabulary: const [],
        ),
        recall: RecallStep(prompt: 'Prompt.', answer: 'Answer.'),
        variation: VariationStep(
          prompt: 'Prompt.',
          answer: 'Answer.',
          translation: 'Translation.',
        ),
      ),
      returnsNormally,
    );
  });

  test('rejects duplicate lesson identifiers in a catalog', () {
    expect(
      () => LessonCatalog(
        lessons: [
          LessonSummary(
            id: 'lesson_001',
            title: 'First',
            access: LessonAccess.free,
          ),
          LessonSummary(
            id: 'lesson_001',
            title: 'Duplicate',
            access: LessonAccess.protected,
          ),
        ],
      ),
      throwsA(isA<DomainValidationException>()),
    );
  });
}

LearningItem _learningItem() {
  return LearningItem(
    id: 'item_001',
    understand: UnderstandStep(
      sentence: 'Sentence.',
      translation: 'Translation.',
      vocabulary: const [],
    ),
    recall: RecallStep(prompt: 'Prompt.', answer: 'Answer.'),
    variation: VariationStep(
      prompt: 'Prompt.',
      answer: 'Answer.',
      translation: 'Translation.',
    ),
  );
}
