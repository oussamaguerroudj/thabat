import 'package:flutter/material.dart';

/// Color tokens — ported 1:1 from `design/prototype/thabat_prototype.html`'s
/// `:root` CSS custom properties. Keep this file and that `:root` block in
/// sync; if a hex value changes in one, it must change in the other.
abstract final class AppColors {
  static const cream = Color(0xFFF7F1E3);
  static const cream2 = Color(0xFFFBF6EA);
  static const greenDeep = Color(0xFF1C3B2E);
  static const green = Color(0xFF234B36);
  static const greenLight = Color(0xFF2F6248);
  static const gold = Color(0xFFB99552);
  static const goldLight = Color(0xFFD9C08E);
  static const beige = Color(0xFFEDE2C7);
  static const charcoal = Color(0xFF2B2924);
  static const muted = Color(0xFF8A8370);
  static const line = Color(0xFFE3D8BE);

  /// Page background outside the card surfaces (`body { background: #EDE7D8 }`
  /// in the prototype).
  static const pageBackground = Color(0xFFEDE7D8);
}
