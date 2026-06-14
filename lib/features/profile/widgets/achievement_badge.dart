import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';


class AchievementData {
  const AchievementData({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool isUnlocked;
}

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
  });

  final AchievementData achievement;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: achievement.isUnlocked ? 1.0 : 0.35,
        child: Container(
          width: 72,
          padding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? AppColors.gold.withOpacity(0.08)
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: achievement.isUnlocked
                  ? AppColors.gold.withOpacity(0.3)
                  : AppColors.darkBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.isUnlocked
                    ? achievement.emoji
                    : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.title,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? AppColors.gold
                      : AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: achievement.isUnlocked
                ? AppColors.gold.withOpacity(0.3)
                : AppColors.darkBorder,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.isUnlocked
                  ? achievement.emoji
                  : '🔒',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: achievement.isUnlocked
                    ? AppColors.gold
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? AppColors.emerald.withOpacity(0.15)
                    : AppColors.darkBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                achievement.isUnlocked
                    ? '✅ Unlocked'
                    : '🔒 Locked',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? AppColors.emeraldLight
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Achievement definitions ────────────────────
List<AchievementData> buildAchievements({
  required int stagesCompleted,
  required int totalCorrect,
  required int bestStreak,
  required int coins,
}) {
  return [
    AchievementData(
      id: 'first_stage',
      emoji: '🎯',
      title: 'First Step',
      description: 'Complete your first stage',
      isUnlocked: stagesCompleted >= 1,
    ),
    AchievementData(
      id: 'streak_3',
      emoji: '⚡',
      title: 'Hot Start',
      description: 'Get a 3× answer streak',
      isUnlocked: bestStreak >= 3,
    ),
    AchievementData(
      id: 'streak_5',
      emoji: '🔥',
      title: 'On Fire',
      description: 'Get a 5× answer streak',
      isUnlocked: bestStreak >= 5,
    ),
    AchievementData(
      id: 'streak_10',
      emoji: '💥',
      title: 'Legendary',
      description: 'Get a 10× answer streak',
      isUnlocked: bestStreak >= 10,
    ),
    AchievementData(
      id: 'correct_50',
      emoji: '📚',
      title: 'Scholar',
      description: 'Answer 50 questions correctly',
      isUnlocked: totalCorrect >= 50,
    ),
    AchievementData(
      id: 'correct_100',
      emoji: '🎓',
      title: 'Hafidh',
      description: 'Answer 100 questions correctly',
      isUnlocked: totalCorrect >= 100,
    ),
    AchievementData(
      id: 'stages_5',
      emoji: '⭐',
      title: 'Stage Star',
      description: 'Complete 5 stages',
      isUnlocked: stagesCompleted >= 5,
    ),
    AchievementData(
      id: 'stages_15',
      emoji: '🏆',
      title: 'Champion',
      description: 'Complete all 15 stages',
      isUnlocked: stagesCompleted >= 15,
    ),
    AchievementData(
      id: 'coins_1000',
      emoji: '💰',
      title: 'Coin Collector',
      description: 'Earn 1,000 coins total',
      isUnlocked: coins >= 1000,
    ),
    AchievementData(
      id: 'coins_10000',
      emoji: '💎',
      title: 'Diamond',
      description: 'Earn 10,000 coins total',
      isUnlocked: coins >= 10000,
    ),
    AchievementData(
      id: 'quran_master',
      emoji: '📖',
      title: 'Quran Master',
      description: 'Complete all Hard stages',
      isUnlocked: stagesCompleted >= 15,
    ),
    AchievementData(
      id: 'daily_7',
      emoji: '🌙',
      title: 'Consistent',
      description: 'Complete 7 daily challenges',
      isUnlocked: false, // Wired in Step 7
    ),
  ];
}