import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../network/app_config.dart';
import '../network/auth_interceptor.dart';
import '../storage/token_storage.dart';
import 'auth_session_controller.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// A plain Dio instance with no interceptors, used only by [AuthInterceptor]
/// to call `/auth/refresh` itself — see that file's doc comment for why it
/// can't reuse the main intercepted client.
final _refreshDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
});

final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AuthSessionStatus>((ref) {
  return AuthSessionController(ref.watch(tokenStorageProvider));
});

final _authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(
    tokenStorage: ref.watch(tokenStorageProvider),
    refreshDio: ref.watch(_refreshDioProvider),
    onSessionExpired: () => ref.read(authSessionProvider.notifier).logout(),
  );
});

/// The API client every feature repository should depend on.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.create(interceptors: [ref.watch(_authInterceptorProvider)]);
});
