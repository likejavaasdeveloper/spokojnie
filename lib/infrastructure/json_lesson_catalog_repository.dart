import 'dart:convert';

import 'package:flutter/services.dart';

import '../application/lesson_catalog_repository.dart';
import '../domain/lesson_catalog.dart';
import '../domain/lesson_access.dart';
import '../domain/lesson_summary.dart';
import 'lesson_content_exception.dart';

class JsonLessonCatalogRepository implements LessonCatalogRepository {
  JsonLessonCatalogRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  @override
  Future<LessonCatalog> loadCatalog() async {
    const assetPath = 'assets/content/lessons/catalog.json';

    try {
      final source = await _assetBundle.loadString(assetPath);
      final decoded = jsonDecode(source);
      return _mapCatalog(decoded);
    } on LessonContentException {
      rethrow;
    } on Object catch (error) {
      throw LessonContentException(
        'Could not load the lesson catalog from $assetPath.',
        cause: error,
      );
    }
  }
}

LessonCatalog _mapCatalog(Object? value) {
  final map = _requiredMap(value, 'catalog');
  final lessonsValue = map['lessons'];

  if (lessonsValue is! List) {
    throw const LessonContentException(
      'Missing or invalid field "catalog.lessons".',
    );
  }

  final lessons = <LessonSummary>[];
  for (var index = 0; index < lessonsValue.length; index++) {
    final context = 'catalog.lessons[$index]';
    final lesson = _requiredMap(lessonsValue[index], context);
    final descriptionValue = lesson['description'];

    if (descriptionValue != null && descriptionValue is! String) {
      throw LessonContentException('Invalid field "$context.description".');
    }

    lessons.add(
      LessonSummary(
        id: _requiredString(lesson, 'id', context),
        title: _requiredString(lesson, 'title', context),
        access: _requiredAccess(lesson, context),
        description: descriptionValue as String?,
      ),
    );
  }

  return LessonCatalog(lessons: lessons);
}

LessonAccess _requiredAccess(Map<String, dynamic> map, String context) {
  final value = map['access'];

  if (value == 'free') {
    return LessonAccess.free;
  }
  if (value == 'protected') {
    return LessonAccess.protected;
  }

  throw LessonContentException('Missing or invalid field "$context.access".');
}

Map<String, dynamic> _requiredMap(Object? value, String context) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  throw LessonContentException('Missing or invalid object "$context".');
}

String _requiredString(Map<String, dynamic> map, String field, String context) {
  final value = map[field];

  if (value is! String) {
    throw LessonContentException('Missing or invalid field "$context.$field".');
  }

  return value;
}
