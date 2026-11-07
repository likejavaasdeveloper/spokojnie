import 'protected_lesson_envelope.dart';

Future<String> decryptWithWebCrypto(
  ProtectedLessonEnvelope envelope,
  String password,
  void Function(Duration, Duration)? timingSink,
) {
  throw UnsupportedError('Web Crypto is available only in Flutter Web.');
}

String normalizePassword(String password) => password;
