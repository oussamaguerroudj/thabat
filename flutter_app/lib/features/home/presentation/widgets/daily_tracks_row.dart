import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/home_mock_data.dart';

/// Section header row with an optional trailing link — matches
/// `.dash-section-head` (used above both the daily-tracks strip and the
/// suggestions/community section).
class DashSectionHead extends StatelessWidget {
  const DashSectionHead({super.key, required this.title, this.trailing, this.onTrailingTap});

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.cairo(fontSize: 13.5, fontWeight: FontWeight.w800)),
          if (trailing != null)
            InkWell(
              onTap: onTrailingTap,
              child: Text(trailing!, style: AppTypography.cairo(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.greenDeep,
              )),
            ),
        ],
      ),
    );
  }
}

/// Daily tracks strip — matches `.dash-tracks`. Data is
/// [MockDailyTrack.all] until Phase 17 (Daily Journey) supplies real
/// per-day tracking state.
class DailyTracksRow extends StatelessWidget {
  const DailyTracksRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            for (final track in MockDailyTrack.all) Expanded(child: _buildTrack(track)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrack(MockDailyTrack track) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.beige, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(track.icon, style: const TextStyle(fontSize: 14)),
            ),
            if (track.completed)
              Positioned(
                top: -3,
                left: -3,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(color: AppColors.greenDeep, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Icon(Icons.check, size: 9, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(track.label, style: AppTypography.cairo(fontSize: 9.5, fontWeight: FontWeight.w700)),
        Text(track.value, style: AppTypography.cairo(fontSize: 9, color: AppColors.muted)),
      ],
    );
  }
}
