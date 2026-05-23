import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────
  static const Color dark        = Color(0xFF0A1A12); // page background
  static const Color darkCard    = Color(0xFF0F2218); // card surface
  static const Color darkPanel   = Color(0xFF142B1E); // elevated panel
  static const Color darkBorder  = Color(0xFF1F3D2A); // default border

  // ── Brand ────────────────────────────────────
  static const Color gold        = Color(0xFFC9A84C);
  static const Color goldLight   = Color(0xFFE8C86A);
  static const Color goldGlow    = Color(0xFFF5D98B);
  static const Color emerald     = Color(0xFF1A6B4A);
  static const Color emeraldMid  = Color(0xFF22874F);
  static const Color emeraldLight= Color(0xFF2EAD66);

  // ── Text ─────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EAD6);
  static const Color textSecondary = Color(0xFFA8B9A0);
  static const Color textMuted     = Color(0xFF5E7A65);
  static const Color cream         = Color(0xFFFDF6E3);

  // ── Lifelines ────────────────────────────────
  static const Color lifelineRed    = Color(0xFFE05252);
  static const Color lifelineBlue   = Color(0xFF4A90D9);
  static const Color lifelinePurple = Color(0xFF8B5CF6);

  // ── Coin ─────────────────────────────────────
  static const Color coin = Color(0xFFF5C842);

  // ── Difficulty ───────────────────────────────
  static const Color easy   = Color(0xFF4DD68A);
  static const Color medium = gold;
  static const Color hard   = Color(0xFFF42222);

  // ── Utility ──────────────────────────────────
  static const Color correct = Color(0xFF2EAD66);
  static const Color wrong   = Color(0xFFE05252);
  static const Color white   = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
}