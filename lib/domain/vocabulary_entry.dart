import 'domain_validation_exception.dart';

class VocabularyEntry {
  VocabularyEntry({required this.word, required this.meaning}) {
    _validateText(word, 'Vocabulary word');
    _validateText(meaning, 'Vocabulary meaning');
  }

  final String word;
  final String meaning;
}

void _validateText(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw DomainValidationException('$fieldName must not be blank.');
  }
}
