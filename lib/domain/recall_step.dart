import 'domain_validation_exception.dart';

class RecallStep {
  RecallStep({required this.prompt, required this.answer}) {
    _validateText(prompt, 'Recall prompt');
    _validateText(answer, 'Recall answer');
  }

  final String prompt;
  final String answer;
}

void _validateText(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw DomainValidationException('$fieldName must not be blank.');
  }
}
