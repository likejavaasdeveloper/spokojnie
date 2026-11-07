import 'protected_lesson_envelope.dart';

import 'web_crypto_platform_stub.dart'
    if (dart.library.js_interop) 'web_crypto_platform_web.dart'
    as platform;

Future<String> decryptWithWebCrypto(
  ProtectedLessonEnvelope envelope,
  String password,
  void Function(Duration, Duration)? timingSink,
) => platform.decryptWithWebCrypto(envelope, password, timingSink);

String normalizePassword(String password) =>
    platform.normalizePassword(password);
