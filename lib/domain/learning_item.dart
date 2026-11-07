import 'domain_validation_exception.dart';
import 'recall_step.dart';
import 'understand_step.dart';
import 'variation_step.dart';

class LearningItem {
  LearningItem({
    required this.id,
    required this.understand,
    required this.recall,
    required this.variation,
  }) {
    if (id.trim().isEmpty) {
      throw const DomainValidationException(
        'Learning item id must not be empty.',
      );
    }
  }

  final String id;
  final UnderstandStep understand;
  final RecallStep recall;
  final VariationStep variation;
}
