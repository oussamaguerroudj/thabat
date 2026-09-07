import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import 'auth_form_state.dart';
import 'auth_repository_provider.dart';

class VerifyCodeController extends StateNotifier<AuthFormState> {
  VerifyCodeController(this._ref) : super(const AuthFormState());

  final Ref _ref;

  Future<void> verify({required String email, required String code}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.verifyEmail(email: email, code: code);

    result.when(
      ok: (_) => state = state.copyWith(isSubmitting: false, succeeded: true),
      // Common failure here is ApiFailure(code: 'invalid_code') — the
      // screen renders `failure.message` directly, which the backend
      // already phrases for end users (see
      // backend app/modules/auth/service.py::_check_code).
      err: (failure) => state = state.copyWith(isSubmitting: false, failure: failure),
    );
  }

  /// Resend is deliberately a separate method (not folded into [verify])
  /// so the UI can show its own small "code sent" confirmation without
  /// touching the main submit state, and so a `resend_cooldown`
  /// ApiFailure from the backend renders in that same small area rather
  /// than replacing the whole screen with an error state.
  Future<Result<Unit>> resend({required String email}) {
    final repo = _ref.read(authRepositoryProvider);
    return repo.resendVerification(email: email);
  }
}

final verifyCodeControllerProvider =
    StateNotifierProvider.autoDispose<VerifyCodeController, AuthFormState>((ref) {
  return VerifyCodeController(ref);
});
