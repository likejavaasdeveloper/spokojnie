import 'domain_validation_exception.dart';
import 'learning_item.dart';

class Lesson {
  Lesson({required this.id, required List<LearningItem> items})
    : items = List.unmodifiable(items) {
    if (id.trim().isEmpty) {
      throw const DomainValidationException('Lesson id must not be empty.');
    }
    if (this.items.isEmpty) {
      throw const DomainValidationException(
        'Lesson must contain at least one learning item.',
      );
    }
  }

  final String id;
  final List<LearningItem> items;
}
