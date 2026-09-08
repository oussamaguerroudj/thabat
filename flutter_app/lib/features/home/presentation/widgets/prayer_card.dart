import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/home_mock_data.dart';

/// Prayer card + times row — matches `.dash-prayer-card` /
/// `.dash-prayer-times`. Data is [MockPrayerData] until Phase 13 (Prayer &
/// Adhan) supplies real calculation + device location.
class PrayerCard extends StatelessWidget {
  const PrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF20493A), Color(0xFF173229)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🕌 ${MockPrayerData.currentPrayerName}', style: AppTypography.cairo(
                            fontSize: 13, color: Colors.white.withOpacity(0.75),
                          )),
                          const SizedBox(height: 4),
                          Text(MockPrayerData.currentPrayerTime, style: AppTypography.cairo(
                            fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                          const SizedBox(height: 4),
                          Text('◔ ${MockPrayerData.countdown}', style: AppTypography.cairo(
                            fontSize: 11, color: AppColors.goldLight,
                          )),
                        ],
                      ),
                      Text('📍 ${MockPrayerData.location}', style: AppTypography.cairo(
                        fontSize: 11, color: Colors.white.withOpacity(0.7),
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: CustomPaint(painter: _SkylinePainter(), size: const Size(double.infinity, 40)),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                for (final t in MockPrayerData.otherTimes)
                  Expanded(
                    child: Column(
                      children: [
                        Text(t.label, style: AppTypography.cairo(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(t.time, style: AppTypography.cairo(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple abstract skyline silhouette — matches the decorative inline
/// SVG in `.dash-prayer-skyline`. Kept as a lightweight CustomPainter
/// rather than shipping an SVG asset for a purely decorative shape this
/// simple.
class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.85);
    final w = size.width;
    final h = size.height;

    void tower(double xFrac, double topFrac) {
      final x = w * xFrac;
      canvas.drawRect(Rect.fromLTWH(x, h * topFrac, 6, h * (1 - topFrac)), paint);
    }

    tower(0.03, 0.5);
    tower(0.15, 0.3);
    tower(0.65, 0.4);
    tower(0.85, 0.25);

    final domePath = Path()
      ..moveTo(w * 0.34, h)
      ..lineTo(w * 0.34, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.66, h * 0.65)
      ..lineTo(w * 0.66, h)
      ..close();
    canvas.drawPath(domePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
