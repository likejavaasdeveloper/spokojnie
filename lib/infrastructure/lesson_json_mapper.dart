import '../domain/learning_item.dart';
import '../domain/lesson.dart';
import '../domain/recall_step.dart';
import '../domain/understand_step.dart';
import '../domain/variation_step.dart';
import '../domain/vocabulary_entry.dart';
import 'lesson_content_exception.dart';

class LessonJsonMapper {
  const LessonJsonMapper();

  Lesson map(Object? value) {
    final map = _requiredMap(value, 'lesson');
    final id = _requiredString(map, 'id', 'lesson');
    final itemsValue = map['items'];
    if (itemsValue is! List) {
      throw const LessonContentException(
        'Missing or invalid field "lesson.items".',
      );
    }
    final items = <LearningItem>[];
    for (var index = 0; index < itemsValue.length; index++) {
      items.add(_mapLearningItem(itemsValue[index], index));
    }
    return Lesson(id: id, items: items);
  }

  LearningItem _mapLearningItem(Object? value, int index) {
    final context = 'lesson.items[$index]';
    final map = _requiredMap(value, context);
    final id = _requiredString(map, 'id', context);
    final steps = _requiredMap(map['steps'], '$context.steps');
    return LearningItem(
      id: id,
      understand: _mapUnderstandStep(
        steps['understand'],
        '$context.steps.understand',
      ),
      recall: _mapRecallStep(steps['recall'], '$context.steps.recall'),
      variation: _mapVariationStep(
        steps['variation'],
        '$context.steps.variation',
      ),
    );
  }

  UnderstandStep _mapUnderstandStep(Object? value, String context) {
    final map = _requiredMap(value, context);
    final vocabularyValue = map['vocabulary'];
    if (vocabularyValue is! List) {
      throw LessonContentException(
        'Missing or invalid field "$context.vocabulary".',
      );
    }
    return UnderstandStep(
      sentence: _requiredString(map, 'sentence', context),
      translation: _requiredString(map, 'translation', context),
      vocabulary: [
        for (var index = 0; index < vocabularyValue.length; index++)
          _mapVocabularyEntry(
            vocabularyValue[index],
            '$context.vocabulary[$index]',
          ),
      ],
    );
  }

  VocabularyEntry _mapVocabularyEntry(Object? value, String context) {
    final map = _requiredMap(value, context);
    return VocabularyEntry(
      word: _requiredString(map, 'word', context),
      meaning: _requiredString(map, 'meaning', context),
    );
  }

  RecallStep _mapRecallStep(Object? value, String context) {
    final map = _requiredMap(value, context);
    return RecallStep(
      prompt: _requiredString(map, 'prompt', context),
      answer: _requiredString(map, 'answer', context),
    );
  }

  VariationStep _mapVariationStep(Object? value, String context) {
    final map = _requiredMap(value, context);
    return VariationStep(
      prompt: _requiredString(map, 'prompt', context),
      answer: _requiredString(map, 'answer', context),
      translation: _requiredString(map, 'translation', context),
    );
  }

  Map<String, dynamic> _requiredMap(Object? value, String context) {
    if (value is Map<String, dynamic>) return value;
    throw LessonContentException('Missing or invalid object "$context".');
  }

  String _requiredString(
    Map<String, dynamic> map,
    String field,
    String context,
  ) {
    final value = map[field];
    if (value is! String) {
      throw LessonContentException(
        'Missing or invalid field "$context.$field".',
      );
    }
    return value;
  }
}
