import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps `flutter_secure_storage` for exactly the two secrets this app
/// persists client-side: the JWT access token and the raw refresh token
/// from the backend's `/auth/login` and `/auth/refresh` responses (see
/// backend `app/modules/auth/schemas.py::TokenPairResponse`).
///
/// Nothing outside this class should call `FlutterSecureStorage` directly —
/// same discipline as the backend's provider adapters (ADR-006/007/008):
/// one file owns the sensitive-storage surface area.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'thabat_access_token';
  static const _refreshTokenKey = 'thabat_refresh_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Updates only the access token — used after a successful silent
  /// refresh when the backend rotates the refresh token too (Phase 3's
  /// `/auth/refresh` rotates both; use [saveTokenPair] for that path).
  Future<void> updateAccessToken(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasSession() async {
    final refresh = await readRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }
}
