import 'package:flutter/material.dart';

import '../application/load_lesson.dart';
import '../application/load_lesson_catalog.dart';
import '../application/unlock_lesson.dart';
import 'lesson_menu_page_state.dart';

class LessonMenuPage extends StatefulWidget {
  const LessonMenuPage({
    required this.loadCatalog,
    required this.loadLesson,
    required this.unlockLesson,
    super.key,
  });

  final LoadLessonCatalog loadCatalog;
  final LoadLesson loadLesson;
  final UnlockLesson unlockLesson;

  @override
  LessonMenuPageState createState() => LessonMenuPageState();
}
