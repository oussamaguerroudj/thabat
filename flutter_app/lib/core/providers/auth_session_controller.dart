import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/token_storage.dart';

/// Whether the app currently believes it has a usable session
/// (a refresh token is stored — not proof the access token is still
/// valid this second, just that there's something to try). This is
/// intentionally coarse: it exists for the router's auth guard, not as a
/// substitute for each screen handling its own 401s via [Failure].
enum AuthSessionStatus { unknown, authenticated, unauthenticated }

class AuthSessionController extends StateNotifier<AuthSessionStatus> {
  AuthSessionController(this._tokenStorage) : super(AuthSessionStatus.unknown) {
    _restoreFromStorage();
  }

  final TokenStorage _tokenStorage;

  Future<void> _restoreFromStorage() async {
    final hasSession = await _tokenStorage.hasSession();
    state = hasSession ? AuthSessionStatus.authenticated : AuthSessionStatus.unauthenticated;
  }

  /// Called by the login/verify-email flow (Phase 6) once the backend
  /// returns a real token pair and it's been saved to [TokenStorage].
  void markAuthenticated() => state = AuthSessionStatus.authenticated;

  /// Called by [AuthInterceptor.onSessionExpired] when a refresh attempt
  /// fails outright, and by an explicit user-initiated logout (Phase 6).
  Future<void> logout() async {
    await _tokenStorage.clear();
    state = AuthSessionStatus.unauthenticated;
  }
}
