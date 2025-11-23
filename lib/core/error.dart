class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AppFirebaseException extends AppException {
  AppFirebaseException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class StorageException extends AppException {
  StorageException(super.message);
}

