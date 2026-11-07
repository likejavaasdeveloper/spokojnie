import 'domain_validation_exception.dart';
import 'vocabulary_entry.dart';

class UnderstandStep {
  UnderstandStep({
    required this.sentence,
    required this.translation,
    required List<VocabularyEntry> vocabulary,
  }) : vocabulary = List.unmodifiable(vocabulary) {
    _validateText(sentence, 'Understand sentence');
    _validateText(translation, 'Understand translation');
  }

  final String sentence;
  final String translation;
  final List<VocabularyEntry> vocabulary;
}

void _validateText(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw DomainValidationException('$fieldName must not be blank.');
  }
}
