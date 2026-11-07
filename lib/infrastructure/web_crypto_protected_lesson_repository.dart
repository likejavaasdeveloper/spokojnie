import 'dart:convert';

import 'package:flutter/services.dart';

import '../application/lesson_unlock_failure.dart';
import '../application/lesson_unlock_failure_kind.dart';
import '../application/protected_lesson_repository.dart';
import '../domain/lesson.dart';
import '../domain/lesson_access.dart';
import '../domain/lesson_summary.dart';
import 'browser_web_crypto_decryptor.dart';
import 'lesson_decryptor.dart';
import 'lesson_json_mapper.dart';
import 'protected_lesson_envelope.dart';
import 'web_crypto_platform.dart';

class WebCryptoProtectedLessonRepository implements ProtectedLessonRepository {
  WebCryptoProtectedLessonRepository({
    AssetBundle? assetBundle,
    LessonDecryptor? decryptor,
    LessonJsonMapper? mapper,
    this.protectedAssetDirectory = 'assets/content/lessons/protected',
  }) : _assetBundle = assetBundle ?? rootBundle,
       _decryptor = decryptor ?? const BrowserWebCryptoDecryptor(),
       _mapper = mapper ?? const LessonJsonMapper();

  final AssetBundle _assetBundle;
  final LessonDecryptor _decryptor;
  final LessonJsonMapper _mapper;
  final String protectedAssetDirectory;

  @override
  Future<Lesson> unlock(LessonSummary lesson, String password) async {
    if (lesson.access != LessonAccess.protected) {
      throw const LessonUnlockFailure(
        'This lesson does not require unlocking.',
      );
    }
    final path = '$protectedAssetDirectory/${lesson.id}.enc.json';
    final source = await _loadAsset(path);
    final envelope = _parseEnvelope(source, lesson.id);
    final plaintext = await _decrypt(envelope, password);
    return _mapLesson(plaintext, lesson.id);
  }

  Future<String> _loadAsset(String path) async {
    try {
      return await _assetBundle.loadString(path);
    } on Object {
      throw const LessonUnlockFailure(
        'The protected lesson is unavailable.',
        kind: LessonUnlockFailureKind.missingAsset,
      );
    }
  }

  ProtectedLessonEnvelope _parseEnvelope(String source, String lessonId) {
    try {
      return ProtectedLessonEnvelope.parse(jsonDecode(source), lessonId);
    } on LessonUnlockFailure {
      rethrow;
    } on Object {
      throw const LessonUnlockFailure(
        'The protected lesson content is invalid.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
  }

  Future<String> _decrypt(
    ProtectedLessonEnvelope envelope,
    String password,
  ) async {
    try {
      return await _decryptor.decrypt(envelope, normalizePassword(password));
    } on Object {
      throw const LessonUnlockFailure(
        'The lesson password was not accepted.',
        kind: LessonUnlockFailureKind.incorrectPassword,
      );
    }
  }

  Lesson _mapLesson(String plaintext, String lessonId) {
    try {
      final mappedLesson = _mapper.map(jsonDecode(plaintext));
      if (mappedLesson.id != lessonId) {
        throw const LessonUnlockFailure(
          'The protected lesson content is invalid.',
          kind: LessonUnlockFailureKind.invalidContent,
        );
      }
      return mappedLesson;
    } on LessonUnlockFailure {
      rethrow;
    } on Object {
      throw const LessonUnlockFailure(
        'The protected lesson content is invalid.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
  }
}
