import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

/// The Phase 4 artwork (`verify_reference.png`) shows the "ابدأ التحقق"
/// button and "تحقق من نص" card, but — being a flat image — has no actual
/// text-input widget baked into it. This bottom sheet is Phase 8's real
/// addition: where the user actually types the content to check, opened
/// when either the hero CTA or the "تحقق من نص" quick card is tapped.
Future<void> showContentInputSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _ContentInputSheet(),
  );
}

class _ContentInputSheet extends StatefulWidget {
  const _ContentInputSheet();

  @override
  State<_ContentInputSheet> createState() => _ContentInputSheetState();
}

class _ContentInputSheetState extends State<_ContentInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تحقق من محتوى ديني',
              textAlign: TextAlign.center,
              style: AppTypography.cairo(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ألصق النص الذي تريد التحقق منه وسنبحث في المصادر الموثوقة.',
              textAlign: TextAlign.center,
              style: AppTypography.cairo(fontSize: 11.5, color: AppColors.muted),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(controller: _controller, label: 'النص المراد التحقق منه'),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'ابدأ التحقق',
              onPressed: () {
                final content = _controller.text.trim();
                if (content.length < 3) return;
                Navigator.of(context).pop();
                context.push(AppRoutes.verifyInProgress, extra: content);
              },
            ),
          ],
        ),
      ),
    );
  }
}
