import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema utama aplikasi Safea.
///
/// Menggunakan palet biru lembut + krem dengan tipografi
/// Google Fonts (Poppins untuk body, Lora untuk heading).
class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepCalmBlue,
      brightness: Brightness.light,
      primary: AppColors.deepCalmBlue,
      secondary: AppColors.accentGold,
      surface: AppColors.warmCream,
      onSurface: AppColors.textDark,
    );

    final textTheme = GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.lora(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.lora(
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineLarge: GoogleFonts.lora(
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.lora(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.lora(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.poppins(color: AppColors.textDark),
      bodyMedium: GoogleFonts.poppins(color: AppColors.textMuted),
      labelLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.warmCream,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepCalmBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.mutedCream, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.mutedCream, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepCalmBlue,
      brightness: Brightness.dark,
      primary: AppColors.darkBlueAccent,
      secondary: AppColors.accentGold,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textLight,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
        .copyWith(
          displayLarge: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
          displayMedium: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
          headlineLarge: GoogleFonts.lora(
            fontWeight: FontWeight.w700,
            color: AppColors.textLight,
          ),
          headlineMedium: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          headlineSmall: GoogleFonts.lora(
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          bodyLarge: GoogleFonts.poppins(color: AppColors.textLight),
          bodyMedium: GoogleFonts.poppins(
            color: AppColors.textLight.withValues(alpha: 0.7),
          ),
          labelLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textLight,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
