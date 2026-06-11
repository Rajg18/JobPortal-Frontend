import 'package:flutter/material.dart';

class AppColors {
  // ── Base backgrounds ─────────────────────────────────────────────────────
  static const Color background  = Color(0xFF09090B); // zinc-950 near-black
  static const Color surface     = Color(0xFF141416); // slightly lifted surface
  static const Color cardBg      = Color(0xFF1C1C1F); // zinc-900 card
  static const Color divider     = Color(0xFF2E2E33); // zinc-800 border

  // ── Brand / Primary ──────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF6366F1); // indigo-500
  static const Color primaryDark  = Color(0xFF4F46E5); // indigo-600
  static const Color primaryLight = Color(0xFFA5B4FC); // indigo-300
  static const Color accentBg     = Color(0x1A6366F1); // indigo 10% alpha

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF4F4F5); // zinc-100
  static const Color textSecondary = Color(0xFFA1A1AA); // zinc-400
  static const Color textMuted     = Color(0xFF52525B); // zinc-600

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF22C55E); // green-500
  static const Color error    = Color(0xFFEF4444); // red-500
  static const Color warning  = Color(0xFFF59E0B); // amber-500
  static const Color info     = Color(0xFF38BDF8); // sky-400

  // ── Inputs ──────────────────────────────────────────────────────────────
  static const Color inputBg     = Color(0xFF1C1C1F);
  static const Color inputBorder = Color(0xFF3F3F46);
  static const Color inputFocus  = Color(0xFF6366F1);

  // ── Company badge palette ─────────────────────────────────────────────────
  static const List<Color> badgeColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFF59E0B), // amber
    Color(0xFF22C55E), // green
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

  // ── Legacy aliases (used across screens — map to new equivalents) ────────
  static const Color gold      = primary;
  static const Color goldLight = primaryLight;
  static const Color skyBlue   = info;
  static const Color accent    = primary;
  static const Color accentLight = accentBg;
  static const Color accentDark  = primaryDark;
  static const Color chipBg    = Color(0xFF27272A);
}
