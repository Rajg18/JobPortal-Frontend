import 'package:flutter/material.dart';

class AppColors {
  // ── Base backgrounds ─────────────────────────────────────────────────────
  static const Color background  = Color(0xFF0D0F12); // near-black (matches screenshot)
  static const Color surface     = Color(0xFF13151A); // slightly lifted surface
  static const Color cardBg      = Color(0xFF1A1D23); // card background
  static const Color divider     = Color(0xFF252830); // subtle border

  // ── Brand / Primary — Emerald Green ──────────────────────────────────────
  static const Color primary      = Color(0xFF10B981); // emerald-500
  static const Color primaryDark  = Color(0xFF059669); // emerald-600
  static const Color primaryLight = Color(0xFF6EE7B7); // emerald-300
  static const Color accentBg     = Color(0x1A10B981); // emerald 10% alpha

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8EAED); // near-white
  static const Color textSecondary = Color(0xFF9AA1AF); // muted grey
  static const Color textMuted     = Color(0xFF4B5263); // very muted

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF10B981); // same as primary
  static const Color error    = Color(0xFFEF4444); // red-500
  static const Color warning  = Color(0xFFF59E0B); // amber-500
  static const Color info     = Color(0xFF38BDF8); // sky-400

  // ── Inputs ──────────────────────────────────────────────────────────────
  static const Color inputBg     = Color(0xFF1A1D23);
  static const Color inputBorder = Color(0xFF2E3240);
  static const Color inputFocus  = Color(0xFF10B981);

  // ── Company badge palette ─────────────────────────────────────────────────
  static const List<Color> badgeColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFFEF4444), // red
    Color(0xFF38BDF8), // sky
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
    Color(0xFFA855F7), // purple
  ];

  static Color badgeFor(String name) {
    if (name.isEmpty) return badgeColors[0];
    return badgeColors[name.codeUnitAt(0) % badgeColors.length];
  }

  // ── Legacy aliases ────────────────────────────────────────────────────────
  static const Color gold       = primary;
  static const Color goldLight  = primaryLight;
  static const Color skyBlue    = info;
  static const Color accent     = primary;
  static const Color accentLight = accentBg;
  static const Color accentDark  = primaryDark;
  static const Color chipBg     = Color(0xFF1E2028);
}
