import 'package:flutter/material.dart';

import '../../core/constant/app_colors.dart';
import '../../data/models/leaderboard_entry.dart';


class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.entry,
    required this.isCurrentUser,
  });

  final LeaderboardEntry entry;
  final bool isCurrentUser;

  Color get _rankColor {
    switch (entry.rank) {
      case 1: return AppColors.gold;
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.gold.withValues(alpha: 0.08)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.darkBorder,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // ── Rank ─────────────────────────────
          SizedBox(
            width: 36,
            child: entry.rank <= 3
                ? Text(
              entry.rank == 1
                  ? '🥇'
                  : entry.rank == 2
                  ? '🥈'
                  : '🥉',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            )
                : Text(
              '#${entry.rank}',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 10),

          // ── Avatar ────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkPanel,
              border: Border.all(
                color: isCurrentUser
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : AppColors.darkBorder,
              ),
            ),
            child: Center(
              child: Text(
                entry.avatarEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Name + country ────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isCurrentUser
                            ? '${entry.displayName} (You)'
                            : entry.displayName,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          fontWeight: isCurrentUser
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrentUser
                              ? AppColors.gold
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.country.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        entry.country,
                        style: const TextStyle(
                            fontSize: 14),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.accuracy.toStringAsFixed(1)}% accuracy · ${entry.bestStreak} best streak',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Coins ─────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.coin,
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _formatCoins(entry.coins),
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
