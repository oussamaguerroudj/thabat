import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Maps a [DioException] to the app's [Failure] hierarchy. Every feature
/// repository should funnel its try/catch through this — the backend's
/// error envelope shape (`app/core/errors.py::_error_envelope`,
/// `{"error": {"code": ..., "message": ...}}`) is only parsed here, not
/// re-implemented per feature.
Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkFailure();
    default:
      break;
  }

  final response = exception.response;
  if (response == null) {
    return const NetworkFailure();
  }

  final data = response.data;
  if (data is Map && data['error'] is Map) {
    final errorMap = data['error'] as Map;
    return ApiFailure(
      code: errorMap['code'] as String? ?? 'unknown',
      message: errorMap['message'] as String? ?? 'حدث خطأ غير متوقع.',
      statusCode: response.statusCode,
    );
  }

  // FastAPI's own validation errors (422 from Pydantic, before request even
  // reaches our handlers) don't use the {"error": {...}} envelope — they
  // use FastAPI's default `{"detail": [...]}` shape. Surface *something*
  // useful rather than silently falling through to UnknownFailure.
  if (data is Map && data['detail'] != null) {
    return ApiFailure(
      code: 'validation_error',
      message: 'تحقق من صحة البيانات المُدخلة.',
      statusCode: response.statusCode,
    );
  }

  return const UnknownFailure();
}
