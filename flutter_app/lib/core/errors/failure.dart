import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

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

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.',
  ]);
}

final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجددًا.',
  ]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'حدث خطأ غير متوقع.',
  ]);
}
