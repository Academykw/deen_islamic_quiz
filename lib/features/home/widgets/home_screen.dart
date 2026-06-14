import 'package:deen_iq/features/home/widgets/quick_play_card.dart';
import 'package:deen_iq/features/home/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/geo_background.dart';
import '../../../state/coin_provider.dart';
import '../../../state/quiz_provider.dart';
import 'daily_challenge_card.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinProvider);
    final easyStages = ref.watch(easyStagesProvider);
    final mediumStages = ref.watch(mediumStagesProvider);
    final hardStages = ref.watch(hardStagesProvider);

    // Compute stats from stage progress
    final completedCount = [
      ...easyStages,
      ...mediumStages,
      ...hardStages,
    ].where((s) => s.isCompleted).length;

    final bestStreak = ref.watch(
      quizProvider.select((s) => s.bestStreak),
    );

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: Column(
              children: [
                // ── App Bar ─────────────────────
                _HomeAppBar(coins: coins),

                // ── Scrollable content ──────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Arabic greeting
                        _ArabicGreeting(),

                        const SizedBox(height: 20),

                        // Stats row
                        _StatsRow(
                          completedStages: completedCount,
                          bestStreak: bestStreak,
                          coins: coins,
                        ),

                        const SizedBox(height: 24),

                        // Quick play card
                        QuickPlayCard(
                          onTap: () => context.pushNamed(Routes.difficulty),
                        ),

                        const SizedBox(height: 20),

                        // Section label
                        const _SectionLabel(text: 'DAILY CHALLENGE'),

                        const SizedBox(height: 12),

                        // Daily challenge card
                        DailyChallengeCard(
                          onTap: () => context.pushNamed(Routes.difficulty),
                        ),

                        const SizedBox(height: 24),

                        // Section label
                        const _SectionLabel(text: 'YOUR PROGRESS'),

                        const SizedBox(height: 12),

                        // Progress by difficulty
                        _ProgressSection(
                          easyStages: easyStages,
                          mediumStages: mediumStages,
                          hardStages: hardStages,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DeenBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index){
            case 0:
              context.goNamed(Routes.home);
              break;
            case 1:
              context.pushNamed(Routes.leaderboard);
              break;
            case 2:
              context.goNamed(Routes.profile);
              break;
            case 3:
            // Redeem — Phase 3
            // context.goNamed(Routes.redeem);
              break;
          }
        },
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo + name
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [AppColors.emeraldMid, AppColors.emerald],
              ),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
            ),
            child: const Center(
              child: Text('☪',
                  style: TextStyle(fontSize: 18, color: AppColors.gold)),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEEN IQ',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'Islamic Quiz',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          // Coin badge
          const CoinBadge(),
        ],
      ),
    );
  }
}

// ── Arabic Greeting ────────────────────────────
class _ArabicGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
        ? 'مرحباً'
        : 'مساء الخير';
    final greetingEn = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Welcome Back'
        : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          greetingEn,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Stats Row ──────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.completedStages,
    required this.bestStreak,
    required this.coins,
  });

  final int completedStages;
  final int bestStreak;
  final int coins;

  String get _multiplier {
    if (bestStreak >= 5) return '2×';
    if (bestStreak >= 3) return '1.5×';
    return '1×';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          label: 'Stages Done',
          value: completedStages.toString(),
          icon: Icons.layers_rounded,
          valueColor: AppColors.emeraldLight,
        ),
        const SizedBox(width: 10),
        StatCard(
          label: 'Best Streak',
          value: bestStreak.toString(),
          icon: Icons.local_fire_department_rounded,
          valueColor: AppColors.gold,
        ),
        const SizedBox(width: 10),
      /*  StatCard(
          label: 'Total Coins',
          value: coins >= 1000
              ? '${(coins / 1000).toStringAsFixed(1)}k'
              : coins.toString(),
          icon: Icons.monetization_on_rounded,
          valueColor: AppColors.coin,
        ),*/
        StatCard(
          label: 'Best Multi',
          value: _multiplier,
          icon: Icons.bolt_rounded,
          valueColor: AppColors.hard,
        ),
      ],
    );
  }
}

// ── Section Label ──────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ── Progress Section ───────────────────────────
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.easyStages,
    required this.mediumStages,
    required this.hardStages,
  });

  final List easyStages;
  final List mediumStages;
  final List hardStages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DifficultyProgressRow(
          label: 'Easy',
          color: AppColors.easy,
          stages: easyStages,
        ),
        const SizedBox(height: 10),
        _DifficultyProgressRow(
          label: 'Medium',
          color: AppColors.medium,
          stages: mediumStages,
        ),
        const SizedBox(height: 10),
        _DifficultyProgressRow(
          label: 'Hard',
          color: AppColors.hard,
          stages: hardStages,
        ),
      ],
    );
  }
}

class _DifficultyProgressRow extends StatelessWidget {
  const _DifficultyProgressRow({
    required this.label,
    required this.color,
    required this.stages,
  });

  final String label;
  final Color color;
  final List stages;

  @override
  Widget build(BuildContext context) {
    final completed = stages.where((s) => s.isCompleted).length;
    final total = stages.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          // Colour dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          // Label
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.darkBorder,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Count
          Text(
            '$completed/$total',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}