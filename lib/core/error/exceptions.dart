class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CacheException extends AppException {
  const CacheException([super.message = 'Local storage error.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Item not found.']);
}
