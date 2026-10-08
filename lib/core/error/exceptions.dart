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

class InvalidBackupException extends AppException {
  const InvalidBackupException(super.message);
}

class FileException extends AppException {
  const FileException([super.message = 'Could not open or save the file.']);
}
