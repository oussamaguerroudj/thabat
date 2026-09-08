import '../../../core/errors/failure.dart';

/// Shared shape for every auth screen's submit-button state: idle, loading,
/// succeeded (screen reacts by navigating), or failed with a [Failure] the
/// UI can render (often via `failure.message`, sometimes branching on
/// `(failure as ApiFailure).code` for a specific backend error code like
/// `"unverified"` or `"resend_cooldown"`).
class AuthFormState {
  const AuthFormState({
    this.isSubmitting = false,
    this.failure,
    this.succeeded = false,
  });

  final bool isSubmitting;
  final Failure? failure;
  final bool succeeded;

  AuthFormState copyWith({
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
    bool? succeeded,
  }) {
    return AuthFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      succeeded: succeeded ?? this.succeeded,
    );
  }
}
