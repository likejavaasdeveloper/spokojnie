import '../domain/lesson.dart';
import '../domain/lesson_summary.dart';

abstract interface class ProtectedLessonRepository {
  Future<Lesson> unlock(LessonSummary lesson, String password);
}
