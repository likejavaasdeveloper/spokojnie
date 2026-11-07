import 'package:flutter/material.dart';

import '../application/load_lesson.dart';
import '../application/unlock_lesson.dart';
import '../domain/lesson_summary.dart';
import 'lesson_unlock_page_state.dart';

class LessonUnlockPage extends StatefulWidget {
  const LessonUnlockPage({
    required this.lesson,
    required this.unlockLesson,
    required this.loadLesson,
    super.key,
  });

  final LessonSummary lesson;
  final UnlockLesson unlockLesson;
  final LoadLesson loadLesson;

  @override
  LessonUnlockPageState createState() => LessonUnlockPageState();
}
