import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/home_mock_data.dart';

/// The three stat cards — matches `.dash-stats-row`. Tapping "عرض
/// الأهداف" navigates to the real (placeholder) Goals route.
class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.onGoalsTap});

  final VoidCallback onGoalsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(child: _TasbeehCard()),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _JourneyCard()),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _GoalsCard(onTap: onGoalsTap)),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: dark ? null : Colors.white,
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF20493A), Color(0xFF173229)],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: dark ? null : Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _TasbeehCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Text('السبحة', style: AppTypography.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('📿', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text('${MockStatsData.tasbeehCount}', style: AppTypography.cairo(fontSize: 15, fontWeight: FontWeight.w800)),
          Text('تسبيحة', style: AppTypography.cairo(fontSize: 9.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final percent = MockStatsData.dailyJourneyPercent / 100;
    return _CardShell(
      dark: true,
      child: Column(
        children: [
          Text('المسار اليومي', style: AppTypography.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
                Text('${MockStatsData.dailyJourneyPercent}%', style: AppTypography.cairo(
                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white,
                )),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              MockStatsData.dailyJourneyNote,
              textAlign: TextAlign.center,
              style: AppTypography.cairo(fontSize: 9, color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Text('أهدافك', style: AppTypography.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('🎯', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.beige, borderRadius: BorderRadius.circular(999)),
              child: Text('عرض الأهداف', style: AppTypography.cairo(
                fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.greenDeep,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
