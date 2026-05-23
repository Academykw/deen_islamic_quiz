import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Amiri (serif — headings & Arabic) ────────
  static const TextStyle amiriDisplay = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle amiriTitle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle amiriHeading = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle amiriArabic = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.goldLight,
    height: 1.6,
  );

  // ── Tajawal (sans — body & UI) ────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 2.0,
  );

  static const TextStyle coinText = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.coin,
  );

  static const TextStyle statNumber = TextStyle(
    fontFamily: 'Tajawal',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.gold,
  );
}