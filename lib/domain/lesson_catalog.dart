import 'domain_validation_exception.dart';
import 'lesson_summary.dart';

class LessonCatalog {
  LessonCatalog({required List<LessonSummary> lessons})
    : lessons = List.unmodifiable(lessons) {
    if (this.lessons.isEmpty) {
      throw const DomainValidationException(
        'Lesson catalog must contain at least one lesson.',
      );
    }

    final identifiers = <String>{};
    for (final lesson in this.lessons) {
      if (!identifiers.add(lesson.id)) {
        throw DomainValidationException(
          'Lesson catalog contains duplicate identifier: ${lesson.id}.',
        );
      }
    }
  }

  final List<LessonSummary> lessons;
}
