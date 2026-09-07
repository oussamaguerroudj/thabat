import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/login_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    ref.listen(loginControllerProvider, (previous, next) {
      if (next.succeeded) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text('ثبات', textAlign: TextAlign.center, style: AppTypography.arefRuqaa(fontSize: 40)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'تسجيل الدخول',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xxl),
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
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.forgotPassword),
                  child: Text('نسيت كلمة المرور؟', style: AppTypography.cairo(color: AppColors.greenDeep)),
                ),
              ),
              if (state.failure != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _LoginErrorMessage(failure: state.failure!),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'تسجيل الدخول',
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ليس لديك حساب؟', style: AppTypography.cairo(color: AppColors.muted)),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: Text('إنشاء حساب', style: AppTypography.cairo(
                      color: AppColors.greenDeep,
                      fontWeight: FontWeight.w700,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    ref.read(loginControllerProvider.notifier).submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}

/// Renders the backend's real error codes distinctly where it matters —
/// `unverified` gets a link back to the verify-code screen instead of just
/// a plain error string, since that's an actionable next step, not a dead
/// end (see backend `app/modules/auth/service.py::login`).
class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final isUnverified = failure is ApiFailure && (failure as ApiFailure).code == 'unverified';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            failure.message,
            textAlign: TextAlign.center,
            style: AppTypography.cairo(fontSize: 12.5, color: const Color(0xFF8C1D18)),
          ),
          if (isUnverified) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => GoRouter.of(context).go(AppRoutes.verifyCode),
              child: const Text('التحقق من البريد الإلكتروني الآن'),
            ),
          ],
        ],
      ),
    );
  }
}
