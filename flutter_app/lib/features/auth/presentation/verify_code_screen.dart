import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/verify_code_controller.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  String? _resendMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyCodeControllerProvider);

    ref.listen(verifyCodeControllerProvider, (previous, next) {
      if (next.succeeded) {
        context.go(AppRoutes.accountCreated);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أدخل الرمز المكوّن من 6 أرقام المُرسل إلى\n${widget.email}',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                controller: _codeController,
                label: 'رمز التحقق',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (state.failure != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.failure!.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.cairo(fontSize: 12.5, color: const Color(0xFF8C1D18)),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'تأكيد',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _resend,
                child: Text('إعادة إرسال الرمز', style: AppTypography.cairo(color: AppColors.greenDeep)),
              ),
              if (_resendMessage != null)
                Text(
                  _resendMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.cairo(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    ref.read(verifyCodeControllerProvider.notifier).verify(
          email: widget.email,
          code: _codeController.text.trim(),
        );
  }

  Future<void> _resend() async {
    final result = await ref.read(verifyCodeControllerProvider.notifier).resend(email: widget.email);
    if (!mounted) return;
    result.when(
      // Backend returns 204 whether or not the email exists/needs it (no
      // account-existence leak) — same message either way is intentional,
      // not a missing distinction.
      ok: (_) => setState(() => _resendMessage = 'تم إرسال رمز جديد.'),
      err: (failure) => setState(() => _resendMessage = failure.message),
    );
  }
}
