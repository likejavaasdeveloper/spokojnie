import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/domain/answer_difference_type.dart';
import 'package:spokojnie/domain/answer_validator.dart';

void main() {
  const validator = AnswerValidator();

  test('accepts an exact answer', () {
    final result = validator.validate('Idę do szkoły.', 'Idę do szkoły.');

    expect(result.isCorrect, isTrue);
    expect(result.differences, isEmpty);
  });

  test('ignores case, repeated spaces, and terminal punctuation', () {
    final result = validator.validate('Idę do szkoły.', '  idĘ   do szkoły  ');

    expect(result.isCorrect, isTrue);
  });

  test('preserves Polish diacritics', () {
    final result = validator.validate('Idę do szkoły.', 'Ide do szkoly');

    expect(result.isCorrect, isFalse);
    expect(
      result.differences.map((difference) => difference.expectedFragment),
      containsAll(<String>['ę', 'ł']),
    );
  });

  test('identifies missing characters', () {
    final result = validator.validate('Idę', 'Ide');

    expect(result.differences, hasLength(1));
    expect(result.differences.single.type, AnswerDifferenceType.substitution);
    expect(result.differences.single.expectedFragment, 'ę');
  });

  test('identifies extra characters', () {
    final result = validator.validate('dom', 'domm');

    expect(result.differences, hasLength(1));
    expect(result.differences.single.type, AnswerDifferenceType.extra);
    expect(result.differences.single.actualFragment, 'm');
  });

  test('identifies substituted characters', () {
    final result = validator.validate('domy', 'doma');

    expect(result.differences, hasLength(1));
    expect(result.differences.single.type, AnswerDifferenceType.substitution);
    expect(result.differences.single.expectedFragment, 'y');
    expect(result.differences.single.actualFragment, 'a');
  });

  test('identifies transposed characters', () {
    final result = validator.validate('kot', 'okt');

    expect(result.differences, hasLength(1));
    expect(result.differences.single.type, AnswerDifferenceType.transposition);
    expect(result.differences.single.expectedFragment, 'ko');
    expect(result.differences.single.actualFragment, 'ok');
  });

  test('identifies multiple spelling errors', () {
    final result = validator.validate('Idę do domu.', 'Ide do domy');

    expect(result.isCorrect, isFalse);
    expect(result.differences.length, greaterThanOrEqualTo(2));
  });

  test('rejects an empty answer', () {
    final result = validator.validate('Idę do domu.', '');

    expect(result.isCorrect, isFalse);
    expect(result.differences, isNotEmpty);
  });
}
