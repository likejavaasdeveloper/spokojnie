import 'answer_difference.dart';

class AnswerValidationResult {
  const AnswerValidationResult({
    required this.expectedAnswer,
    required this.learnerAnswer,
    required this.normalizedExpectedAnswer,
    required this.normalizedLearnerAnswer,
    required this.differences,
  });

  final String expectedAnswer;
  final String learnerAnswer;
  final String normalizedExpectedAnswer;
  final String normalizedLearnerAnswer;
  final List<AnswerDifference> differences;

  bool get isCorrect => differences.isEmpty;
}
