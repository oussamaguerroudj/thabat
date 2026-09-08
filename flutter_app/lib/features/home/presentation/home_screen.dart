import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/application/auth_repository_provider.dart';
import '../../auth/data/auth_models.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/ayah_banner.dart';
import 'widgets/daily_tracks_row.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/prayer_card.dart';
import 'widgets/quick_access_row.dart';
import 'widgets/stats_row.dart';
import 'widgets/suggestions_section.dart';

/// The real Home dashboard from Phase 4's design (image 1 — the "عباد"-
/// style dashboard reference, ported into THABAT's own branding per that
/// phase's decisions). Replaces Phase 6's `HomePlaceholderScreen` as the
/// route builder for [AppRoutes.home].
///
/// Sections whose real backend doesn't exist yet render [MockPrayerData]
/// etc. from `features/home/data/home_mock_data.dart` — every one of
/// those is named accordingly and documented with which phase replaces
/// it; nothing here pretends to be live data it isn't.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Result<AuthUser>? _meResult;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final result = await ref.read(authRepositoryProvider).me();
    if (mounted) setState(() => _meResult = result);
  }

  @override
  Widget build(BuildContext context) {
    // The greeting degrades gracefully to the generic prototype copy if
    // `/auth/me` hasn't resolved yet or failed — this screen doesn't block
    // on it the way the old placeholder's whole body did, since the rest
    // of the dashboard doesn't depend on it.
    final displayName = _meResult?.when(ok: (user) => user.displayName, err: (_) => null);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DashboardHeader(onNotificationsTap: () => context.go(AppRoutes.notifications)),
            DashboardGreeting(displayName: displayName),
            AiAssistantCard(onTap: () => context.go(AppRoutes.askThabat)),
            VerifyStrip(onTap: () => context.go(AppRoutes.verify)),
            const PrayerCard(),
            QuickAccessRow(items: [
              QuickAccessItem(icon: '📿', label: 'الأذكار', onTap: () => context.go(AppRoutes.adhkar)),
              QuickAccessItem(icon: '📖', label: 'القرآن', onTap: () => context.go(AppRoutes.quran)),
              QuickAccessItem(icon: '🤲', label: 'الأدعية', onTap: () => context.go(AppRoutes.dua)),
              QuickAccessItem(icon: '☾', label: 'الصيام', onTap: () => context.go(AppRoutes.fasting)),
              QuickAccessItem(icon: '🔎', label: 'التحقق', onTap: () => context.go(AppRoutes.verify)),
              QuickAccessItem(icon: '▦', label: 'المزيد', onTap: () => context.go(AppRoutes.settings)),
            ]),
            StatsRow(onGoalsTap: () => context.go(AppRoutes.goals)),
            DashSectionHead(
              title: 'مسارك اليومي',
              trailing: 'عرض الكل 📅',
              onTrailingTap: () => context.go(AppRoutes.dailyJourney),
            ),
            const DailyTracksRow(),
            const AyahBanner(),
            DashSectionHead(title: 'مقترحات لك', trailing: 'عرض الكل'),
            const SuggestionsSection(),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
