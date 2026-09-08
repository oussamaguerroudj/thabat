import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';

/// Centered spinner for a screen/section that's fetching data. Prefer this
/// over an ad-hoc `CircularProgressIndicator()` so loading states look
/// consistent across every feature.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.greenDeep),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: AppTypography.cairo(color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

/// Empty-state placeholder — matches the prototype's "حالات فارغة" screen
/// intent (an icon, a short message, and an optional action) rather than
/// leaving a feature screen blank when there's genuinely nothing to show.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.muted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.cairo(color: AppColors.muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error-state placeholder for a failed fetch/action — always offers a
/// retry, since a dead end with no way forward is the thing to avoid per
/// the project's error-handling rule (every feature needs loading/success/
/// empty/error/retry states).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.muted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.cairo(color: AppColors.charcoal),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'إعادة المحاولة', onPressed: onRetry, expand: false),
          ],
        ),
      ),
    );
  }
}

/// Slim persistent banner shown app-wide while the device has no network —
/// see `core/connectivity/connectivity_provider.dart` for what feeds this.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.greenDeep,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: AppSpacing.lg),
      child: Text(
        'لا يوجد اتصال بالإنترنت',
        textAlign: TextAlign.center,
        style: AppTypography.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
        ),
      ),
    );
  }
}
