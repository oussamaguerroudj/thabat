import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers/core_providers.dart';
import '../data/verification_models.dart';
import '../data/verification_repository.dart';

sealed class VerificationCheckState {
  const VerificationCheckState();
}

final class VerificationCheckIdle extends VerificationCheckState {
  const VerificationCheckIdle();
}

final class VerificationCheckLoading extends VerificationCheckState {
  const VerificationCheckLoading();
}

final class VerificationCheckSuccess extends VerificationCheckState {
  const VerificationCheckSuccess(this.result);
  final VerificationResult result;
}

final class VerificationCheckError extends VerificationCheckState {
  const VerificationCheckError(this.failure);
  final Failure failure;
}

class VerificationController extends StateNotifier<VerificationCheckState> {
  VerificationController(this._repo) : super(const VerificationCheckIdle());

  final VerificationRepository _repo;

  Future<void> submit(String content) async {
    state = const VerificationCheckLoading();
    final result = await _repo.check(content: content);
    state = result.when(
      ok: (data) => VerificationCheckSuccess(data),
      err: (failure) => VerificationCheckError(failure),
    );
  }

  void reset() => state = const VerificationCheckIdle();
}

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.watch(apiClientProvider));
});

/// Deliberately NOT autoDispose: the result screen navigated to after a
/// successful check needs to read this same state after the in-progress
/// screen (which triggered the call) is gone from the tree.
final verificationControllerProvider =
    StateNotifierProvider<VerificationController, VerificationCheckState>((ref) {
  return VerificationController(ref.watch(verificationRepositoryProvider));
});
