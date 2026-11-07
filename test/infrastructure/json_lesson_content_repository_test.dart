import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/infrastructure/json_lesson_content_repository.dart';
import 'package:spokojnie/infrastructure/lesson_content_exception.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson_summary.dart';

import '../support/memory_asset_bundle.dart';

void main() {
  test('loads the example lesson and maps all three steps', () async {
    final repository = _exampleLessonRepository();

    final lesson = await repository.loadFree(_freeSummary('lesson_001'));
    final firstItem = lesson.items.first;

    expect(lesson.id, 'lesson_001');
    expect(lesson.items, hasLength(18));
    expect(firstItem.id, 'item_001');
    expect(firstItem.understand.sentence, 'Dzień dobry.');
    expect(firstItem.understand.translation, 'روز بخیر.');
    expect(firstItem.understand.vocabulary.first.word, 'Dzień dobry');
    expect(firstItem.understand.vocabulary.first.meaning, 'روز بخیر');
    expect(firstItem.recall.prompt, 'روز بخیر.');
    expect(firstItem.recall.answer, 'Dzień dobry.');
    expect(firstItem.variation.prompt, 'سلام (غیررسمی).');
    expect(firstItem.variation.answer, 'Cześć.');
    expect(firstItem.variation.translation, 'سلام (غیررسمی).');
  });

  test('preserves the declared learning item order', () async {
    final repository = _exampleLessonRepository();

    final lesson = await repository.loadFree(_freeSummary('lesson_001'));

    expect(lesson.items.take(2).map((item) => item.id), [
      'item_001',
      'item_002',
    ]);
  });

  test('rejects missing required fields', () async {
    final repository = _repositoryFor({
      'id': 'missing_field',
      'items': [
        {'id': 'item_001', 'steps': <String, Object?>{}},
      ],
    });

    await expectLater(
      repository.loadFree(_freeSummary('missing_field')),
      throwsA(isA<LessonContentException>()),
    );
  });

  test('rejects blank required educational content', () async {
    final repository = _repositoryFor(_validLessonPayload(sentence: ' '));

    await expectLater(
      repository.loadFree(_freeSummary('invalid_blank')),
      throwsA(isA<LessonContentException>()),
    );
  });

  test('rejects a lesson without learning items', () async {
    final repository = _repositoryFor({
      'id': 'empty_lesson',
      'items': <Object?>[],
    });

    await expectLater(
      repository.loadFree(_freeSummary('empty_lesson')),
      throwsA(isA<LessonContentException>()),
    );
  });

  test('handles missing lesson assets with a controlled error', () async {
    final repository = JsonLessonContentRepository(assetBundle: rootBundle);

    await expectLater(
      repository.loadFree(_freeSummary('does_not_exist')),
      throwsA(isA<LessonContentException>()),
    );
  });

  test('handles malformed JSON with a controlled error', () async {
    final repository = JsonLessonContentRepository(
      assetBundle: MemoryAssetBundle({
        'assets/content/lessons/malformed.json': '{',
      }),
    );

    await expectLater(
      repository.loadFree(_freeSummary('malformed')),
      throwsA(isA<LessonContentException>()),
    );
  });

  test(
    'cannot load protected content through the free repository port',
    () async {
      final repository = JsonLessonContentRepository(
        assetBundle: MemoryAssetBundle({}),
      );

      await expectLater(
        repository.loadFree(
          LessonSummary(
            id: 'lesson_003',
            title: 'Protected',
            access: LessonAccess.protected,
          ),
        ),
        throwsA(isA<LessonContentException>()),
      );
    },
  );
}

LessonSummary _freeSummary(String id) {
  return LessonSummary(id: id, title: id, access: LessonAccess.free);
}

JsonLessonContentRepository _repositoryFor(Map<String, Object?> lesson) {
  return JsonLessonContentRepository(
    assetBundle: MemoryAssetBundle({
      'assets/content/lessons/${lesson['id']}.json': jsonEncode(lesson),
    }),
  );
}

JsonLessonContentRepository _exampleLessonRepository() {
  const assetPath = 'assets/content/lessons/lesson_001.json';

  return JsonLessonContentRepository(
    assetBundle: MemoryAssetBundle({
      assetPath: File(assetPath).readAsStringSync(),
    }),
  );
}

Map<String, Object?> _validLessonPayload({String sentence = 'Sentence.'}) {
  return {
    'id': 'invalid_blank',
    'items': [
      {
        'id': 'item_001',
        'steps': {
          'understand': {
            'sentence': sentence,
            'translation': 'Translation.',
            'vocabulary': [
              {'word': 'Word', 'meaning': 'Meaning'},
            ],
          },
          'recall': {'prompt': 'Prompt.', 'answer': 'Answer.'},
          'variation': {
            'prompt': 'Variation prompt.',
            'answer': 'Variation answer.',
            'translation': 'Variation translation.',
          },
        },
      },
    ],
  };
}
