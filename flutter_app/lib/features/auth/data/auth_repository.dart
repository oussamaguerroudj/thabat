import 'package:dio/dio.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_failure_mapper.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<AuthUser>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          if (displayName != null) 'display_name': displayName,
        },
      );

      return Result.ok(
        AuthUser.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<Unit>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'code': code,
        },
      );

      return Result.ok(Unit.value);
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<Unit>> resendVerification({
    required String email,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/resend-verification',
        data: {
          'email': email,
        },
      );

      return Result.ok(Unit.value);
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<TokenPair>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return Result.ok(
        TokenPair.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<Unit>> forgotPassword({
    required String email,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      return Result.ok(Unit.value);
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );

      return Result.ok(Unit.value);
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<Unit>> logout({
    required String refreshToken,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/logout',
        data: {
          'refresh_token': refreshToken,
        },
      );

      return Result.ok(Unit.value);
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }

  Future<Result<AuthUser>> me() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');

      return Result.ok(
        AuthUser.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }
}
