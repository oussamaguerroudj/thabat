import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../application/verification_controller.dart';
import '../data/verification_models.dart';

/// "نتيجة التحقق". Reads the last completed check from
/// [verificationControllerProvider] rather than a route parameter — the
/// full result (explanation + evidence list) doesn't fit cleanly through
/// a URL, and the controller already holds it from the in-progress screen
/// that triggered the call.
class VerificationResultScreen extends ConsumerWidget {
  const VerificationResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verificationControllerProvider);

    if (state is! VerificationCheckSuccess) {
      // Reaching this screen without a completed result (e.g. a deep link,
      // or app restart losing in-memory state) — send back to start a
      // real check rather than showing an empty/broken result screen.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.verify);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final result = state.result;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(title: const Text('نتيجة التحقق')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _StatusBadge(status: result.status),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(result.explanation, style: AppTypography.cairo(fontSize: 13, height: 1.8)),
            ),
            if (result.evidence.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('الأدلة المرجعية', style: AppTypography.cairo(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              for (final evidence in result.evidence) _EvidenceCard(evidence: evidence),
            ],
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(14)),
              child: Text(
                result.disclaimer,
                textAlign: TextAlign.center,
                style: AppTypography.cairo(fontSize: 11, color: AppColors.greenDeep, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'تحقق من محتوى آخر',
              onPressed: () {
                ref.read(verificationControllerProvider.notifier).reset();
                context.go(AppRoutes.verify);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VerificationStatus status;

  ({Color color, Color bg, String label, IconData icon}) _presentation() {
    switch (status) {
      case VerificationStatus.verified:
        return (color: const Color(0xFF1C6B3F), bg: const Color(0xFFE3F3E9), label: 'موثوق', icon: Icons.verified_outlined);
      case VerificationStatus.needsReview:
        return (color: const Color(0xFF8A6300), bg: const Color(0xFFFBF0D6), label: 'يحتاج إلى تحقق', icon: Icons.help_outline);
      case VerificationStatus.unreliable:
        return (color: const Color(0xFF8C1D18), bg: const Color(0xFFFBEAEA), label: 'غير موثوق', icon: Icons.cancel_outlined);
      case VerificationStatus.inconclusive:
      case VerificationStatus.unknown:
        return (color: AppColors.muted, bg: const Color(0xFFEFEBE0), label: 'تعذر التحقق', icon: Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _presentation();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(p.icon, size: 36, color: p.color),
          const SizedBox(height: AppSpacing.sm),
          Text(p.label, style: AppTypography.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: p.color)),
        ],
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.evidence});

  final VerificationEvidence evidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(evidence.sourceName, style: AppTypography.cairo(fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(evidence.content, style: AppTypography.cairo(fontSize: 11.5, color: AppColors.muted, height: 1.6)),
        ],
      ),
    );
  }
}
