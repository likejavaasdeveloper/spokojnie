import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/lesson_unlock_failure.dart';
import 'package:spokojnie/application/protected_lesson_repository.dart';
import 'package:spokojnie/application/unlock_lesson.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';

void main() {
  test('unlocks a protected lesson through the protected port', () async {
    final repository = _FakeProtectedLessonRepository();
    final lesson = await UnlockLesson(
      repository,
    ).call(_summary('lesson_003'), 'private-password');

    expect(lesson.id, 'lesson_003');
    expect(repository.requestedIds, ['lesson_003']);
  });

  test('does not send a free lesson to the protected port', () async {
    final repository = _FakeProtectedLessonRepository();

    await expectLater(
      UnlockLesson(
        repository,
      ).call(_summary('lesson_001', free: true), 'password'),
      throwsA(isA<LessonUnlockFailure>()),
    );
    expect(repository.requestedIds, isEmpty);
  });

  test(
    'converts repository failures into controlled unlock failures',
    () async {
      final repository = _FakeProtectedLessonRepository(failure: Exception());

      await expectLater(
        UnlockLesson(repository).call(_summary('lesson_004'), 'password'),
        throwsA(isA<LessonUnlockFailure>()),
      );
    },
  );

  test('keeps protected lesson requests independent', () async {
    final repository = _FakeProtectedLessonRepository();
    final useCase = UnlockLesson(repository);

    await useCase(_summary('lesson_003'), 'password-3');
    await useCase(_summary('lesson_004'), 'password-4');

    expect(repository.requestedIds, ['lesson_003', 'lesson_004']);
    expect(repository.requestedPasswords, ['password-3', 'password-4']);
  });
}

LessonSummary _summary(String id, {bool free = false}) {
  return LessonSummary(
    id: id,
    title: id,
    access: free ? LessonAccess.free : LessonAccess.protected,
  );
}

class _FakeProtectedLessonRepository implements ProtectedLessonRepository {
  _FakeProtectedLessonRepository({this.failure});

  final Object? failure;
  final requestedIds = <String>[];
  final requestedPasswords = <String>[];

  @override
  Future<Lesson> unlock(LessonSummary lesson, String password) async {
    requestedIds.add(lesson.id);
    requestedPasswords.add(password);
    if (failure != null) {
      throw failure!;
    }
    return _lesson(lesson.id);
  }
}

Lesson _lesson(String id) {
  return Lesson(
    id: id,
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
