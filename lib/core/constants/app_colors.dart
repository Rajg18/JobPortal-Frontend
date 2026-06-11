import 'package:flutter/material.dart';

class AppColors {
  // ── Background layers ────────────────────────────────────────────────────
  static const Color background  = Color(0xFFFFFFFF); // Pure white
  static const Color surface     = Color(0xFFF8FAFC); // Off-white surface
  static const Color cardBg      = Color(0xFFFFFFFF); // White cards
  static const Color divider     = Color(0xFFE2E8F0); // Soft border

  // ── Primary / Brand ──────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF0F172A); // Near-black navy
  static const Color accent       = Color(0xFF6366F1); // Indigo
  static const Color accentLight  = Color(0xFFEEF2FF); // Indigo tint bg
  static const Color accentDark   = Color(0xFF4F46E5); // Darker indigo

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A); // Near-black
  static const Color textSecondary = Color(0xFF64748B); // Slate grey
  static const Color textMuted     = Color(0xFF94A3B8); // Light grey

  // ── Status colors ────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF10B981); // Emerald green
  static const Color error    = Color(0xFFEF4444); // Red
  static const Color warning  = Color(0xFFF59E0B); // Amber
  static const Color info     = Color(0xFF3B82F6); // Blue

  // ── Input fields ────────────────────────────────────────────────────────
  static const Color inputBg     = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFCBD5E1);
  static const Color inputFocus  = Color(0xFF6366F1);

  // ── Company badge palette (cycles through for visual variety) ────────────
  static const List<Color> badgeColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEF4444), // Red
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal
    Color(0xFFE11D48), // Rose
    Color(0xFF0EA5E9), // Sky
  ];

  // ── Category chip colors ─────────────────────────────────────────────────
  static const Color chipBg       = Color(0xFFF1F5F9);
  static const Color chipSelected = Color(0xFF0F172A);

  static Color badgeFor(String name) {
    if (name.isEmpty) return badgeColors[0];
    return badgeColors[name.codeUnitAt(0) % badgeColors.length];
  }

  // ── Legacy aliases (used in admin/profile screens) ───────────────────────
  static const Color gold      = accent;
  static const Color goldLight = Color(0xFF818CF8); // indigo-400
  static const Color skyBlue   = info;
  static const Color inputFocusLegacy = inputFocus;
  static const Color cardBgDark = Color(0xFFF1F5F9); // light slate for tinted bg
}
