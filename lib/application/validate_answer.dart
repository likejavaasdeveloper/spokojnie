import '../domain/answer_validation_result.dart';
import '../domain/answer_validator.dart';

class ValidateAnswer {
  const ValidateAnswer({AnswerValidator validator = const AnswerValidator()})
    : _validator = validator;

  final AnswerValidator _validator;

  AnswerValidationResult call(String expectedAnswer, String learnerAnswer) {
    return _validator.validate(expectedAnswer, learnerAnswer);
  }
}
