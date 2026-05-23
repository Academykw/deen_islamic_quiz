import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constant/app_colors.dart';
import '../core/constant/app_text_styles.dart';


class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark,
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.gold,
        secondary: AppColors.emeraldLight,
        surface:   AppColors.darkCard,
        error:     AppColors.wrong,
        onPrimary: AppColors.dark,
        onSurface: AppColors.textPrimary,
      ),

      // ── AppBar ────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.labelLarge,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Text ──────────────────────────────────
      textTheme: const TextTheme(
        displayLarge:  AppTextStyles.amiriDisplay,
        titleLarge:    AppTextStyles.amiriTitle,
        titleMedium:   AppTextStyles.amiriHeading,
        bodyLarge:     AppTextStyles.bodyLarge,
        bodyMedium:    AppTextStyles.bodyMedium,
        bodySmall:     AppTextStyles.bodySmall,
        labelLarge:    AppTextStyles.labelLarge,
        labelMedium:   AppTextStyles.labelMedium,
        labelSmall:    AppTextStyles.labelSmall,
      ),

      // ── Cards ─────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton (gold) ─────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.dark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ── OutlinedButton (secondary) ────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── BottomNavBar ──────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.dark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Tajawal', fontSize: 11, fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Tajawal', fontSize: 11,
        ),
      ),

      // ── Divider ───────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 0,
      ),
    );
  }
}