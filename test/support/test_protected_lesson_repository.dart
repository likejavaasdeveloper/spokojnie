import 'package:spokojnie/application/protected_lesson_repository.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_summary.dart';

class TestProtectedLessonRepository implements ProtectedLessonRepository {
  TestProtectedLessonRepository(this.lesson, {this.failure, this.delay});

  final Lesson lesson;
  Object? failure;
  final Duration? delay;
  final requestedPasswords = <String>[];
  var requestCount = 0;

  @override
  Future<Lesson> unlock(LessonSummary summary, String password) async {
    requestCount++;
    requestedPasswords.add(password);
    final requestDelay = delay;
    if (requestDelay != null) {
      await Future<void>.delayed(requestDelay);
    }
    final error = failure;
    if (error != null) {
      throw error;
    }
    return lesson;
  }
}
