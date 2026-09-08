import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/forgot_password_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.succeeded) {
        final email = Uri.encodeQueryComponent(_emailController.text.trim());
        context.go('${AppRoutes.resetPassword}?email=$email');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('نسيت كلمة المرور')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أدخل بريدك الإلكتروني وسنرسل لك رمزًا لإعادة تعيين كلمة المرور.',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
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
                label: 'إرسال الرمز',
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
    ref.read(forgotPasswordControllerProvider.notifier).submit(
          email: _emailController.text.trim(),
        );
  }
}
