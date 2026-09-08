import 'package:dio/dio.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_failure_mapper.dart';
import 'verification_models.dart';

/// Calls to the backend's `/verification/*` endpoints (Phase 8 —
/// `app/api/verification.py`). Screens/controllers depend on this, never
/// on [ApiClient] directly.
class VerificationRepository {
  VerificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<VerificationResult>> check({required String content}) async {
    try {
      final response = await _apiClient.dio.post(
        '/verification/check',
        data: {'content': content},
      );
      return Result.ok(VerificationResult.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Result.err(mapDioExceptionToFailure(e));
    }
  }
}
