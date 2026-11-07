import 'answer_difference_type.dart';

class AnswerDifference {
  const AnswerDifference({
    required this.type,
    required this.expectedIndex,
    required this.actualIndex,
    required this.expectedFragment,
    required this.actualFragment,
    required this.wordIndex,
  });

  final AnswerDifferenceType type;
  final int expectedIndex;
  final int? actualIndex;
  final String expectedFragment;
  final String actualFragment;
  final int wordIndex;
}
