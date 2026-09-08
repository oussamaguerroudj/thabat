import 'package:dio/dio.dart';

import 'app_config.dart';

/// Thin wrapper around a configured [Dio] instance. Feature code depends on
/// this — never instantiates `Dio()` directly — so every HTTP call in the
/// app goes through the same base URL, timeouts, and interceptor chain.
class ApiClient {
  ApiClient({required this.dio});

  final Dio dio;

  factory ApiClient.create({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );
    dio.interceptors.addAll(interceptors);
    return ApiClient(dio: dio);
  }
}
