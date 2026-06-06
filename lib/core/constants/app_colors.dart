import 'package:flutter/material.dart';

class AppColors {
  // ── Background layers ────────────────────────────────────────────────────
  static const Color background   = Color(0xFF0A1628); // Deep navy
  static const Color surface      = Color(0xFF152238); // Slightly lighter navy
  static const Color cardBg       = Color(0xFF1E2E45); // Card background
  static const Color divider      = Color(0xFF2C3E50); // Subtle borders

  // ── Brand accents ────────────────────────────────────────────────────────
  static const Color gold         = Color(0xFFF5A623); // Warm gold — CTAs
  static const Color goldLight    = Color(0xFFFFC75F); // Hover/highlight gold
  static const Color skyBlue      = Color(0xFF4A9EE8); // Info / secondary
  static const Color skyBlueLight = Color(0xFF6FB8FF); // Light blue

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BA4BE);
  static const Color textMuted     = Color(0xFF4A6480);

  // ── Status colors ────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF27AE60); // ACCEPTED
  static const Color error    = Color(0xFFE74C3C); // REJECTED
  static const Color warning  = Color(0xFFF39C12); // PENDING
  static const Color info     = Color(0xFF3498DB);

  // ── Input fields ────────────────────────────────────────────────────────
  static const Color inputBg     = Color(0xFF0F1E33);
  static const Color inputBorder = Color(0xFF2A3F58);
  static const Color inputFocus  = Color(0xFFF5A623);
}
