import 'package:flutter/material.dart';

import '../application/load_lesson.dart';
import '../application/load_lesson_catalog.dart';
import '../application/unlock_lesson.dart';
import 'spokojnie_home_page.dart';

class SpokojnieApp extends StatelessWidget {
  const SpokojnieApp({
    required this.loadLesson,
    required this.loadCatalog,
    required this.unlockLesson,
    super.key,
  });

  final LoadLesson loadLesson;
  final LoadLessonCatalog loadCatalog;
  final UnlockLesson unlockLesson;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spokojnie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF487C78),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: SpokojnieHomePage(
        loadLesson: loadLesson,
        loadCatalog: loadCatalog,
        unlockLesson: unlockLesson,
      ),
    );
  }
}
