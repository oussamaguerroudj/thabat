import 'package:equatable/equatable.dart';

/// Base class for all failures surfaced to the UI.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// The backend responded with a structured error envelope.
final class ApiFailure extends Failure {
  final String code;
  final int? statusCode;

  const ApiFailure({
    required this.code,
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  List<Object?> get props => [code, message, statusCode];
}

/// No network connectivity or request timeout.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
  ]) : super(message);
}

/// The access token is missing or the session has expired.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    String message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجددًا.',
  ]) : super(message);
}

/// An unexpected error occurred.
final class UnknownFailure extends Failure {
  const UnknownFailure([
    String message = 'حدث خطأ غير متوقع.',
  ]) : super(message);
}
