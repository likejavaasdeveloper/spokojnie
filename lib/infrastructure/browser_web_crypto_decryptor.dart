import 'lesson_decryptor.dart';
import 'protected_lesson_envelope.dart';
import 'web_crypto_platform.dart';

class BrowserWebCryptoDecryptor implements LessonDecryptor {
  const BrowserWebCryptoDecryptor({this.timingSink});

  final void Function(Duration, Duration)? timingSink;

  @override
  Future<String> decrypt(ProtectedLessonEnvelope envelope, String password) {
    return decryptWithWebCrypto(envelope, password, timingSink);
  }
}
