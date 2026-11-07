import '../domain/lesson_catalog.dart';
import 'lesson_catalog_repository.dart';

class LoadLessonCatalog {
  const LoadLessonCatalog(this._repository);

  final LessonCatalogRepository _repository;

  Future<LessonCatalog> call() {
    return _repository.loadCatalog();
  }
}
