import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/load_lesson.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';
import 'package:spokojnie/infrastructure/json_lesson_content_repository.dart';
import 'package:spokojnie/presentation/revealed_answer_card.dart';
import 'package:spokojnie/presentation/revealed_variation_card.dart';
import 'package:spokojnie/presentation/learning_practice_page.dart';

import '../support/memory_asset_bundle.dart';
import '../support/test_lesson_content_repository.dart';

void main() {
  testWidgets('starts a lesson and displays JSON content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LearningPracticePage(
          loadLesson: _exampleLoadLesson(),
          lesson: _freeSummary(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dzień dobry.'), findsOneWidget);
    expect(find.text('روز بخیر.'), findsOneWidget);
    expect(find.text('Dzień dobry'), findsOneWidget);
    expect(find.text('روز بخیر'), findsOneWidget);
    expect(find.text('درک'), findsOneWidget);
  });

  testWidgets('navigates through steps, items, completion, and restart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LearningPracticePage(
          loadLesson: _flowLoadLesson(),
          lesson: _freeSummary(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    expect(find.text('Flow prompt 1.'), findsOneWidget);
    expect(find.text('Flow answer 1.'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Flow answer 1.');
    await tester.tap(find.text('نمایش پاسخ'));
    await tester.pumpAndSettle();
    expect(find.byType(RevealedAnswerCard), findsOneWidget);

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    expect(find.text('Flow variation prompt 1.'), findsOneWidget);

    await tester.tap(find.text('نمایش پاسخ'));
    await tester.pumpAndSettle();
    expect(find.byType(RevealedVariationCard), findsOneWidget);

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    expect(find.text('Flow sentence 2.'), findsOneWidget);
    expect(find.text('درس 2 از 2'), findsOneWidget);

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();

    expect(find.text('درس تمام شد'), findsOneWidget);

    await tester.tap(find.text('شروع دوباره'));
    await tester.pumpAndSettle();
    expect(find.text('Flow sentence 1.'), findsOneWidget);
    expect(find.text('درس 1 از 2'), findsOneWidget);
  });

  testWidgets('shows a loading error and retries loading', (
    WidgetTester tester,
  ) async {
    final repository = TestLessonContentRepository(
      _fallbackLesson(),
      failure: Exception('load failed'),
    );
    final loadLesson = LoadLesson(repository);

    await tester.pumpWidget(
      MaterialApp(
        home: LearningPracticePage(
          loadLesson: loadLesson,
          lesson: _freeSummary(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('بارگذاری درس ممکن نیست. لطفاً دوباره تلاش کنید.'),
      findsOneWidget,
    );
    expect(find.text('تلاش دوباره'), findsOneWidget);

    await tester.tap(find.text('تلاش دوباره'));
    await tester.pumpAndSettle();

    expect(repository.loadCount, 2);
    expect(find.text('Fallback sentence.'), findsOneWidget);
  });
}

LoadLesson _exampleLoadLesson() {
  const assetPath = 'assets/content/lessons/lesson_001.json';
  final repository = JsonLessonContentRepository(
    assetBundle: MemoryAssetBundle({
      assetPath: File(assetPath).readAsStringSync(),
    }),
  );

  return LoadLesson(repository);
}

LoadLesson _flowLoadLesson() {
  return LoadLesson(TestLessonContentRepository(_flowLesson()));
}

LessonSummary _freeSummary() {
  return LessonSummary(
    id: 'lesson_001',
    title: 'Lesson',
    access: LessonAccess.free,
  );
}

Lesson _flowLesson() {
  return Lesson(id: 'lesson_001', items: [_flowItem('1'), _flowItem('2')]);
}

LearningItem _flowItem(String suffix) {
  return LearningItem(
    id: 'item_$suffix',
    understand: UnderstandStep(
      sentence: 'Flow sentence $suffix.',
      translation: 'Flow translation $suffix.',
      vocabulary: const [],
    ),
    recall: RecallStep(
      prompt: 'Flow prompt $suffix.',
      answer: 'Flow answer $suffix.',
    ),
    variation: VariationStep(
      prompt: 'Flow variation prompt $suffix.',
      answer: 'Flow variation answer $suffix.',
      translation: 'Flow variation translation $suffix.',
    ),
  );
}

Lesson _fallbackLesson() {
  return Lesson(
    id: 'lesson_001',
    items: [
      LearningItem(
        id: 'item_001',
        understand: UnderstandStep(
          sentence: 'Fallback sentence.',
          translation: 'Fallback translation.',
          vocabulary: const [],
        ),
        recall: RecallStep(
          prompt: 'Fallback prompt.',
          answer: 'Fallback answer.',
        ),
        variation: VariationStep(
          prompt: 'Fallback variation.',
          answer: 'Fallback variation answer.',
          translation: 'Fallback variation translation.',
        ),
      ),
    ],
  );
}
