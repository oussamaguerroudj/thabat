import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the stored access token to every outgoing request, and on a 401
/// response performs exactly one refresh call against the backend's real
/// `/auth/refresh` endpoint (Phase 3 — `app/api/auth.py::refresh`), then
/// retries the original request once with the new access token.
///
/// Concurrency: if several requests hit 401 at the same moment, only the
/// first triggers a refresh call — the rest await that same in-flight
/// refresh instead of each calling `/auth/refresh` independently. This
/// matters because the backend **rotates** the refresh token on every use
/// (Phase 3 `AuthService.refresh`) — a second concurrent refresh call using
/// the now-already-consumed refresh token would fail with
/// `invalid_refresh_token`, wrongly logging the user out. `_refreshCompleter`
/// exists specifically to prevent that race.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshDio,
    required this.onSessionExpired,
  });

  final TokenStorage tokenStorage;

  /// A separate, interceptor-free [Dio] instance used only for the
  /// `/auth/refresh` call itself — using the main client here would risk
  /// this interceptor recursively intercepting its own refresh request.
  final Dio refreshDio;

  /// Called when refresh fails outright (refresh token invalid/expired) —
  /// the app must treat this as a real logout, typically by clearing
  /// storage and letting the router's auth guard redirect to login.
  final Future<void> Function() onSessionExpired;

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');

    if (!isUnauthorized || isRefreshCall) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      await onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await refreshDio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() async {
    // If a refresh is already in flight, piggyback on it instead of
    // starting a second one (see class doc for why this matters).
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        completer.complete(null);
        return null;
      }

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;
      await tokenStorage.saveTokenPair(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      completer.complete(newAccessToken);
      return newAccessToken;
    } on DioException {
      // Refresh token itself invalid/expired/revoked (401) — real logout.
      await tokenStorage.clear();
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }
}
