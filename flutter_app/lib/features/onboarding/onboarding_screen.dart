import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// Onboarding screen. Per ADR-010 (Phase 4), the source image
/// (`assets/images/onboarding_hero.png`) already contains the full
/// composition — lanterns, logo, headline, mosque illustration, the
/// "ابدأ الآن" CTA, trust icons, and footer — rendered as one finished
/// artwork, so it's used as a full-bleed background rather than redrawn.
/// Only a transparent, precisely-positioned button sits on top so the CTA
/// baked into the artwork stays tappable.
///
/// The overlay's position (16% / 16% / 74.3% / 6.8%) is not eyeballed —
/// it's the same percentage box measured from the image's actual pixel
/// data (green-pill color detection) during Phase 4, ported as-is from
/// `.ob-cta-overlay` in `design/prototype/thabat_prototype.html` so the
/// hit target lines up with the same artwork in both places.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/onboarding_hero.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned(
                left: constraints.maxWidth * 0.16,
                right: constraints.maxWidth * 0.16,
                top: constraints.maxHeight * 0.743,
                height: constraints.maxHeight * 0.068,
                child: _CtaOverlayButton(
                  onTap: () => context.go(AppRoutes.login),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CtaOverlayButton extends StatelessWidget {
  const _CtaOverlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ابدأ الآن',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
