import 'protected_lesson_envelope.dart';

abstract interface class LessonDecryptor {
  Future<String> decrypt(ProtectedLessonEnvelope envelope, String password);
}
