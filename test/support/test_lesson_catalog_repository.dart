import 'package:spokojnie/application/lesson_catalog_repository.dart';
import 'package:spokojnie/domain/lesson_catalog.dart';

class TestLessonCatalogRepository implements LessonCatalogRepository {
  TestLessonCatalogRepository(this.catalog, {this.failure});

  final LessonCatalog catalog;
  Object? failure;

  @override
  Future<LessonCatalog> loadCatalog() async {
    final error = failure;
    if (error != null) {
      failure = null;
      throw error;
    }

    return catalog;
  }
}
