/// Radius tokens — ported from `:root { --radius-lg/md/sm }` in the prototype.
abstract final class AppRadii {
  static const double lg = 26;
  static const double md = 18;
  static const double sm = 12;

  /// The pill shape used by primary buttons and nav-style chips throughout
  /// the prototype (`border-radius: 999px`).
  static const double pill = 999;
}

/// Spacing scale. The prototype doesn't declare an explicit spacing scale —
/// its screens use ad-hoc px values — so this is Phase 5's own addition:
/// a small consistent scale for Flutter layout, chosen to cover the most
/// common paddings/margins actually seen across the prototype's screens
/// (4/20px content margins, 8-18px inter-element gaps).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}
