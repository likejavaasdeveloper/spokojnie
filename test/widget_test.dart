import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/load_lesson.dart';
import 'package:spokojnie/application/load_lesson_catalog.dart';
import 'package:spokojnie/application/unlock_lesson.dart';
import 'package:spokojnie/domain/lesson_catalog.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/presentation/spokojnie_app.dart';

import 'support/test_lesson_catalog_repository.dart';
import 'support/test_lesson_content_repository.dart';
import 'support/test_protected_lesson_repository.dart';

void main() {
  testWidgets('shows the Spokojnie home screen', (WidgetTester tester) async {
    final repository = TestLessonContentRepository(_lesson());
    final catalogRepository = TestLessonCatalogRepository(_catalog());
    final protectedRepository = TestProtectedLessonRepository(_lesson());
    await tester.pumpWidget(
      SpokojnieApp(
        loadLesson: LoadLesson(repository),
        loadCatalog: LoadLessonCatalog(catalogRepository),
        unlockLesson: UnlockLesson(protectedRepository),
      ),
    );

    expect(find.text('Spokojnie'), findsOneWidget);
    expect(
      find.text('یادگیری زبان لهستانی، یک جمله در هر نوبت'),
      findsOneWidget,
    );

    final directionality = tester.widget<Directionality>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Directionality &&
            widget.textDirection == TextDirection.rtl,
      ),
    );
    final startButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );

    expect(directionality.textDirection, TextDirection.rtl);
    expect(find.text('شروع یادگیری'), findsOneWidget);
    expect(startButton.onPressed, isNotNull);
    expect(find.byType(Banner), findsNothing);

    await tester.tap(find.text('شروع یادگیری'));
    await tester.pumpAndSettle();

    expect(find.text('درس آزمایشی'), findsOneWidget);
  });
}

LessonCatalog _catalog() {
  return LessonCatalog(
    lessons: [
      LessonSummary(
        id: 'lesson_001',
        title: 'درس آزمایشی',
        access: LessonAccess.free,
      ),
    ],
  );
}

Lesson _lesson() {
  return Lesson(
    id: 'lesson_001',
    items: [
      LearningItem(
        id: 'item_001',
        understand: UnderstandStep(
          sentence: 'Sentence.',
          translation: 'Translation.',
          vocabulary: const [],
        ),
        recall: RecallStep(prompt: 'Prompt.', answer: 'Answer.'),
        variation: VariationStep(
          prompt: 'Variation prompt.',
          answer: 'Variation answer.',
          translation: 'Variation translation.',
        ),
      ),
    ],
  );
}
