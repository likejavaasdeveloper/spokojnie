import '../domain/lesson.dart';
import '../domain/lesson_summary.dart';

abstract interface class LessonContentRepository {
  Future<Lesson> loadFree(LessonSummary lesson);
}
