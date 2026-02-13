/// Base exception for Tuteliq SDK errors.
class TuteliqException implements Exception {
  const TuteliqException(this.message, [this.details]);

  final String message;
  final dynamic details;

  @override
  String toString() => 'TuteliqException: $message';
}

/// Thrown when API key is invalid or missing.
class AuthenticationException extends TuteliqException {
  const AuthenticationException(super.message, [super.details]);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Thrown when rate limit is exceeded.
class RateLimitException extends TuteliqException {
  const RateLimitException(super.message, [super.details]);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Thrown when request validation fails.
class ValidationException extends TuteliqException {
  const ValidationException(super.message, [super.details]);

  @override
  String toString() => 'ValidationException: $message';
}

/// Thrown when a resource is not found.
class NotFoundException extends TuteliqException {
  const NotFoundException(super.message, [super.details]);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Thrown when the server returns a 5xx error.
class ServerException extends TuteliqException {
  const ServerException(super.message, this.statusCode, [super.details]);

  final int statusCode;

  @override
  String toString() => 'ServerException ($statusCode): $message';
}

/// Thrown when a request times out.
class TimeoutException extends TuteliqException {
  const TimeoutException(super.message, [super.details]);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Thrown when a network error occurs.
class NetworkException extends TuteliqException {
  const NetworkException(super.message, [super.details]);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the monthly quota is exceeded.
class QuotaExceededException extends TuteliqException {
  const QuotaExceededException(super.message, [super.details]);

  @override
  String toString() => 'QuotaExceededException: $message';
}

/// Thrown when an endpoint requires a higher tier.
class TierAccessException extends TuteliqException {
  const TierAccessException(super.message, [super.details]);

  @override
  String toString() => 'TierAccessException: $message';
}
