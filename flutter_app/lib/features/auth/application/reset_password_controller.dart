import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_form_state.dart';
import 'auth_repository_provider.dart';

class ResetPasswordController extends StateNotifier<AuthFormState> {
  ResetPasswordController(this._ref) : super(const AuthFormState());

  final Ref _ref;

  Future<void> submit({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final repo = _ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );

    result.when(
      ok: (_) => state = state.copyWith(isSubmitting: false, succeeded: true),
      err: (failure) => state = state.copyWith(isSubmitting: false, failure: failure),
    );
  }
}

final resetPasswordControllerProvider =
    StateNotifierProvider.autoDispose<ResetPasswordController, AuthFormState>((ref) {
  return ResetPasswordController(ref);
});
