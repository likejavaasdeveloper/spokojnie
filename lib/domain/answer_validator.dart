import 'answer_difference.dart';
import 'answer_difference_type.dart';
import 'answer_validation_result.dart';

class AnswerValidator {
  const AnswerValidator();

  AnswerValidationResult validate(String expectedAnswer, String learnerAnswer) {
    final normalizedExpected = normalize(expectedAnswer);
    final normalizedLearner = normalize(learnerAnswer);
    final differences = _findDifferences(normalizedExpected, normalizedLearner);

    return AnswerValidationResult(
      expectedAnswer: expectedAnswer,
      learnerAnswer: learnerAnswer,
      normalizedExpectedAnswer: normalizedExpected,
      normalizedLearnerAnswer: normalizedLearner,
      differences: List.unmodifiable(differences),
    );
  }

  String normalize(String answer) {
    var normalized = answer
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
    normalized = normalized.replaceFirst(RegExp(r'[.!?]+$'), '');
    return normalized.trim();
  }
}

List<AnswerDifference> _findDifferences(String expected, String actual) {
  final expectedCharacters = expected.runes.toList();
  final actualCharacters = actual.runes.toList();
  final distances = _buildDistances(expectedCharacters, actualCharacters);
  final differences = <AnswerDifference>[];
  var expectedIndex = 0;
  var actualIndex = 0;

  while (expectedIndex < expectedCharacters.length ||
      actualIndex < actualCharacters.length) {
    if (expectedIndex < expectedCharacters.length &&
        actualIndex < actualCharacters.length &&
        expectedCharacters[expectedIndex] == actualCharacters[actualIndex]) {
      expectedIndex++;
      actualIndex++;
      continue;
    }

    if (_isTransposition(
      expectedCharacters,
      actualCharacters,
      expectedIndex,
      actualIndex,
      distances,
    )) {
      differences.add(
        AnswerDifference(
          type: AnswerDifferenceType.transposition,
          expectedIndex: expectedIndex,
          actualIndex: actualIndex,
          expectedFragment: _charactersToString(
            expectedCharacters.sublist(expectedIndex, expectedIndex + 2),
          ),
          actualFragment: _charactersToString(
            actualCharacters.sublist(actualIndex, actualIndex + 2),
          ),
          wordIndex: _wordIndex(expected, expectedIndex),
        ),
      );
      expectedIndex += 2;
      actualIndex += 2;
      continue;
    }

    final substitutionDistance = _distanceAt(
      distances,
      expectedIndex + 1,
      actualIndex + 1,
    );
    final deletionDistance = _distanceAt(
      distances,
      expectedIndex + 1,
      actualIndex,
    );
    final insertionDistance = _distanceAt(
      distances,
      expectedIndex,
      actualIndex + 1,
    );
    final currentDistance = _distanceAt(distances, expectedIndex, actualIndex);

    if (expectedIndex < expectedCharacters.length &&
        actualIndex < actualCharacters.length &&
        substitutionDistance == currentDistance - 1) {
      differences.add(
        AnswerDifference(
          type: AnswerDifferenceType.substitution,
          expectedIndex: expectedIndex,
          actualIndex: actualIndex,
          expectedFragment: String.fromCharCode(
            expectedCharacters[expectedIndex],
          ),
          actualFragment: String.fromCharCode(actualCharacters[actualIndex]),
          wordIndex: _wordIndex(expected, expectedIndex),
        ),
      );
      expectedIndex++;
      actualIndex++;
    } else if (expectedIndex < expectedCharacters.length &&
        deletionDistance == currentDistance - 1) {
      differences.add(
        AnswerDifference(
          type: AnswerDifferenceType.missing,
          expectedIndex: expectedIndex,
          actualIndex: null,
          expectedFragment: String.fromCharCode(
            expectedCharacters[expectedIndex],
          ),
          actualFragment: '',
          wordIndex: _wordIndex(expected, expectedIndex),
        ),
      );
      expectedIndex++;
    } else if (actualIndex < actualCharacters.length &&
        insertionDistance == currentDistance - 1) {
      differences.add(
        AnswerDifference(
          type: AnswerDifferenceType.extra,
          expectedIndex: expectedIndex,
          actualIndex: actualIndex,
          expectedFragment: '',
          actualFragment: String.fromCharCode(actualCharacters[actualIndex]),
          wordIndex: _wordIndex(expected, expectedIndex),
        ),
      );
      actualIndex++;
    }
  }

  return differences;
}

List<List<int>> _buildDistances(List<int> expected, List<int> actual) {
  final distances = List.generate(
    expected.length + 1,
    (_) => List<int>.filled(actual.length + 1, 0),
  );

  for (var index = 0; index <= expected.length; index++) {
    distances[index][actual.length] = expected.length - index;
  }
  for (var index = 0; index <= actual.length; index++) {
    distances[expected.length][index] = actual.length - index;
  }

  for (
    var expectedIndex = expected.length - 1;
    expectedIndex >= 0;
    expectedIndex--
  ) {
    for (var actualIndex = actual.length - 1; actualIndex >= 0; actualIndex--) {
      if (expected[expectedIndex] == actual[actualIndex]) {
        distances[expectedIndex][actualIndex] =
            distances[expectedIndex + 1][actualIndex + 1];
      } else {
        distances[expectedIndex][actualIndex] =
            1 +
            _minimum([
              distances[expectedIndex + 1][actualIndex + 1],
              distances[expectedIndex + 1][actualIndex],
              distances[expectedIndex][actualIndex + 1],
            ]);
      }
    }
  }

  return distances;
}

bool _isTransposition(
  List<int> expected,
  List<int> actual,
  int expectedIndex,
  int actualIndex,
  List<List<int>> distances,
) {
  if (expectedIndex + 1 >= expected.length ||
      actualIndex + 1 >= actual.length ||
      expected[expectedIndex] != actual[actualIndex + 1] ||
      expected[expectedIndex + 1] != actual[actualIndex]) {
    return false;
  }

  final currentDistance = _distanceAt(distances, expectedIndex, actualIndex);
  final afterTransposition = _distanceAt(
    distances,
    expectedIndex + 2,
    actualIndex + 2,
  );
  return currentDistance == afterTransposition + 2;
}

int _distanceAt(List<List<int>> distances, int row, int column) {
  if (row >= distances.length || column >= distances.first.length) {
    return 0;
  }
  return distances[row][column];
}

int _minimum(List<int> values) => values.reduce((a, b) => a < b ? a : b);

String _charactersToString(List<int> characters) =>
    String.fromCharCodes(characters);

int _wordIndex(String value, int characterIndex) {
  if (value.isEmpty) {
    return 0;
  }
  final prefix = value.substring(0, characterIndex.clamp(0, value.length));
  final words = prefix.trim().split(' ');
  return prefix.trim().isEmpty ? 0 : words.length - 1;
}
