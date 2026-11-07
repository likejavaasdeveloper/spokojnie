import 'package:spokojnie/application/lesson_content_repository.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_summary.dart';

class TestLessonContentRepository implements LessonContentRepository {
  TestLessonContentRepository(this.lesson, {this.failure});

  final Lesson lesson;
  Object? failure;
  var loadCount = 0;
  String? lastLessonId;

  @override
  Future<Lesson> loadFree(LessonSummary lessonSummary) async {
    loadCount++;
    lastLessonId = lessonSummary.id;
    final error = failure;
    if (error != null) {
      failure = null;
      throw error;
    }

    return lesson;
  }
}
