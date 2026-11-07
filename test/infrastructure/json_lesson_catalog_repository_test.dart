import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/infrastructure/json_lesson_catalog_repository.dart';
import 'package:spokojnie/infrastructure/lesson_content_exception.dart';
import 'package:spokojnie/domain/lesson_access.dart';

import '../support/memory_asset_bundle.dart';

void main() {
  test('loads lesson titles and preserves catalog order', () async {
    const assetPath = 'assets/content/lessons/catalog.json';
    final repository = JsonLessonCatalogRepository(
      assetBundle: MemoryAssetBundle({
        assetPath: File(assetPath).readAsStringSync(),
      }),
    );

    final catalog = await repository.loadCatalog();

    expect(catalog.lessons, hasLength(26));
    expect(catalog.lessons.first.id, 'lesson_001');
    expect(catalog.lessons.first.title, 'اولین روز در مدرسه');
    expect(catalog.lessons.first.access, LessonAccess.free);
    expect(catalog.lessons[1].access, LessonAccess.free);
    expect(catalog.lessons[2].access, LessonAccess.protected);
    expect(catalog.lessons.last.id, 'lesson_026');
    expect(catalog.lessons.last.access, LessonAccess.protected);
    expect(catalog.lessons.first.description, isNotNull);
  });

  test('handles malformed catalog content', () async {
    final repository = JsonLessonCatalogRepository(
      assetBundle: MemoryAssetBundle({
        'assets/content/lessons/catalog.json': '{',
      }),
    );

    await expectLater(
      repository.loadCatalog(),
      throwsA(isA<LessonContentException>()),
    );
  });
}
