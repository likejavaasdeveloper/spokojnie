import 'dart:convert';

import 'package:flutter/services.dart';

import '../application/lesson_content_repository.dart';
import '../domain/domain_validation_exception.dart';
import '../domain/lesson.dart';
import '../domain/lesson_access.dart';
import '../domain/lesson_summary.dart';
import 'lesson_content_exception.dart';
import 'lesson_json_mapper.dart';

class JsonLessonContentRepository implements LessonContentRepository {
  JsonLessonContentRepository({
    AssetBundle? assetBundle,
    LessonJsonMapper? mapper,
  }) : _assetBundle = assetBundle ?? rootBundle,
       _mapper = mapper ?? const LessonJsonMapper();

  final AssetBundle _assetBundle;
  final LessonJsonMapper _mapper;

  @override
  Future<Lesson> loadFree(LessonSummary lesson) async {
    if (lesson.access != LessonAccess.free) {
      throw const LessonContentException(
        'Protected lesson content is unavailable through the free loader.',
      );
    }
    final assetPath = 'assets/content/lessons/${lesson.id}.json';
    try {
      final mappedLesson = _mapper.map(
        jsonDecode(await _assetBundle.loadString(assetPath)),
      );
      if (mappedLesson.id != lesson.id) {
        throw const LessonContentException(
          'Lesson content identifier does not match the catalog entry.',
        );
      }
      return mappedLesson;
    } on LessonContentException {
      rethrow;
    } on DomainValidationException catch (error) {
      throw LessonContentException(
        'Invalid lesson content for "${lesson.id}": ${error.message}',
        cause: error,
      );
    } on Object catch (error) {
      throw LessonContentException(
        'Could not load lesson "${lesson.id}" from $assetPath.',
        cause: error,
      );
    }
  }
}
