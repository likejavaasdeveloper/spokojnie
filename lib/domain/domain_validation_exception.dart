class DomainValidationException implements Exception {
  const DomainValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
