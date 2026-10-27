import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/gold_button.dart';
import '../../../state/daily_challenge_provider.dart';

class DailyChallengeCard extends ConsumerStatefulWidget {
  const DailyChallengeCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  ConsumerState<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends ConsumerState<DailyChallengeCard> {
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
    final now = DateTime.now().toUtc();
    final midnight = DateTime.utc(now.year, now.month, now.day + 1);
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
    final state = ref.watch(dailyChallengeProvider);

    if (state.isLoading) {
      return _LoadingCard();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isCompleted
              ? [AppColors.darkPanel, AppColors.darkCard]
              : [AppColors.emerald.withValues(alpha: 0.25), AppColors.darkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.isCompleted
              ? AppColors.darkBorder
              : AppColors.emeraldLight.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: state.isCompleted
                        ? AppColors.darkBorder
                        : AppColors.emerald.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    state.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.local_fire_department_rounded,
                    color: state.isCompleted
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
                        state.isCompleted
                            ? 'Completed today • Come back tomorrow'
                            : '10 questions • 2× Acoin reward',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Countdown timer
                if (!state.isCompleted)
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

            // ── Streak + stats row ───────────────
            const SizedBox(height: 14),
            Row(
              children: [
                _StatChip(
                  icon: Icons.whatshot_rounded,
                  label: '${state.dailyStreak} day streak',
                  color: state.dailyStreak >= 7
                      ? AppColors.hard
                      : state.dailyStreak >= 3
                      ? AppColors.gold
                      : AppColors.emeraldLight,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  icon: Icons.event_available_rounded,
                  label: '${state.totalCompleted} completed',
                  color: AppColors.lifelineBlue,
                ),
              ],
            ),

            if (!state.isCompleted) ...[
              const SizedBox(height: 14),

              // Reward chips
              Row(
                children: [
                  _RewardChip(
                    icon: Icons.monetization_on_rounded,
                    label: 'Server-calculated coins',
                    color: AppColors.coin,
                  ),
                  const SizedBox(width: 8),
                  _RewardChip(
                    icon: Icons.bolt_rounded,
                    label: '2× multiplier',
                    color: AppColors.gold,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              GoldButton(
                label: 'Start Challenge',
                onTap: widget.onTap,
                height: 44,
                icon: Icons.play_arrow_rounded,
              ),
            ],

            // ── Completed state ──────────────────
            if (state.isCompleted) ...[
              const SizedBox(height: 14),
              _CompletedBanner(
                score: state.todayChallenge?.score ?? 0,
                coinsEarned: state.todayChallenge?.coinsEarned ?? 0,
                timeLeft: _format(_timeLeft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({
    required this.score,
    required this.coinsEarned,
    required this.timeLeft,
  });

  final int score;
  final int coinsEarned;
  final String timeLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.emeraldLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.emeraldLight,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: $score/10 • Earned $coinsEarned Acoins',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldLight,
                  ),
                ),
                Text(
                  'Next challenge in $timeLeft',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: AppColors.textMuted,
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

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
      ),
    );
  }
}
