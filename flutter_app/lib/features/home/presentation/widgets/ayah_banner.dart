import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/home_mock_data.dart';

/// Ayah banner — matches `.dash-ayah`. See [MockAyah]'s doc comment: this
/// text must be checked against a verified mushaf source before Phase 10
/// treats it as production content.
class AyahBanner extends StatelessWidget {
  const AyahBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.goldLight),
          bottom: BorderSide(color: AppColors.goldLight),
        ),
      ),
      child: Column(
        children: [
          Text(
            MockAyah.text,
            textAlign: TextAlign.center,
            style: AppTypography.arefRuqaa(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(MockAyah.reference, style: AppTypography.cairo(fontSize: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}
