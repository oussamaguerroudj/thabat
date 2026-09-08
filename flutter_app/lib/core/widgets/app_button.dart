import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The pill-shaped primary CTA button used throughout the prototype
/// (`.btn-primary` — e.g. "ابدأ الآن", "ابدأ التحقق"). Feature screens use
/// this instead of a raw `ElevatedButton` so the shape/weight stays
/// consistent without every screen repeating the same style block.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.cream,
              ),
            )
          : Text(label, style: AppTypography.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            )),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
