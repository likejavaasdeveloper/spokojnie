import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/load_lesson.dart';
import 'package:spokojnie/application/load_lesson_catalog.dart';
import 'package:spokojnie/application/unlock_lesson.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/lesson_catalog.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';
import 'package:spokojnie/infrastructure/json_lesson_catalog_repository.dart';
import 'package:spokojnie/presentation/lesson_menu_page.dart';

import '../support/memory_asset_bundle.dart';
import '../support/test_lesson_catalog_repository.dart';
import '../support/test_lesson_content_repository.dart';
import '../support/test_protected_lesson_repository.dart';

void main() {
  testWidgets('displays ordered lessons and loads the selected lesson', (
    WidgetTester tester,
  ) async {
    final catalogRepository = JsonLessonCatalogRepository(
      assetBundle: MemoryAssetBundle({
        'assets/content/lessons/catalog.json': '''
{
  "lessons": [
    {"id": "lesson_001", "title": "درس اول", "description": "توضیح اول", "access": "free"},
    {"id": "lesson_002", "title": "درس دوم", "description": "توضیح دوم", "access": "protected"}
  ]
}
''',
      }),
    );
    final contentRepository = TestLessonContentRepository(_lesson());
    final protectedRepository = TestProtectedLessonRepository(_lesson());

    await tester.pumpWidget(
      MaterialApp(
        home: LessonMenuPage(
          loadCatalog: LoadLessonCatalog(catalogRepository),
          loadLesson: LoadLesson(contentRepository),
          unlockLesson: UnlockLesson(protectedRepository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('درس اول'), findsOneWidget);
    expect(find.text('درس دوم'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('درس اول')).dy,
      lessThan(tester.getTopLeft(find.text('درس دوم')).dy),
    );

    await tester.tap(find.text('درس اول'));
    await tester.pumpAndSettle();

    expect(contentRepository.lastLessonId, 'lesson_001');
    expect(find.text('Fallback sentence.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('درس دوم'));
    await tester.pumpAndSettle();

    expect(
      find.text('برای ادامه این درس، رمز عبور را وارد کنید.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('shows a catalog loading error and retries', (
    WidgetTester tester,
  ) async {
    final catalogRepository = TestLessonCatalogRepository(
      _catalog(),
      failure: Exception('catalog failed'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LessonMenuPage(
          loadCatalog: LoadLessonCatalog(catalogRepository),
          loadLesson: LoadLesson(TestLessonContentRepository(_lesson())),
          unlockLesson: UnlockLesson(TestProtectedLessonRepository(_lesson())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('بارگذاری فهرست درس‌ها ممکن نیست. لطفاً دوباره تلاش کنید.'),
      findsOneWidget,
    );
    await tester.tap(find.text('تلاش دوباره'));
    await tester.pumpAndSettle();
    expect(find.text('درس آزمایشی'), findsOneWidget);
  });

  testWidgets('requires a new unlock after returning to the menu', (
    WidgetTester tester,
  ) async {
    final protectedRepository = TestProtectedLessonRepository(_lesson());
    await tester.pumpWidget(
      MaterialApp(
        home: LessonMenuPage(
          loadCatalog: LoadLessonCatalog(
            TestLessonCatalogRepository(
              LessonCatalog(lessons: [_protectedSummary()]),
            ),
          ),
          loadLesson: LoadLesson(TestLessonContentRepository(_lesson())),
          unlockLesson: UnlockLesson(protectedRepository),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('درس محافظت‌شده'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pumpAndSettle();
    expect(find.text('Fallback sentence.'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('درس محافظت‌شده'));
    await tester.pumpAndSettle();

    expect(
      find.text('برای ادامه این درس، رمز عبور را وارد کنید.'),
      findsOneWidget,
    );
    expect(protectedRepository.requestCount, 1);
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

LessonSummary _protectedSummary() {
  return LessonSummary(
    id: 'lesson_003',
    title: 'درس محافظت‌شده',
    access: LessonAccess.protected,
  );
}

Lesson _lesson() {
  return Lesson(
    id: 'lesson_002',
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
