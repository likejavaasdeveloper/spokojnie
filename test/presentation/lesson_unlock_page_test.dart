import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/load_lesson.dart';
import 'package:spokojnie/application/lesson_unlock_failure.dart';
import 'package:spokojnie/application/lesson_unlock_failure_kind.dart';
import 'package:spokojnie/application/unlock_lesson.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson.dart';
import 'package:spokojnie/domain/learning_item.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/domain/recall_step.dart';
import 'package:spokojnie/domain/understand_step.dart';
import 'package:spokojnie/domain/variation_step.dart';
import 'package:spokojnie/presentation/lesson_unlock_page.dart';

import '../support/test_lesson_content_repository.dart';
import '../support/test_protected_lesson_repository.dart';

void main() {
  testWidgets('shows a protected lesson password form', (
    WidgetTester tester,
  ) async {
    final repository = TestProtectedLessonRepository(_lesson());
    await tester.pumpWidget(_app(repository));

    expect(find.text('درس محافظت‌شده'), findsOneWidget);
    expect(
      find.text('برای ادامه این درس، رمز عبور را وارد کنید.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
  });

  testWidgets('handles empty and incorrect passwords', (
    WidgetTester tester,
  ) async {
    final repository = TestProtectedLessonRepository(
      _lesson(),
      failure: const LessonUnlockFailure(
        'synthetic incorrect password',
        kind: LessonUnlockFailureKind.incorrectPassword,
      ),
    );
    await tester.pumpWidget(_app(repository));

    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pump();
    expect(find.text('لطفاً رمز عبور را وارد کنید.'), findsOneWidget);
    expect(repository.requestCount, 0);

    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pumpAndSettle();

    expect(
      find.text('رمز عبور نادرست است. لطفاً دوباره تلاش کنید.'),
      findsOneWidget,
    );
    expect(repository.requestCount, 1);
  });

  testWidgets('shows a missing asset message', (WidgetTester tester) async {
    final repository = TestProtectedLessonRepository(
      _lesson(),
      failure: const LessonUnlockFailure(
        'synthetic missing asset',
        kind: LessonUnlockFailureKind.missingAsset,
      ),
    );
    await tester.pumpWidget(_app(repository));
    await tester.enterText(find.byType(TextField), 'lesson-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pumpAndSettle();

    expect(find.text('این درس در حال حاضر در دسترس نیست.'), findsOneWidget);
  });

  testWidgets('shows an invalid content message', (WidgetTester tester) async {
    final repository = TestProtectedLessonRepository(
      _lesson(),
      failure: const LessonUnlockFailure(
        'synthetic invalid content',
        kind: LessonUnlockFailureKind.invalidContent,
      ),
    );
    await tester.pumpWidget(_app(repository));
    await tester.enterText(find.byType(TextField), 'lesson-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pumpAndSettle();

    expect(find.text('محتوای این درس قابل بارگذاری نیست.'), findsOneWidget);
  });

  testWidgets('shows an unknown failure message', (WidgetTester tester) async {
    final repository = TestProtectedLessonRepository(
      _lesson(),
      failure: const LessonUnlockFailure('synthetic unknown failure'),
    );
    await tester.pumpWidget(_app(repository));
    await tester.enterText(find.byType(TextField), 'lesson-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pumpAndSettle();

    expect(
      find.text('باز کردن درس ممکن نیست. لطفاً دوباره تلاش کنید.'),
      findsOneWidget,
    );
  });

  testWidgets('prevents repeated submission and passes the unlocked lesson', (
    WidgetTester tester,
  ) async {
    final repository = TestProtectedLessonRepository(
      _lesson(),
      delay: const Duration(milliseconds: 100),
    );
    await tester.pumpWidget(_app(repository));
    await tester.enterText(find.byType(TextField), 'lesson-password');

    await tester.tap(find.widgetWithText(ElevatedButton, 'باز کردن درس'));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(const Duration(milliseconds: 20));

    expect(repository.requestCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Fallback sentence.'), findsOneWidget);
  });

  testWidgets('back action returns without unlocking', (
    WidgetTester tester,
  ) async {
    final repository = TestProtectedLessonRepository(_lesson());
    await tester.pumpWidget(const MaterialApp(home: Text('menu')));
    final context = tester.element(find.text('menu'));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LessonUnlockPage(
          lesson: _summary(),
          unlockLesson: UnlockLesson(repository),
          loadLesson: LoadLesson(TestLessonContentRepository(_lesson())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(LessonUnlockPage), findsNothing);
    expect(find.text('menu'), findsOneWidget);
    expect(repository.requestCount, 0);
  });
}

Widget _app(TestProtectedLessonRepository repository) {
  return MaterialApp(
    home: LessonUnlockPage(
      lesson: _summary(),
      unlockLesson: UnlockLesson(repository),
      loadLesson: LoadLesson(TestLessonContentRepository(_lesson())),
    ),
  );
}

LessonSummary _summary() {
  return LessonSummary(
    id: 'lesson_003',
    title: 'درس محافظت‌شده',
    access: LessonAccess.protected,
  );
}

Lesson _lesson() {
  return Lesson(
    id: 'lesson_003',
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
