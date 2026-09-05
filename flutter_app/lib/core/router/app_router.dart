import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_session_controller.dart';
import '../providers/core_providers.dart';
import '../widgets/coming_soon_screen.dart';
import 'app_routes.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Routes that don't require a session. Everything else is treated as
/// protected: an unauthenticated user hitting a protected route is
/// redirected to [AppRoutes.login] (see [_authGuard]).
const _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyCode,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
  AppRoutes.accountCreated,
  AppRoutes.languageSelect,
  AppRoutes.about,
  AppRoutes.help,
  AppRoutes.emptyStates,
  AppRoutes.systemStates,
};

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _authGuard(ref, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),

      // Everything below is a placeholder until its feature phase builds
      // the real screen — see AppRoutes' phase-numbered comments.
      for (final entry in _placeholderTitles.entries)
        GoRoute(
          path: entry.key,
          builder: (_, __) => ComingSoonScreen(title: entry.value),
        ),
    ],
  );
});

/// `null` return means "no redirect" (go_router's convention) — i.e. stay
/// on the requested route.
String? _authGuard(Ref ref, String location) {
  final status = ref.read(authSessionProvider);

  // Session state hasn't finished loading from secure storage yet — stay
  // put (typically the splash screen) rather than guessing.
  if (status == AuthSessionStatus.unknown) return null;

  final isPublic = _publicRoutes.contains(location);
  final isAuthenticated = status == AuthSessionStatus.authenticated;

  if (!isAuthenticated && !isPublic) return AppRoutes.login;
  if (isAuthenticated && location == AppRoutes.login) return AppRoutes.home;
  return null;
}

/// go_router wants a plain [Listenable] to know when to re-run [redirect];
/// Riverpod state doesn't implement that directly, so this bridges the two
/// by listening to [authSessionProvider] and calling [notifyListeners]
/// whenever it changes.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    _subscription = ref.listen<AuthSessionStatus>(
      authSessionProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<AuthSessionStatus> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Route path -> Arabic screen title, sourced directly from the Phase 4
/// prototype's `data-name` attributes, for every screen not yet built.
const _placeholderTitles = <String, String>{
  AppRoutes.login: 'تسجيل الدخول',
  AppRoutes.register: 'إنشاء حساب',
  AppRoutes.verifyCode: 'رمز التحقق',
  AppRoutes.forgotPassword: 'نسيت كلمة المرور',
  AppRoutes.resetPassword: 'إعادة تعيين كلمة المرور',
  AppRoutes.accountCreated: 'تم إنشاء الحساب',
  AppRoutes.home: 'الرئيسية',
  AppRoutes.verify: 'التحقق',
  AppRoutes.verifyResult: 'نتيجة التحقق',
  AppRoutes.verifyInProgress: 'جارٍ التحقق',
  AppRoutes.verifyMethodology: 'منهجية التحقق',
  AppRoutes.askThabat: 'اسأل ثبات',
  AppRoutes.quran: 'القرآن الكريم',
  AppRoutes.quranReader: 'قارئ القرآن',
  AppRoutes.adhkar: 'الأذكار',
  AppRoutes.adhkarDetail: 'تفاصيل الذكر',
  AppRoutes.dua: 'الأدعية',
  AppRoutes.duaDetail: 'تفاصيل الدعاء',
  AppRoutes.prayer: 'الصلاة',
  AppRoutes.qibla: 'القبلة',
  AppRoutes.fasting: 'الصيام',
  AppRoutes.tasbeeh: 'السبحة',
  AppRoutes.dailyJourney: 'مساري اليومي',
  AppRoutes.goals: 'أهدافي',
  AppRoutes.saved: 'المحفوظات',
  AppRoutes.trustedSources: 'المصادر الموثوقة',
  AppRoutes.community: 'المجتمع',
  AppRoutes.notifications: 'التنبيهات',
  AppRoutes.profile: 'الملف الشخصي',
  AppRoutes.settings: 'الإعدادات',
  AppRoutes.languageSelect: 'اختيار اللغة',
  AppRoutes.help: 'المساعدة والدعم',
  AppRoutes.about: 'عن ثبات',
  AppRoutes.emptyStates: 'حالات فارغة',
  AppRoutes.systemStates: 'حالات النظام',
};
