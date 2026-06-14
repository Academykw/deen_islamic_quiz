import 'package:flutter/material.dart';

import '../../core/constant/app_colors.dart';
import '../../data/models/leaderboard_entry.dart';


class YourRankCard extends StatelessWidget {
  const YourRankCard({
    super.key,
    required this.rank,
    required this.entry,
  });

  final int rank;
  final LeaderboardEntry? entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.emerald.withValues(alpha: 0.2),
            AppColors.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emeraldLight.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald.withValues(alpha: 0.2),
              border: Border.all(
                  color: AppColors.emeraldLight, width: 1.5),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emeraldLight,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Ranking',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rank == 1
                      ? '🏆 You\'re #1!'
                      : 'Rank #$rank globally',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (entry != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${entry!.accuracy.toStringAsFixed(1)}% accuracy',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Coins
          if (entry != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppColors.coin, size: 20),
                const SizedBox(height: 2),
                Text(
                  _formatCoins(entry!.coins),
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coin,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatCoins(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}
