@TestOn('chrome')
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/lesson_unlock_failure.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/infrastructure/browser_web_crypto_decryptor.dart';
import 'package:spokojnie/infrastructure/web_crypto_protected_lesson_repository.dart';
import '../fixtures/lesson_003_encrypted_fixture.dart';
import '../support/memory_asset_bundle.dart';

void main() {
  final lesson = LessonSummary(
    id: 'lesson_003',
    title: 'Fixture',
    access: LessonAccess.protected,
  );
  test('decrypts the Node-generated fixture in Chrome', () async {
    final result = await _repository().unlock(
      lesson,
      'ＮonProduction-PhaseD-Password',
    );

    expect(result.id, 'lesson_003');
    expect(result.items.single.recall.answer, 'To jest test.');
  });

  test('rejects an incorrect password without exposing plaintext', () async {
    await expectLater(
      _repository().unlock(lesson, 'Wrong-NonProduction-Password'),
      throwsA(isA<LessonUnlockFailure>()),
    );
  });

  test('rejects a tampered authentication tag', () async {
    await expectLater(
      _repository(
        _withEnvelopeValue('tag', 'AAAAAAAAAAAAAAAAAAAAAA'),
      ).unlock(lesson, 'NonProduction-PhaseD-Password'),
      throwsA(isA<LessonUnlockFailure>()),
    );
  });

  test('rejects invalid associated data', () async {
    await expectLater(
      _repository(
        _withEnvelopeValue('associatedData', 'wrong'),
      ).unlock(lesson, 'NonProduction-PhaseD-Password'),
      throwsA(isA<LessonUnlockFailure>()),
    );
  });

  test(
    'keeps protected lessons isolated by lesson-bound associated data',
    () async {
      final otherLesson = LessonSummary(
        id: 'lesson_004',
        title: 'Other fixture',
        access: LessonAccess.protected,
      );
      final repository = _repository(encryptedLessonFixture, true);

      await expectLater(
        repository.unlock(otherLesson, 'NonProduction-PhaseD-Password'),
        throwsA(isA<LessonUnlockFailure>()),
      );
    },
  );

  test('measures PBKDF2 and AES-GCM independently', () async {
    Duration? kdfDuration;
    Duration? decryptionDuration;
    final repository = _repository(
      encryptedLessonFixture,
      false,
      BrowserWebCryptoDecryptor(
        timingSink: (kdf, decryption) {
          kdfDuration = kdf;
          decryptionDuration = decryption;
        },
      ),
    );

    await repository.unlock(lesson, 'NonProduction-PhaseD-Password');

    expect(kdfDuration, isNotNull);
    expect(decryptionDuration, isNotNull);
    debugPrint('PBKDF2: $kdfDuration; AES-GCM: $decryptionDuration');
  });
}

WebCryptoProtectedLessonRepository _repository([
  String fixture = encryptedLessonFixture,
  bool includeOtherLesson = false,
  BrowserWebCryptoDecryptor? decryptor,
]) {
  final assets = <String, String>{'assets/test/lesson_003.enc.json': fixture};
  if (includeOtherLesson) {
    assets['assets/test/lesson_004.enc.json'] = fixture;
  }
  return WebCryptoProtectedLessonRepository(
    assetBundle: MemoryAssetBundle(assets),
    decryptor: decryptor,
    protectedAssetDirectory: 'assets/test',
  );
}

String _withEnvelopeValue(String field, String value) {
  final envelope = jsonDecode(encryptedLessonFixture) as Map<String, dynamic>;
  envelope[field] = value;
  return jsonEncode(envelope);
}
