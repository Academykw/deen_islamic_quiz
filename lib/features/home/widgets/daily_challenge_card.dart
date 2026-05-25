import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/gold_button.dart';

class DailyChallengeCard extends StatefulWidget {
  const DailyChallengeCard({
    super.key,
    required this.onTap,
    this.isCompleted = false,
  });

  final VoidCallback onTap;
  final bool isCompleted;

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _timeLeft = _timeUntilMidnight();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _timeLeft = _timeUntilMidnight());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _timeUntilMidnight() {
    final now = DateTime.now();
    final midnight =
    DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isCompleted
              ? [AppColors.darkPanel, AppColors.darkCard]
              : [
            AppColors.emerald.withOpacity(0.25),
            AppColors.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCompleted
              ? AppColors.darkBorder
              : AppColors.emeraldLight.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? AppColors.darkBorder
                        : AppColors.emerald.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.local_fire_department_rounded,
                    color: widget.isCompleted
                        ? AppColors.textMuted
                        : AppColors.emeraldLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Challenge',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.isCompleted
                            ? 'Come back tomorrow'
                            : '10 questions · 2× coins',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown
                if (!widget.isCompleted)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Resets in',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        _format(_timeLeft),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            if (!widget.isCompleted) ...[
              const SizedBox(height: 16),

              // ── Reward chips ───────────────────
              Row(
                children: [
                  _RewardChip(
                    icon: Icons.monetization_on_rounded,
                    label: '+500 coins',
                    color: AppColors.coin,
                  ),
                  const SizedBox(width: 8),
                  _RewardChip(
                    icon: Icons.emoji_events_rounded,
                    label: 'Leaderboard XP',
                    color: AppColors.gold,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GoldButton(
                label: 'Start Challenge',
                onTap: widget.onTap,
                height: 44,
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}