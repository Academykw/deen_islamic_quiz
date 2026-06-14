import 'package:deen_iq/features/quiz/widget/difficulty_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../core/constant/app_colors.dart';

import '../../core/widgets/coin_badge.dart';
import '../../core/widgets/geo_background.dart';

import '../../data/models/quiz_model.dart';
import '../../state/quiz_provider.dart';


class DifficultyScreen extends ConsumerWidget {
  const DifficultyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final easyStages  = ref.watch(easyStagesProvider);
    final mediumStages = ref.watch(mediumStagesProvider);
    final hardStages  = ref.watch(hardStagesProvider);

    // Total stats across all difficulties
    final allStages = [...easyStages, ...mediumStages, ...hardStages];
    final totalCompleted = allStages.where((s) => s.isCompleted).length;
    final totalStars = allStages.fold<int>(0, (sum, s) => sum + s.starsEarned);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── App Bar ───────────────────────
                _DifficultyAppBar(),

                // ── Header ────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Difficulty',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'اختر مستوى الصعوبة',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 14),

                      // ── Summary chips ──────────
                      Row(
                        children: [
                          _SummaryChip(
                            icon: Icons.layers_rounded,
                            label: '$totalCompleted / ${allStages.length} Stages',
                            color: AppColors.emeraldLight,
                          ),
                          const SizedBox(width: 10),
                          _SummaryChip(
                            icon: Icons.star_rounded,
                            label: '$totalStars Stars',
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Difficulty cards ──────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      children: [
                        DifficultyCard(
                          difficulty: Difficulty.easy,
                          stages: easyStages,
                          onTap: () {
                            // Navigate to stage select — wired in Step 10
                            // context.go('/stages/easy');
                            _navigateToStages(
                                context, Difficulty.easy);
                          },
                        ),
                        const SizedBox(height: 14),
                        DifficultyCard(
                          difficulty: Difficulty.medium,
                          stages: mediumStages,
                          onTap: () {
                            _navigateToStages(
                                context, Difficulty.medium);
                          },
                        ),
                        const SizedBox(height: 14),
                        DifficultyCard(
                          difficulty: Difficulty.hard,
                          stages: hardStages,
                          onTap: () {
                            _navigateToStages(
                                context, Difficulty.hard);
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── How coins work banner ──
                        _CoinInfoBanner(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStages(BuildContext context, Difficulty difficulty) {
    context.pushNamed(
      Routes.stages,
      pathParameters: {'difficulty': difficulty.name},
    );
  }
}

// ── App Bar ────────────────────────────────────
class _DifficultyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const Spacer(),
          const Text(
            'DEEN',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CoinBadge(size: CoinBadgeSize.small),
          ),
        ],
      ),
    );
  }
}

// ── Summary chip ───────────────────────────────
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
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

// ── Coin info banner ───────────────────────────
class _CoinInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.coin.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.coin.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.coin.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.coin,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn Real Coins',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Answer correctly to earn coins. Streak bonuses give 1.5× – 2× rewards. Redeem for real money!',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.5,
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

