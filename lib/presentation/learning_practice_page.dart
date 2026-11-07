import 'package:flutter/material.dart';

import '../application/load_lesson.dart';
import '../domain/lesson.dart';
import '../domain/lesson_summary.dart';
import 'learning_practice_page_state.dart';

class LearningPracticePage extends StatefulWidget {
  const LearningPracticePage({
    required this.loadLesson,
    required this.lesson,
    this.initialLesson,
    super.key,
  });

  final LoadLesson loadLesson;
  final LessonSummary lesson;
  final Lesson? initialLesson;

  @override
  LearningPracticePageState createState() => LearningPracticePageState();
}
