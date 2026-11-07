import '../domain/lesson.dart';
import '../domain/lesson_access.dart';
import '../domain/lesson_summary.dart';
import 'lesson_unlock_failure.dart';
import 'lesson_content_repository.dart';

class LoadLesson {
  const LoadLesson(this._repository);

  final LessonContentRepository _repository;

  Future<Lesson> call(LessonSummary lesson) async {
    if (lesson.access != LessonAccess.free) {
      throw const LessonUnlockFailure(
        'Protected lessons must be unlocked explicitly.',
      );
    }

    return _repository.loadFree(lesson);
  }
}
