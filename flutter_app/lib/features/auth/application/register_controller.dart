import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_form_state.dart';
import 'auth_repository_provider.dart';

class RegisterController extends StateNotifier<AuthFormState> {
  RegisterController(this._ref) : super(const AuthFormState());

  final Ref _ref;

  Future<void> submit({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.when(
      // Registration succeeding means the backend has already issued a
      // verification code (Phase 3 `AuthService.register` calls
      // `_issue_and_send_code` inline) — the screen navigates to the
      // verify-code screen on `succeeded`, not to login.
      ok: (_) => state = state.copyWith(isSubmitting: false, succeeded: true),
      err: (failure) => state = state.copyWith(isSubmitting: false, failure: failure),
    );
  }
}

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, AuthFormState>((ref) {
  return RegisterController(ref);
});
