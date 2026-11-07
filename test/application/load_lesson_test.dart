import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/lesson_content_repository.dart';
import 'package:spokojnie/application/load_lesson.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';

void main() {
  test('loads a lesson through the content-access contract', () async {
    final expectedLesson = _lesson();
    final useCase = LoadLesson(_FakeLessonContentRepository(expectedLesson));

    final lesson = await useCase(_freeSummary());

    expect(lesson, same(expectedLesson));
  });
}

Lesson _lesson() {
  return Lesson(
    id: 'lesson_001',
    items: [
      LearningItem(
        id: 'item_001',
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
      ),
    ],
  );
}

class _FakeLessonContentRepository implements LessonContentRepository {
  _FakeLessonContentRepository(this.lesson);

  final Lesson lesson;

  @override
  Future<Lesson> loadFree(LessonSummary lessonSummary) async => lesson;
}

LessonSummary _freeSummary() {
  return LessonSummary(
    id: 'lesson_001',
    title: 'Lesson',
    access: LessonAccess.free,
  );
}
