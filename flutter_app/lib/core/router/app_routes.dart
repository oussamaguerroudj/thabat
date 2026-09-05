/// Route paths for every screen identified in the Phase 4 prototype
/// (`design/prototype/thabat_prototype.html`, 36 `data-name` screens).
/// Phase 5 wires all of them into the router as placeholders so navigation
/// exists end-to-end; each is replaced with a real screen in its own
/// feature phase (see the phase-to-screen mapping in code comments below).
abstract final class AppRoutes {
  // Phase 5 — implemented for real in this phase.
  static const splash = '/';
  static const onboarding = '/onboarding';

  // Phase 6 — Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verifyCode = '/auth/verify-code';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const accountCreated = '/auth/account-created';

  // Phase 7 — Home
  static const home = '/home';

  // Phase 8 — Verification
  static const verify = '/verify';
  static const verifyResult = '/verify/result';
  static const verifyInProgress = '/verify/in-progress';
  static const verifyMethodology = '/verify/methodology';

  // Phase 9 — Ask Thabat
  static const askThabat = '/ask-thabat';

  // Phase 10 — Quran
  static const quran = '/quran';
  static const quranReader = '/quran/reader';

  // Phase 11 — Adhkar
  static const adhkar = '/adhkar';
  static const adhkarDetail = '/adhkar/detail';

  // Phase 12 — Dua
  static const dua = '/dua';
  static const duaDetail = '/dua/detail';

  // Phase 13 — Prayer
  static const prayer = '/prayer';
  static const qibla = '/qibla';

  // Phase 14 — Fasting
  static const fasting = '/fasting';

  // Phase 15 — Tasbeeh
  static const tasbeeh = '/tasbeeh';

  // Phase 17 — Daily journey
  static const dailyJourney = '/journey';

  // Phase 18 — Goals
  static const goals = '/goals';

  // Phase 19 — Saved content
  static const saved = '/saved';

  // Phase 20 — Trusted sources
  static const trustedSources = '/trusted-sources';

  // Phase 21 — Community
  static const community = '/community';

  // Phase 22 — Notifications
  static const notifications = '/notifications';

  // Phase 23 — Profile & Settings
  static const profile = '/profile';
  static const settings = '/settings';
  static const languageSelect = '/settings/language';
  static const help = '/settings/help';
  static const about = '/settings/about';

  // Cross-cutting / system
  static const emptyStates = '/dev/empty-states';
  static const systemStates = '/dev/system-states';
}
