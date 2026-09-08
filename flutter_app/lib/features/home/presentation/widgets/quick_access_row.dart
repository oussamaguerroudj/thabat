import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class QuickAccessItem {
  const QuickAccessItem({required this.icon, required this.label, required this.onTap});

  final String icon;
  final String label;
  final VoidCallback onTap;
}

/// The 6-icon quick access row — matches `.dash-quick-row`. Each item
/// navigates to a real route (mostly still [ComingSoonScreen] placeholders
/// until their own feature phase, except التحقق which the Verification
/// phase — 8 — will make real).
class QuickAccessRow extends StatelessWidget {
  const QuickAccessRow({super.key, required this.items});

  final List<QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Row(
        children: [for (final item in items) Expanded(child: _buildItem(item))],
      ),
    );
  }

  Widget _buildItem(QuickAccessItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(21),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
            ),
            alignment: Alignment.center,
            child: Text(item.icon, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 6),
          Text(item.label, style: AppTypography.cairo(fontSize: 9.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
