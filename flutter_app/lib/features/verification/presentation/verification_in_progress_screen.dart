import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../application/verification_controller.dart';

/// "جارٍ التحقق" — matches the prototype screen of the same name. Triggers
/// the real `/verification/check` call via [VerificationController] as
/// soon as it's shown, then replaces itself with the result screen (or
/// stays here with a retry option on failure) once that call resolves.
class VerificationInProgressScreen extends ConsumerStatefulWidget {
  const VerificationInProgressScreen({super.key, required this.content});

  final String content;

  @override
  ConsumerState<VerificationInProgressScreen> createState() =>
      _VerificationInProgressScreenState();
}

class _VerificationInProgressScreenState extends ConsumerState<VerificationInProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame so the loading UI is guaranteed to
    // paint before the (possibly fast, e.g. cached-DNS) request resolves.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(verificationControllerProvider.notifier).submit(widget.content);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verificationControllerProvider);

    ref.listen(verificationControllerProvider, (previous, next) {
      if (next is VerificationCheckSuccess) {
        context.go(AppRoutes.verifyResult);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: state is VerificationCheckError
                ? _ErrorState(
                    message: state.failure.message,
                    onRetry: () => ref.read(verificationControllerProvider.notifier).submit(widget.content),
                  )
                : const _LoadingState(),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.greenDeep),
        const SizedBox(height: AppSpacing.xl),
        Text('جارٍ التحقق من المحتوى...', style: AppTypography.cairo(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'نبحث في المصادر الموثوقة، قد يستغرق هذا بضع ثوانٍ.',
          textAlign: TextAlign.center,
          style: AppTypography.cairo(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 44, color: AppColors.muted),
        const SizedBox(height: AppSpacing.lg),
        Text(message, textAlign: TextAlign.center, style: AppTypography.cairo()),
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'إعادة المحاولة', onPressed: onRetry, expand: false),
      ],
    );
  }
}
