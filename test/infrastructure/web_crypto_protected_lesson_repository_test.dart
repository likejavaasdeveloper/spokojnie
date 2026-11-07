import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:spokojnie/application/lesson_unlock_failure.dart';
import 'package:spokojnie/application/lesson_unlock_failure_kind.dart';
import 'package:spokojnie/domain/lesson_access.dart';
import 'package:spokojnie/domain/lesson_summary.dart';
import 'package:spokojnie/infrastructure/lesson_decryptor.dart';
import 'package:spokojnie/infrastructure/web_crypto_protected_lesson_repository.dart';
import '../support/memory_asset_bundle.dart';

void main() {
  final protectedLesson = LessonSummary(
    id: 'lesson_003',
    title: 'Lekcja testowa',
    access: LessonAccess.protected,
  );
  final freeLesson = LessonSummary(
    id: 'lesson_001',
    title: 'Lekcja darmowa',
    access: LessonAccess.free,
  );

  test(
    'loads and maps a protected lesson through the decryptor port',
    () async {
      final repository = WebCryptoProtectedLessonRepository(
        assetBundle: MemoryAssetBundle({
          'test/lesson_003.enc.json': _envelope(),
        }),
        decryptor: _FakeDecryptor(_lessonJson()),
        protectedAssetDirectory: 'test',
      );

      final lesson = await repository.unlock(
        protectedLesson,
        'Ｐassword-123456',
      );

      expect(lesson.id, 'lesson_003');
      expect(lesson.items.single.understand.sentence, 'To jest test.');
    },
  );

  test('rejects a free lesson before loading an asset', () async {
    final repository = WebCryptoProtectedLessonRepository(
      assetBundle: MemoryAssetBundle({}),
      decryptor: _FakeDecryptor(_lessonJson()),
      protectedAssetDirectory: 'test',
    );

    await expectLater(
      repository.unlock(freeLesson, 'Password-123456'),
      throwsA(isA<LessonUnlockFailure>()),
    );
  });

  test('classifies missing assets separately from password failures', () async {
    final repository = WebCryptoProtectedLessonRepository(
      assetBundle: MemoryAssetBundle({}),
      decryptor: _FakeDecryptor(_lessonJson()),
      protectedAssetDirectory: 'test',
    );

    try {
      await repository.unlock(protectedLesson, 'Password-123456');
      fail('Expected a missing asset failure.');
    } on LessonUnlockFailure catch (error) {
      expect(error.kind, LessonUnlockFailureKind.missingAsset);
    }
  });

  test('classifies decryption failures as password failures', () async {
    final repository = WebCryptoProtectedLessonRepository(
      assetBundle: MemoryAssetBundle({'test/lesson_003.enc.json': _envelope()}),
      decryptor: _FailingDecryptor(),
      protectedAssetDirectory: 'test',
    );

    try {
      await repository.unlock(protectedLesson, 'Password-123456');
      fail('Expected a password failure.');
    } on LessonUnlockFailure catch (error) {
      expect(error.kind, LessonUnlockFailureKind.incorrectPassword);
    }
  });

  for (final invalidEnvelope in <String, String>{
    'unsupported version': _envelope(version: 2),
    'invalid associated data': _envelope(associatedData: 'wrong'),
    'invalid salt': _envelope(salt: 'AA'),
    'invalid nonce': _envelope(nonce: 'AA'),
    'invalid authentication tag': _envelope(tag: 'AA'),
    'invalid ciphertext': _envelope(ciphertext: ''),
  }.entries) {
    test('rejects ${invalidEnvelope.key}', () async {
      final repository = WebCryptoProtectedLessonRepository(
        assetBundle: MemoryAssetBundle({
          'test/lesson_003.enc.json': invalidEnvelope.value,
        }),
        decryptor: _FakeDecryptor(_lessonJson()),
        protectedAssetDirectory: 'test',
      );

      await expectLater(
        repository.unlock(protectedLesson, 'Password-123456'),
        throwsA(isA<LessonUnlockFailure>()),
      );
    });
  }

  test('rejects invalid decrypted JSON and identifier mismatch', () async {
    final invalidJsonRepository = WebCryptoProtectedLessonRepository(
      assetBundle: MemoryAssetBundle({'test/lesson_003.enc.json': _envelope()}),
      decryptor: _FakeDecryptor('{"id":"lesson_003","items":[]}'),
      protectedAssetDirectory: 'test',
    );
    final mismatchedRepository = WebCryptoProtectedLessonRepository(
      assetBundle: MemoryAssetBundle({'test/lesson_003.enc.json': _envelope()}),
      decryptor: _FakeDecryptor(
        _lessonJson().replaceFirst('lesson_003', 'lesson_004'),
      ),
      protectedAssetDirectory: 'test',
    );

    await expectLater(
      invalidJsonRepository.unlock(protectedLesson, 'Password-123456'),
      throwsA(isA<LessonUnlockFailure>()),
    );
    await expectLater(
      mismatchedRepository.unlock(protectedLesson, 'Password-123456'),
      throwsA(isA<LessonUnlockFailure>()),
    );
  });
}

class _FakeDecryptor implements LessonDecryptor {
  _FakeDecryptor(this.content);

  final String content;
  String? password;

  @override
  Future<String> decrypt(envelope, String password) async {
    this.password = password;
    return content;
  }
}

class _FailingDecryptor implements LessonDecryptor {
  @override
  Future<String> decrypt(envelope, String password) {
    throw StateError('synthetic authentication failure');
  }
}

String _lessonJson() => jsonEncode({
  'id': 'lesson_003',
  'items': [
    {
      'id': 'fixture_item_001',
      'steps': {
        'understand': {
          'sentence': 'To jest test.',
          'translation': 'این یک آزمون است.',
          'vocabulary': [
            {'word': 'To jest', 'meaning': 'این است'},
            {'word': 'test', 'meaning': 'آزمون'},
          ],
        },
        'recall': {'prompt': 'این یک آزمون است.', 'answer': 'To jest test.'},
        'variation': {
          'prompt': 'این یک درس است.',
          'answer': 'To jest lekcja.',
          'translation': 'این یک درس است.',
        },
      },
    },
  ],
});

String _envelope({
  int version = 1,
  String associatedData = 'spokojnie:lesson-envelope:v1:lesson_003',
  String salt = 'AAAAAAAAAAAAAAAAAAAAAA',
  String nonce = 'AAAAAAAAAAAAAAAA',
  String tag = 'AAAAAAAAAAAAAAAAAAAAAA',
  String ciphertext = 'AQ',
}) => jsonEncode({
  'version': version,
  'algorithm': 'AES-256-GCM',
  'kdf': 'PBKDF2-HMAC-SHA-256',
  'kdfParameters': {'salt': salt, 'iterations': 600000, 'keyLength': 32},
  'nonce': nonce,
  'tag': tag,
  'associatedData': associatedData,
  'ciphertext': ciphertext,
});
