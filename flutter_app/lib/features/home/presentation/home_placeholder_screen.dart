import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_repository_provider.dart';
import '../../../core/errors/result.dart';
import '../../../core/providers/auth_session_controller.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../auth/data/auth_models.dart';

/// Phase 6 places a genuinely functional (if visually minimal) Home screen
/// here — not [ComingSoonScreen] — specifically because Home is the one
/// place that proves the whole auth loop actually closes: it calls the
/// real, protected `/auth/me` endpoint (Phase 3) using the stored access
/// token, and offers a real logout. The full dashboard design from Phase 4
/// is still Phase 7's job; this is intentionally not that.
class HomePlaceholderScreen extends ConsumerStatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  ConsumerState<HomePlaceholderScreen> createState() => _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends ConsumerState<HomePlaceholderScreen> {
  Result<AuthUser>? _result;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final result = await ref.read(authRepositoryProvider).me();
    if (mounted) setState(() => _result = result);
  }

  Future<void> _logout() async {
    final refreshToken = await ref.read(tokenStorageProvider).readRefreshToken();
    if (refreshToken != null) {
      // Best-effort: revoke server-side, but log out locally regardless of
      // whether this call succeeds (matching the backend's own logout
      // semantics — Phase 3 `AuthService.logout` is idempotent/silent on
      // an already-invalid token).
      await ref.read(authRepositoryProvider).logout(refreshToken: refreshToken);
    }
    await ref.read(authSessionProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'تسجيل الخروج'),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final result = _result;
    if (result == null) return const LoadingView();

    return result.when(
      ok: (user) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 48, color: AppColors.greenDeep),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'مرحبًا ${user.displayName ?? user.email} 🌿',
                style: AppTypography.cairo(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'الحالة: ${user.accountStatus}',
                style: AppTypography.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'هذه شاشة مؤقتة تثبت أن حلقة تسجيل الدخول تعمل فعليًا مع'
                ' الخادم — التصميم الكامل من مرحلة 4 يُبنى في مرحلة 7.',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
      err: (failure) => ErrorView(message: failure.message, onRetry: _loadMe),
    );
  }
}
