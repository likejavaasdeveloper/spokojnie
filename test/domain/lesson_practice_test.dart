import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_practice.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/learning_step.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';

void main() {
  test('advances through all steps and items in order', () {
    final practice = LessonPractice(_lesson());

    expect(practice.step, LearningStep.understand);
    expect(practice.currentItem.id, 'item_001');

    practice.advance();
    expect(practice.step, LearningStep.recall);
    practice.advance();
    expect(practice.step, LearningStep.variation);
    practice.advance();

    expect(practice.currentItem.id, 'item_002');
    expect(practice.step, LearningStep.understand);

    practice.advance();
    practice.advance();
    practice.advance();

    expect(practice.isComplete, isTrue);
  });

  test('restarts from the first item and step', () {
    final practice = LessonPractice(_lesson());

    practice.advance();
    practice.advance();
    practice.advance();
    practice.restart();

    expect(practice.isComplete, isFalse);
    expect(practice.currentItem.id, 'item_001');
    expect(practice.step, LearningStep.understand);
  });
}

Lesson _lesson() {
  return Lesson(
    id: 'lesson_001',
    items: [_item('item_001'), _item('item_002')],
  );
}

LearningItem _item(String id) {
  return LearningItem(
    id: id,
    understand: UnderstandStep(
      sentence: 'Sentence.',
      translation: 'Translation.',
      vocabulary: const [],
    ),
    recall: RecallStep(prompt: 'Prompt.', answer: 'Answer.'),
    variation: VariationStep(
      prompt: 'Variation prompt.',
      answer: 'Variation answer.',
      translation: 'Variation translation.',
    ),
  );
}
