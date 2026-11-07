import 'domain_validation_exception.dart';

class VariationStep {
  VariationStep({
    required this.prompt,
    required this.answer,
    required this.translation,
  }) {
    _validateText(prompt, 'Variation prompt');
    _validateText(answer, 'Variation answer');
    _validateText(translation, 'Variation translation');
  }

  final String prompt;
  final String answer;
  final String translation;
}

void _validateText(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw DomainValidationException('$fieldName must not be blank.');
  }
}
