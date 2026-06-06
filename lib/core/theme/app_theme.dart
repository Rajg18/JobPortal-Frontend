import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.gold,
        secondary:  AppColors.skyBlue,
        surface:    AppColors.surface,
        error:      AppColors.error,
        onPrimary:  AppColors.background,
        onSurface:  AppColors.textPrimary,
      ),

      // ── Typography (Poppins throughout) ───────────────────────────────────
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.poppins(
          fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.background),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  AppColors.surface,
        elevation:        0,
        centerTitle:      false,
        titleTextStyle:   GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ── Cards ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color:        AppColors.cardBg,
        elevation:    0,
        shape:        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ── Input decoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:            true,
        fillColor:         AppColors.inputBg,
        contentPadding:    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle:         GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
        labelStyle:        GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor:   AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // ── Elevated buttons ──────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.gold,
          foregroundColor:  AppColors.background,
          minimumSize:      const Size(double.infinity, 52),
          shape:            RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          textStyle:        GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),

      // ── Text buttons ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Bottom nav ────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.surface,
        selectedItemColor:    AppColors.gold,
        unselectedItemColor:  AppColors.textMuted,
        type:                 BottomNavigationBarType.fixed,
        elevation:            0,
      ),

      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.cardBg,
        selectedColor:    AppColors.gold.withValues(alpha: 0.2),
        labelStyle:       GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        side:             const BorderSide(color: AppColors.divider),
        shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Floating action button ────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, thickness: 1, space: 1),

      // ── Snackbar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:    AppColors.cardBg,
        contentTextStyle:   GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
        shape:              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior:           SnackBarBehavior.floating,
      ),
    );
  }
}
