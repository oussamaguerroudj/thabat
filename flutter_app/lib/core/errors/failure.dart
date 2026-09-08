import 'package:equatable/equatable.dart';

/// Mirrors the backend's error envelope from `app/core/errors.py`
/// (`{"error": {"code": ..., "message": ...}}`). Every failure surfaced to
/// the UI carries the same `code` the backend used, so a screen can branch
/// on `code` (e.g. `"unverified"`, `"invalid_credentials"`) instead of
/// parsing human-readable message text.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// The backend responded with a structured `{"error": {...}}` envelope —
/// `code` is the value from that envelope, e.g. `"invalid_credentials"`,
/// `"unverified"`, `"resend_cooldown"` (see backend `app/core/errors.py`
/// and `app/modules/auth/service.py` for the full set of codes in use).
final class ApiFailure extends Failure {
  final String code;
  final int? statusCode;

  const ApiFailure({
    required this.code,
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [code, message, statusCode];
}

/// No network connectivity, or the request timed out before reaching the
/// server at all — distinct from `ApiFailure` because the UI response is
/// different (offline state / retry), not an error envelope to render.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.']);
}

/// The access token is missing, expired, and the refresh attempt also
/// failed — the caller must treat this as "session ended," not a normal
/// API error to retry.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجددًا.']);
}

/// Anything that reached this app in a shape the client didn't expect
/// (malformed JSON, an unrecognized status code with no envelope, etc.) —
/// kept distinct from ApiFailure so it's never silently treated as if the
/// backend had returned a real error code.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع.']);
}
