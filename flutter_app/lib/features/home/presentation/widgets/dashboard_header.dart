import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Top bar: menu, Hijri/Gregorian date, notifications + avatar — matches
/// `.dash-header` in the prototype. The date shown is the device's actual
/// current date formatted simply; a real Hijri conversion is Phase 13's
/// job (it needs the same calendar logic as prayer times), so this uses
/// the Gregorian date only for now rather than fabricating a Hijri one.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, this.onMenuTap, this.onNotificationsTap});

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(icon: Icons.menu, onTap: onMenuTap),
          Text(dateText, style: AppTypography.cairo(fontSize: 11, color: AppColors.muted)),
          Row(
            children: [
              _CircleIconButton(icon: Icons.notifications_none, onTap: onNotificationsTap),
              const SizedBox(width: AppSpacing.sm),
              const CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.greenDeep,
                child: Text('🌙', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(BorderSide(color: AppColors.line)),
        ),
        child: Icon(icon, size: 18, color: AppColors.greenDeep),
      ),
    );
  }
}

/// "السلام عليكم / مرحبًا بك في ثبات" greeting block — matches
/// `.dash-greeting`. Takes the user's display name when available (from
/// the real `/auth/me` call Phase 6 already wires up) rather than always
/// showing the generic prototype copy.
class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key, this.displayName});

  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final name = displayName;
    final greeting = (name == null || name.isEmpty) ? 'مرحبًا بك في ثبات 🌿' : 'مرحبًا $name 🌿';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('السلام عليكم', style: AppTypography.cairo(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(greeting, style: AppTypography.cairo(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('🤍', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'نسأل الله أن يبارك يومك ويثبتك على الطاعة',
                  style: AppTypography.cairo(fontSize: 11.5, color: const Color(0xFF5C7C68)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
