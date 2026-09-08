import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The 5-tab bottom bar from `.nav2` in the prototype
/// (الرئيسية/التحقق/المحفوظات/المصادر/الإعدادات), used identically on
/// every screen that shows it — matching the prototype, where the same
/// nav2 markup is repeated on both the Home and Verification screens
/// rather than being screen-specific chrome.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _items = [
    (icon: '🏠', label: 'الرئيسية', route: AppRoutes.home),
    (icon: '🔎', label: 'التحقق', route: AppRoutes.verify),
    (icon: '🕐', label: 'المحفوظات', route: AppRoutes.saved),
    (icon: '📚', label: 'المصادر', route: AppRoutes.trustedSources),
    (icon: '⚙', label: 'الإعدادات', route: AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 18, left: 6, right: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++) _buildItem(context, i),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final isActive = index == currentIndex;
    final color = isActive ? AppColors.greenDeep : AppColors.muted;

    return InkWell(
      onTap: isActive ? null : () => context.go(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: AppTypography.cairo(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
