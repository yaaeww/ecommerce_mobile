import 'package:flutter/material.dart';

/// Clean agricultural-modern palette
class AppColors {
  // Primary: Emerald green (trust, growth)
  static const Color emerald = Color(0xFF059669);
  static const Color emeraldDark = Color(0xFF065F46);
  // Accent: Mango amber (warmth, energy)
  static const Color mango = Color(0xFFF59E0B);
  static const Color mangoLight = Color(0xFFFCD34D);

  // Neutrals
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Legacy (kept for transition)
  static const Color darkBlue = Color(0xFF0a1628);
  static const Color mediumBlue = Color(0xFF1a3a5f);
  static const Color lightBlue = Color(0xFF2a4a7f);
  static const Color gold = mango;
  static const Color goldLight = mangoLight;
  static const Color goldDark = Color(0xFFD97706);
  static const Color textLight = textDark;
}
