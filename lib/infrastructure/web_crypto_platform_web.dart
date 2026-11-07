import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'protected_lesson_envelope.dart';

extension type NormalizableJavaScriptString._(JSString _) implements JSString {
  external JSString normalize(JSString form);
}

Future<String> decryptWithWebCrypto(
  ProtectedLessonEnvelope envelope,
  String password,
  void Function(Duration, Duration)? timingSink,
) async {
  final subtle = (globalContext['crypto'] as JSObject)['subtle'] as JSObject;
  final kdfTimer = Stopwatch()..start();
  final passwordKey = await subtle.callMethodVarArgs<JSPromise<JSObject>>(
    'importKey'.toJS,
    [
      'raw'.toJS,
      Uint8List.fromList(utf8.encode(password)).toJS,
      {'name': 'PBKDF2'}.jsify(),
      false.toJS,
      ['deriveKey'].jsify(),
    ],
  ).toDart;
  final key = await subtle.callMethodVarArgs<JSPromise<JSObject>>(
    'deriveKey'.toJS,
    [
      {
        'name': 'PBKDF2',
        'salt': envelope.salt.toJS,
        'iterations': 600000,
        'hash': 'SHA-256',
      }.jsify(),
      passwordKey,
      {'name': 'AES-GCM', 'length': 256}.jsify(),
      false.toJS,
      ['decrypt'].jsify(),
    ],
  ).toDart;
  kdfTimer.stop();
  final encrypted = Uint8List(envelope.ciphertext.length + envelope.tag.length)
    ..setRange(0, envelope.ciphertext.length, envelope.ciphertext)
    ..setRange(
      envelope.ciphertext.length,
      envelope.ciphertext.length + envelope.tag.length,
      envelope.tag,
    );
  final decryptionTimer = Stopwatch()..start();
  final plaintext = await subtle.callMethodVarArgs<JSPromise<JSArrayBuffer>>(
    'decrypt'.toJS,
    [
      {
        'name': 'AES-GCM',
        'iv': envelope.nonce.toJS,
        'additionalData': utf8.encode(envelope.associatedData).toJS,
        'tagLength': 128,
      }.jsify(),
      key,
      encrypted.toJS,
    ],
  ).toDart;
  decryptionTimer.stop();
  timingSink?.call(kdfTimer.elapsed, decryptionTimer.elapsed);
  return utf8.decode(Uint8List.view(plaintext.toDart));
}

String normalizePassword(String password) =>
    NormalizableJavaScriptString._(password.toJS).normalize('NFKC'.toJS).toDart;
