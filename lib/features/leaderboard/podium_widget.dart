import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constant/app_colors.dart';
import '../../data/models/leaderboard_entry.dart';


class PodiumWidget extends StatelessWidget {
  const PodiumWidget({
    super.key,
    required this.topThree,
    required this.currentUid,
  });

  final List<LeaderboardEntry> topThree;
  final String currentUid;

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first  = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third  = topThree.length > 2 ? topThree[2] : null;

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── 2nd place ──────────────────────────
          if (second != null)
            Expanded(
              child: _PodiumColumn(
                entry: second,
                height: 140,
                medalColor: const Color(0xFFC0C0C0),
                medalEmoji: '🥈',
                isCurrentUser: second.uid == currentUid,
                delay: 200,
              ),
            ),

          // ── 1st place ──────────────────────────
          if (first != null)
            Expanded(
              child: _PodiumColumn(
                entry: first,
                height: 180,
                medalColor: AppColors.gold,
                medalEmoji: '🥇',
                isCurrentUser: first.uid == currentUid,
                delay: 0,
                isCrown: true,
              ),
            ),

          // ── 3rd place ──────────────────────────
          if (third != null)
            Expanded(
              child: _PodiumColumn(
                entry: third,
                height: 110,
                medalColor: const Color(0xFFCD7F32),
                medalEmoji: '🥉',
                isCurrentUser: third.uid == currentUid,
                delay: 400,
              ),
            ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.height,
    required this.medalColor,
    required this.medalEmoji,
    required this.isCurrentUser,
    required this.delay,
    this.isCrown = false,
  });

  final LeaderboardEntry entry;
  final double height;
  final Color medalColor;
  final String medalEmoji;
  final bool isCurrentUser;
  final int delay;
  final bool isCrown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ── Crown (1st only) ───────────────
        if (isCrown)
          const Text('👑',
              style: TextStyle(fontSize: 22))
              .animate(delay: Duration(milliseconds: delay + 600))
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.5, end: 0),

        const SizedBox(height: 4),

        // ── Avatar ─────────────────────────
        Container(
          width: isCrown ? 64 : 52,
          height: isCrown ? 64 : 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medalColor.withValues(alpha: 0.15),
            border: Border.all(
              color: isCurrentUser
                  ? AppColors.gold
                  : medalColor,
              width: isCurrentUser ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: medalColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              entry.avatarEmoji,
              style: TextStyle(
                fontSize: isCrown ? 30 : 24,
              ),
            ),
          ),
        )
            .animate(
            delay: Duration(milliseconds: delay))
            .scale(
          begin: const Offset(0.0, 0.0),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
            .fadeIn(duration: 300.ms),

        const SizedBox(height: 6),

        // ── Name ───────────────────────────
        Text(
          entry.displayName.split(' ').first,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: isCrown ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: isCurrentUser
                ? AppColors.gold
                : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        // ── Coins ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.coin,
              size: 11,
            ),
            const SizedBox(width: 2),
            Text(
              _formatCoins(entry.coins),
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.coin,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ── Podium block ───────────────────
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                medalColor.withValues(alpha: 0.3),
                medalColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              top: BorderSide(
                  color: medalColor.withValues(alpha: 0.5),
                  width: 1.5),
              left: BorderSide(
                  color: medalColor.withValues(alpha: 0.2)),
              right: BorderSide(
                  color: medalColor.withValues(alpha: 0.2)),
            ),
          ),
          child: Center(
            child: Text(
              medalEmoji,
              style: TextStyle(
                  fontSize: isCrown ? 28 : 22),
            ),
          ),
        )
            .animate(
            delay: Duration(milliseconds: delay + 200))
            .slideY(
          begin: 1.0,
          end: 0.0,
          duration: 500.ms,
          curve: Curves.easeOut,
        )
            .fadeIn(duration: 300.ms),
      ],
    );
  }

  String _formatCoins(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}