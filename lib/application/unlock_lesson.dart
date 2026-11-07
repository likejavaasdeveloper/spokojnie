import '../domain/lesson.dart';
import '../domain/lesson_access.dart';
import '../domain/lesson_summary.dart';
import 'lesson_unlock_failure.dart';
import 'protected_lesson_repository.dart';

class UnlockLesson {
  const UnlockLesson(this._repository);

  final ProtectedLessonRepository _repository;

  Future<Lesson> call(LessonSummary lesson, String password) async {
    if (lesson.access != LessonAccess.protected) {
      throw const LessonUnlockFailure(
        'This lesson does not require unlocking.',
      );
    }
    if (password.trim().isEmpty) {
      throw const LessonUnlockFailure(
        'A password is required to unlock this lesson.',
      );
    }

    try {
      return await _repository.unlock(lesson, password);
    } on LessonUnlockFailure {
      rethrow;
    } on Object {
      throw const LessonUnlockFailure('The lesson could not be unlocked.');
    }
  }
}
