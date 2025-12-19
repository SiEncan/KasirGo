/// Unified exception class for the entire app
class AppException implements Exception {
  final String message;
  final AppExceptionType type;

  AppException(this.message, {this.type = AppExceptionType.general});

  /// Server tidak merespon (timeout)
  factory AppException.serverTimeout() => AppException(
    'Server is not responding. Please try again later.',
    type: AppExceptionType.server,
  );

  /// Masalah koneksi internet user
  factory AppException.network() => AppException(
    'Please check your internet connection.',
    type: AppExceptionType.network,
  );

  factory AppException.sessionExpired() => AppException(
    'Session expired. Please login again.',
    type: AppExceptionType.sessionExpired,
  );

  factory AppException.server(String? message) => AppException(
    message ?? 'Something went wrong. Please try again.',
    type: AppExceptionType.server,
  );

  @override
  String toString() => message;

  bool get isSessionExpired => type == AppExceptionType.sessionExpired;
  bool get isNetwork => type == AppExceptionType.network;
}

enum AppExceptionType {
  network,
  sessionExpired,
  server,
  general,
}
