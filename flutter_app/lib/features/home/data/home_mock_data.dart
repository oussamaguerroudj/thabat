/// Static placeholder values for Home dashboard widgets whose real backend
/// doesn't exist yet. This is Phase 7's honest scope: the *screen* is real
/// and fully wired for navigation, but prayer times, Quran/Adhkar/goal
/// progress, and community activity all depend on backends that later
/// phases build (see each field's comment for which one). Nothing here
/// should be mistaken for a live data source — `HomeScreen` never claims
/// otherwise, and every value here is named `mock*` for that reason.
library;

/// Real source: Phase 13 (Prayer & Adhan) backend + device location.
class MockPrayerData {
  static const currentPrayerName = 'الفجر';
  static const currentPrayerTime = '04:35';
  static const countdown = '01:12:34';
  static const location = 'المدينة المنورة';
  static const otherTimes = [
    (label: 'العشاء', time: '8:42 م'),
    (label: 'المغرب', time: '7:12 م'),
    (label: 'العصر', time: '3:45 م'),
    (label: 'الظهر', time: '12:20 م'),
    (label: 'الشروق', time: '5:58 ص'),
  ];
}

/// Real source: Phase 15 (Tasbeeh), Phase 17 (Daily Journey), Phase 18
/// (Goals) backends respectively.
class MockStatsData {
  static const tasbeehCount = 33;
  static const dailyJourneyPercent = 72;
  static const dailyJourneyNote = 'أحسنت! استمر على الطاعة';
}

/// Real source: Phase 17 (Daily Journey) backend.
class MockDailyTrack {
  const MockDailyTrack({
    required this.icon,
    required this.label,
    required this.value,
    required this.completed,
  });

  final String icon;
  final String label;
  final String value;
  final bool completed;

  static const all = [
    MockDailyTrack(icon: '🕌', label: 'الصلاة', value: '5/5', completed: true),
    MockDailyTrack(icon: '📗', label: 'القرآن', value: '12/20', completed: true),
    MockDailyTrack(icon: '📿', label: 'أذكار', value: '3/3', completed: true),
    MockDailyTrack(icon: '☾', label: 'صيام', value: 'نعم', completed: false),
    MockDailyTrack(icon: '✒', label: 'ذكر اليوم', value: '45/100', completed: false),
  ];
}

/// Placeholder ayah shown on the dashboard. Per the project's data
/// integrity rule (religious text is never AI-generated or altered), this
/// exact string was carried over unchanged from the Phase 4 prototype —
/// it should be checked against a verified mushaf source by Phase 10
/// (Quran) before being treated as production content, not re-typed or
/// "improved" here.
class MockAyah {
  static const text = 'فَاسْتَبِقُوا الْخَيْرَاتِ ۚ أَيْنَ مَا تَكُونُوا يَأْتِ بِكُمُ اللَّهُ جَمِيعًا';
  static const reference = 'سورة البقرة، آية 148';
}

/// Real source: Phase 10 (Quran) / Phase 14 (Fasting) recommendation logic.
class MockSuggestion {
  const MockSuggestion({required this.icon, required this.title, required this.subtitle});

  final String icon;
  final String title;
  final String subtitle;

  static const all = [
    MockSuggestion(icon: '📗', title: 'سورة الكهف', subtitle: 'من سنن يوم الجمعة'),
    MockSuggestion(icon: '🗓️', title: 'صيام الإثنين والخميس', subtitle: 'سنة نبوية، لا تنسها'),
  ];
}

/// Real source: Phase 21 (Community) backend. Names/content here are
/// fictional placeholder examples, not real user data.
class MockCommunityPost {
  const MockCommunityPost({required this.author, required this.excerpt});

  final String author;
  final String excerpt;

  static const all = [
    MockCommunityPost(author: 'أبو محمد', excerpt: 'ما حكم إخراج زكاة الفطر نقدًا؟'),
    MockCommunityPost(author: 'أم عبدالله', excerpt: 'شاركت فائدة عن فضل قيام الليل في رمضان'),
  ];
}
