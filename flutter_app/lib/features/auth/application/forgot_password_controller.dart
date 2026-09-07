import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_form_state.dart';
import 'auth_repository_provider.dart';

class ForgotPasswordController extends StateNotifier<AuthFormState> {
  ForgotPasswordController(this._ref) : super(const AuthFormState());

  final Ref _ref;

  Future<void> submit({required String email}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final repo = _ref.read(authRepositoryProvider);
    // Backend always returns 204 here regardless of whether the email
    // exists (Phase 3 — account-existence-leak prevention), so `succeeded`
    // is the only outcome on the happy path; a Failure here means a real
    // transport/server problem, not "email not found".
    final result = await repo.forgotPassword(email: email);

    result.when(
      ok: (_) => state = state.copyWith(isSubmitting: false, succeeded: true),
      err: (failure) => state = state.copyWith(isSubmitting: false, failure: failure),
    );
  }
}

final forgotPasswordControllerProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordController, AuthFormState>((ref) {
  return ForgotPasswordController(ref);
});
