/// Centralized error types for the application.
sealed class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, [this.details]);

  @override
  String toString() => 'AppException: $message${details != null ? ' ($details)' : ''}';
}

/// Thrown when Firestore credentials are invalid.
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Invalid username or password. Please try again.');
}

/// Thrown when a user already exists in Firestore.
class UserAlreadyExistsException extends AppException {
  final String userId;
  const UserAlreadyExistsException(this.userId)
      : super('User "$userId" already exists.');
}

/// Thrown when a user is not found in Firestore.
class UserNotFoundException extends AppException {
  final String userId;
  const UserNotFoundException(this.userId)
      : super('User "$userId" does not exist.');
}

/// Thrown when a token operation fails (e.g., already used, sold out).
class TokenException extends AppException {
  final TokenErrorType type;
  const TokenException(this.type, String message) : super(message);
}

enum TokenErrorType { alreadyUsed, soldOut, notFound, insufficientCount }

/// Thrown for generic Firestore or network errors.
class FirestoreException extends AppException {
  const FirestoreException([String? details])
      : super('Unable to complete the operation. Please check your connection and try again.', details);
}

/// Thrown when an operation is forbidden for the current role.
class PermissionDeniedException extends AppException {
  const PermissionDeniedException()
      : super('You do not have permission to perform this action.');
}

/// Thrown when QR data format is invalid.
class InvalidQrDataException extends AppException {
  const InvalidQrDataException()
      : super('Invalid QR code. Please scan a valid token QR.');
}

/// Thrown when a student's DOJ exceeds the allowed limit for their course.
class StudentValidationException extends AppException {
  const StudentValidationException(super.message);
}
