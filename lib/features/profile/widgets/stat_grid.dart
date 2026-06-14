import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';


class ProfileStatGrid extends StatelessWidget {
  const ProfileStatGrid({
    super.key,
    required this.totalCorrect,
    required this.accuracy,
    required this.bestStreak,
    required this.stagesCompleted,
    required this.coins,
    required this.totalAttempted,
  });

  final int totalCorrect;
  final double accuracy;
  final int bestStreak;
  final int stagesCompleted;
  final int coins;
  final int totalAttempted;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _StatTile(
          icon: Icons.check_circle_rounded,
          label: 'Correct Answers',
          value: totalCorrect.toString(),
          color: AppColors.correct,
        ),
        _StatTile(
          icon: Icons.gps_fixed_rounded,
          label: 'Accuracy',
          value: '${accuracy.toStringAsFixed(1)}%',
          color: AppColors.emeraldLight,
        ),
        _StatTile(
          icon: Icons.local_fire_department_rounded,
          label: 'Best Streak',
          value: bestStreak.toString(),
          color: AppColors.gold,
        ),
        _StatTile(
          icon: Icons.layers_rounded,
          label: 'Stages Done',
          value: stagesCompleted.toString(),
          color: AppColors.lifelineBlue,
        ),
        _StatTile(
          icon: Icons.monetization_on_rounded,
          label: 'Total Coins',
          value: _formatCoins(coins),
          color: AppColors.coin,
        ),
        _StatTile(
          icon: Icons.quiz_rounded,
          label: 'Total Played',
          value: totalAttempted.toString(),
          color: AppColors.lifelinePurple,
        ),
      ],
    );
  }

  String _formatCoins(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}