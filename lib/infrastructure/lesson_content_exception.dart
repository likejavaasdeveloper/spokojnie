class LessonContentException implements Exception {
  const LessonContentException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
