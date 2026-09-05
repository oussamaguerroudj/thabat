import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Placeholder for any screen not yet implemented in its own feature phase.
/// This exists so the full navigation graph is real and clickable from
/// Phase 5 onward — every route in [AppRoutes] resolves to *something*,
/// never a dead/missing-route crash — without pretending the feature
/// itself is built. Each feature phase replaces its call site in
/// `app_router.dart` with a real screen; this widget is never itself
/// "finished."
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 40, color: AppColors.muted),
              const SizedBox(height: 16),
              Text(
                'قيد التطوير — $title',
                textAlign: TextAlign.center,
                style: AppTypography.cairo(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
