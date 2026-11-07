import 'domain_validation_exception.dart';
import 'lesson_access.dart';

class LessonSummary {
  LessonSummary({
    required this.id,
    required this.title,
    required this.access,
    this.description,
  }) {
    if (id.trim().isEmpty) {
      throw const DomainValidationException(
        'Lesson identifier must not be empty.',
      );
    }
    if (title.trim().isEmpty) {
      throw const DomainValidationException('Lesson title must not be blank.');
    }
  }

  final String id;
  final String title;
  final LessonAccess access;
  final String? description;
}
