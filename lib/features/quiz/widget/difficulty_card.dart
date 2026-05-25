import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../data/models/quiz_model.dart';


class DifficultyCard extends StatelessWidget {
  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.stages,
    required this.onTap,
  });

  final Difficulty difficulty;
  final List<Stage> stages;
  final VoidCallback onTap;

  // ── Config per difficulty ──────────────────────
  String get _title {
    switch (difficulty) {
      case Difficulty.easy:   return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard:   return 'Hard';
    }
  }

  String get _arabicTitle {
    switch (difficulty) {
      case Difficulty.easy:   return 'سهل';
      case Difficulty.medium: return 'متوسط';
      case Difficulty.hard:   return 'صعب';
    }
  }

  String get _description {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Pillars of Islam, basic\nfacts & fundamentals';
      case Difficulty.medium:
        return 'Quran, Hadith, Islamic\nhistory & jurisprudence';
      case Difficulty.hard:
        return 'Advanced fiqh, scholars,\nbattles & deep knowledge';
    }
  }

  String get _coinRate {
    switch (difficulty) {
      case Difficulty.easy:   return '10 coins/question';
      case Difficulty.medium: return '15 coins/question';
      case Difficulty.hard:   return '20 coins/question';
    }
  }

  Color get _color {
    switch (difficulty) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }

  List<Color> get _gradientColors {
    switch (difficulty) {
      case Difficulty.easy:
        return [
          const Color(0xFF1A3D2A),
          AppColors.darkCard,
        ];
      case Difficulty.medium:
        return [
          const Color(0xFF3D2E0A),
          AppColors.darkCard,
        ];
      case Difficulty.hard:
        return [
          const Color(0xFF3D1A1A),
          AppColors.darkCard,
        ];
    }
  }

  IconData get _icon {
    switch (difficulty) {
      case Difficulty.easy:   return Icons.eco_rounded;
      case Difficulty.medium: return Icons.local_fire_department_rounded;
      case Difficulty.hard:   return Icons.whatshot_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = stages.where((s) => s.isCompleted).length;
    final total = stages.length;
    final progress = total == 0 ? 0.0 : completed / total;
    final totalStars = stages.fold<int>(0, (sum, s) => sum + s.starsEarned);
    final maxStars = total * 3;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _color.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: icon + title + arabic ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon orb
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _color.withOpacity(0.3), width: 1),
                    ),
                    child: Icon(_icon, color: _color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _title,
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _arabicTitle,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        Text(
                          _description,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _color.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Progress bar ─────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$completed of $total stages',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                            AppColors.darkBorder,
                            valueColor:
                            AlwaysStoppedAnimation(_color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Bottom: coin rate + stars ─────────
              Row(
                children: [
                  // Coin rate
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.coin.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.coin.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            color: AppColors.coin, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          _coinRate,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.coin,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Stars earned
                  Row(
                    children: List.generate(maxStars > 9 ? 9 : maxStars, (i) {
                      return Icon(
                        i < totalStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < totalStars
                            ? AppColors.gold
                            : AppColors.darkBorder,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}