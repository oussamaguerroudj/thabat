import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_session_controller.dart';
import '../../../core/providers/core_providers.dart';
import 'auth_form_state.dart';
import 'auth_repository_provider.dart';

class LoginController extends StateNotifier<AuthFormState> {
  LoginController(this._ref) : super(const AuthFormState());

  final Ref _ref;

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);

    result.when(
      ok: (tokenPair) async {
        await _ref.read(tokenStorageProvider).saveTokenPair(
              accessToken: tokenPair.accessToken,
              refreshToken: tokenPair.refreshToken,
            );
        // This is what flips the router's auth guard — see
        // core/router/app_router.dart's `_authGuard`.
        _ref.read(authSessionProvider.notifier).markAuthenticated();
        state = state.copyWith(isSubmitting: false, succeeded: true);
      },
      err: (failure) {
        state = state.copyWith(isSubmitting: false, failure: failure);
      },
    );
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AuthFormState>((ref) {
  return LoginController(ref);
});
