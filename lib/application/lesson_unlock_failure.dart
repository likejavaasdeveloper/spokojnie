import 'lesson_unlock_failure_kind.dart';

class LessonUnlockFailure implements Exception {
  const LessonUnlockFailure(
    this.message, {
    this.kind = LessonUnlockFailureKind.unknown,
  });

  final String message;
  final LessonUnlockFailureKind kind;

  @override
  String toString() => message;
}
