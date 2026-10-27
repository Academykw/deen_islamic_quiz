import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────
  static const Color dark = Color(0xFF07150F);
  static const Color darkCard = Color(0xFF0D2118);
  static const Color darkPanel = Color(0xFF142D21);
  static const Color darkElevated = Color(0xFF193829);
  static const Color darkBorder = Color(0xFF234535);

  // ── Brand ────────────────────────────────────
  static const Color gold = Color(0xFFD6B75C);
  static const Color goldLight = Color(0xFFF0D887);
  static const Color goldGlow = Color(0xFFFFE7A0);
  static const Color emerald = Color(0xFF126044);
  static const Color emeraldMid = Color(0xFF1B8259);
  static const Color emeraldLight = Color(0xFF45C985);

  // ── Text ─────────────────────────────────────
  static const Color textPrimary = Color(0xFFF8F2DF);
  static const Color textSecondary = Color(0xFFB8C9BE);
  static const Color textMuted = Color(0xFF799487);
  static const Color cream = Color(0xFFFFF8E7);

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6549), Color(0xFF0E392A)],
  );

  static const LinearGradient pageGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF102C20), dark],
    stops: [0, 0.42],
  );

  // ── Lifelines ────────────────────────────────
  static const Color lifelineRed = Color(0xFFE05252);
  static const Color lifelineBlue = Color(0xFF4A90D9);
  static const Color lifelinePurple = Color(0xFF8B5CF6);

  // ── Coin ─────────────────────────────────────
  static const Color coin = Color(0xFFF5C842);

  // ── Difficulty ───────────────────────────────
  static const Color easy = Color(0xFF4DD68A);
  static const Color medium = gold;
  static const Color hard = Color(0xFFF42222);

  // ── Utility ──────────────────────────────────
  static const Color correct = Color(0xFF2EAD66);
  static const Color wrong = Color(0xFFE05252);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
}
