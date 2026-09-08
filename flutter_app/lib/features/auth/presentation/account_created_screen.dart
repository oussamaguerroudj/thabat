import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 72, color: AppColors.greenDeep),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'تم إنشاء حسابك بنجاح',
                style: AppTypography.cairo(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'يمكنك الآن تسجيل الدخول والبدء في استخدام ثبات.',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'تسجيل الدخول',
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
