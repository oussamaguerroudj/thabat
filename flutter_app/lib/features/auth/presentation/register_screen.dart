import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/register_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    ref.listen(registerControllerProvider, (previous, next) {
      if (next.succeeded) {
        final email = Uri.encodeQueryComponent(_emailController.text.trim());
        context.go('${AppRoutes.verifyCode}?email=$email');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(controller: _nameController, label: 'الاسم (اختياري)'),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '8 أحرف على الأقل',
                style: AppTypography.cairo(fontSize: 11, color: AppColors.muted),
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
                label: 'إنشاء حساب',
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
    ref.read(registerControllerProvider.notifier).submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        );
  }
}
