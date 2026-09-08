import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/content_input_sheet.dart';

/// "التحقق" screen. Per ADR-010 (Phase 4) and its Flutter counterpart in
/// Phase 5's onboarding screen, `verify_reference.png` already contains
/// the full finished composition — header, greeting, hero card, and the
/// 2x2 quick-options grid — so it's used as a full-bleed background with
/// precisely-positioned transparent hit targets on top, rather than
/// redrawn as Flutter widgets.
///
/// Every coordinate below is copied as-is from `.vp-hit` elements in
/// `design/prototype/thabat_prototype.html` (already pixel-measured
/// against the image during Phase 4/6's prototype work) — not re-guessed
/// for Flutter.
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          Widget hit({
            required double top,
            required double height,
            double? left,
            double? right,
            double? width,
            required VoidCallback onTap,
            required String label,
          }) {
            return Positioned(
              top: h * top,
              height: h * height,
              left: left != null ? w * left : null,
              right: right != null ? w * right : null,
              width: width != null ? w * width : null,
              child: Semantics(
                button: true,
                label: label,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap, child: const SizedBox.expand()),
                ),
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/verify_reference.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              hit(
                top: 0.02, height: 0.05, left: 0.024, width: 0.11,
                label: 'التنبيهات',
                onTap: () => context.go(AppRoutes.notifications),
              ),
              hit(
                top: 0.02, height: 0.05, right: 0.024, width: 0.11,
                label: 'الإعدادات',
                onTap: () => context.go(AppRoutes.settings),
              ),
              hit(
                top: 0.503, height: 0.063, left: 0.013, right: 0.013,
                label: 'ابدأ التحقق',
                onTap: () => showContentInputSheet(context),
              ),
              hit(
                top: 0.645, height: 0.113, left: 0.018, right: 0.511,
                label: 'تحقق من نص',
                onTap: () => showContentInputSheet(context),
              ),
              hit(
                top: 0.645, height: 0.113, left: 0.555, right: 0.005,
                label: 'تحقق من صورة',
                onTap: () => _showImageNotYetAvailable(context),
              ),
              hit(
                top: 0.766, height: 0.10, left: 0.018, right: 0.511,
                label: 'المحفوظات',
                onTap: () => context.go(AppRoutes.saved),
              ),
              hit(
                top: 0.766, height: 0.10, left: 0.555, right: 0.005,
                label: 'المصادر',
                onTap: () => context.go(AppRoutes.trustedSources),
              ),
              _VerifyBottomNavOverlay(top: h * 0.876, height: h * 0.078, width: w),
            ],
          );
        },
      ),
    );
  }

  void _showImageNotYetAvailable(BuildContext context) {
    // Real, honest state: image-based verification (OCR) has no backend
    // yet (Phase 8 only built the text-content endpoint) — say so rather
    // than pretending to accept an image upload that goes nowhere.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('التحقق من الصور غير متاح حالياً — سيتم إضافته لاحقاً')),
    );
  }
}

/// The image's baked-in bottom nav row gets the same 5 real destinations
/// as [AppBottomNav] elsewhere, so tapping it actually navigates instead
/// of being decorative.
class _VerifyBottomNavOverlay extends StatelessWidget {
  const _VerifyBottomNavOverlay({required this.top, required this.height, required this.width});

  final double top;
  final double height;
  final double width;

  static const _targets = [
    AppRoutes.home,
    AppRoutes.verify,
    AppRoutes.saved,
    AppRoutes.trustedSources,
    AppRoutes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final itemWidth = width / _targets.length;
    return Positioned(
      top: top,
      height: height,
      left: 0,
      right: 0,
      child: Row(
        children: [
          for (final route in _targets)
            SizedBox(
              width: itemWidth,
              height: height,
              child: route == AppRoutes.verify
                  ? const SizedBox.shrink() // already on this screen
                  : InkWell(onTap: () => context.go(route), child: const SizedBox.expand()),
            ),
        ],
      ),
    );
  }
}
