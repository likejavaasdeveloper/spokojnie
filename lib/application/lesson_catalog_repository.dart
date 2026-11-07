import '../domain/lesson_catalog.dart';

abstract interface class LessonCatalogRepository {
  Future<LessonCatalog> loadCatalog();
}
