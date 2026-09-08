import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// "اسأل ثبات" card — matches `.dash-ai-card`. Tapping it navigates to the
/// Ask Thabat screen (Phase 9); until then it's a real, tappable card
/// pointed at a real (placeholder) route, not a dead visual element.
class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.greenDeep, AppColors.green],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🤖', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اسأل ثبات', style: AppTypography.cairo(
                        fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      const SizedBox(height: 4),
                      Text(
                        'مساعدك المعلوماتي للإجابة عن أسئلتك في الأمور الدينية استنادًا إلى مصادر موثوقة',
                        style: AppTypography.cairo(fontSize: 11.5, color: Colors.white.withOpacity(0.75), height: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Text('تحدث الآن 💬', style: AppTypography.cairo(
                          fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white,
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "تحقق قبل أن تنشر" compact strip — matches `.dash-verify-strip`. This
/// exists specifically so verification stays reachable in one tap from
/// Home even though it isn't itself a bottom-nav tab destination other
/// than via [AppBottomNav]'s التحقق item — see the discussion in Phase 4
/// about keeping verification highly visible per the project brief.
class VerifyStrip extends StatelessWidget {
  const VerifyStrip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.goldLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تحقق قبل أن تنشر', style: AppTypography.cairo(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.greenDeep,
                  )),
                  const SizedBox(height: 2),
                  Text('تحقق من حديث أو محتوى ديني الآن', style: AppTypography.cairo(
                    fontSize: 10.5, color: AppColors.muted,
                  )),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('تحقق'),
            ),
          ],
        ),
      ),
    );
  }
}
