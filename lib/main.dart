import 'package:flutter/material.dart';

import 'application/load_lesson_catalog.dart';
import 'application/load_lesson.dart';
import 'application/unlock_lesson.dart';
import 'infrastructure/json_lesson_catalog_repository.dart';
import 'infrastructure/json_lesson_content_repository.dart';
import 'infrastructure/web_crypto_protected_lesson_repository.dart';
import 'presentation/spokojnie_app.dart';

void main() {
  final contentRepository = JsonLessonContentRepository();
  final catalogRepository = JsonLessonCatalogRepository();
  final loadLesson = LoadLesson(contentRepository);
  final loadCatalog = LoadLessonCatalog(catalogRepository);
  final unlockLesson = UnlockLesson(WebCryptoProtectedLessonRepository());

  runApp(
    SpokojnieApp(
      loadLesson: loadLesson,
      loadCatalog: loadCatalog,
      unlockLesson: unlockLesson,
    ),
  );
}
