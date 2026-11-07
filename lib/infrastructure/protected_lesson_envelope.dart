import 'dart:convert';
import 'dart:typed_data';

import '../application/lesson_unlock_failure.dart';
import '../application/lesson_unlock_failure_kind.dart';

class ProtectedLessonEnvelope {
  const ProtectedLessonEnvelope({
    required this.salt,
    required this.nonce,
    required this.tag,
    required this.ciphertext,
    required this.associatedData,
  });

  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List tag;
  final Uint8List ciphertext;
  final String associatedData;

  static ProtectedLessonEnvelope parse(Object? value, String lessonId) {
    if (value is! Map<String, dynamic> ||
        value['version'] != 1 ||
        value['algorithm'] != 'AES-256-GCM' ||
        value['kdf'] != 'PBKDF2-HMAC-SHA-256') {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
    final parameters = value['kdfParameters'];
    if (parameters is! Map<String, dynamic> ||
        parameters['iterations'] != 600000 ||
        parameters['keyLength'] != 32) {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
    final expectedAssociatedData = 'spokojnie:lesson-envelope:v1:$lessonId';
    if (value['associatedData'] != expectedAssociatedData) {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
    final salt = _decode(parameters['salt'], 16);
    final nonce = _decode(value['nonce'], 12);
    final tag = _decode(value['tag'], 16);
    final ciphertext = _decode(value['ciphertext'], null);
    if (ciphertext.isEmpty) {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
    return ProtectedLessonEnvelope(
      salt: salt,
      nonce: nonce,
      tag: tag,
      ciphertext: ciphertext,
      associatedData: expectedAssociatedData,
    );
  }

  static Uint8List _decode(Object? value, int? expectedLength) {
    if (value is! String ||
        value.isEmpty ||
        !RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value)) {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
    try {
      final padded = value.padRight((value.length + 3) ~/ 4 * 4, '=');
      final decoded = Uint8List.fromList(base64Url.decode(padded));
      if (expectedLength != null && decoded.length != expectedLength) {
        throw const LessonUnlockFailure(
          'The lesson could not be unlocked.',
          kind: LessonUnlockFailureKind.invalidContent,
        );
      }
      return decoded;
    } on LessonUnlockFailure {
      rethrow;
    } on Object {
      throw const LessonUnlockFailure(
        'The lesson could not be unlocked.',
        kind: LessonUnlockFailureKind.invalidContent,
      );
    }
  }
}
