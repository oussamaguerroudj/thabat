import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/reset_password_controller.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);

    ref.listen(resetPasswordControllerProvider, (previous, next) {
      if (next.succeeded) {
        context.go(AppRoutes.login);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أدخل رمز التحقق المُرسل إلى ${widget.email} وكلمة المرور الجديدة.',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                controller: _codeController,
                label: 'رمز التحقق',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _passwordController,
                label: 'كلمة المرور الجديدة',
                obscureText: true,
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
                label: 'تعيين كلمة المرور',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    ref.read(resetPasswordControllerProvider.notifier).submit(
          email: widget.email,
          code: _codeController.text.trim(),
          newPassword: _passwordController.text,
        );
  }
}
