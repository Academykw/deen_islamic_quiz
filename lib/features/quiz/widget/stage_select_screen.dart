import 'package:deen_iq/app/router.dart';

import 'package:deen_iq/features/quiz/widget/stage_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/geo_background.dart';
import '../../../core/widgets/gold_button.dart';
import '../../../data/models/quiz_model.dart';
import '../../../state/quiz_provider.dart';


class StageSelectScreen extends ConsumerWidget {
  const StageSelectScreen({
    super.key,
    required this.difficulty,
  });

  final Difficulty difficulty;

  Color get _color {
    switch (difficulty) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }

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

  List<Stage> _getStages(WidgetRef ref) {
    switch (difficulty) {
      case Difficulty.easy:   return ref.watch(easyStagesProvider);
      case Difficulty.medium: return ref.watch(mediumStagesProvider);
      case Difficulty.hard:   return ref.watch(hardStagesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = _getStages(ref);
    final completed = stages.where((s) => s.isCompleted).length;
    final totalStars =
    stages.fold<int>(0, (sum, s) => sum + s.starsEarned);

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── App bar ───────────────────────
                _StageAppBar(color: _color),

                // ── Header ────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            _title,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: _color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding:
                            const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _arabicTitle,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                color: AppColors.textSecondary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const Spacer(),
                          // Stars summary
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.gold,
                                  size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$totalStars / ${stages.length * 3}',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Progress bar
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completed of ${stages.length} stages completed',
                                style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '${stages.isEmpty ? 0 : (completed / stages.length * 100).round()}%',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stages.isEmpty
                                  ? 0
                                  : completed / stages.length,
                              backgroundColor:
                              AppColors.darkBorder,
                              valueColor:
                              AlwaysStoppedAnimation(_color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Stage grid ────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        20, 0, 20, 40),
                    child: Column(
                      children: [
                        // 5-stage grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: stages.length,
                          itemBuilder: (context, index) {
                            final stage = stages[index];
                            return StageCard(
                              stage: stage,
                              difficulty: difficulty,
                              onTap: stage.isLocked
                                  ? null
                                  : () => _onStageTap(
                                  context, ref, stage),
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // ── How to unlock ──────────
                        if (stages
                            .any((s) => s.isLocked))
                          _UnlockInfoCard(color: _color),

                        const SizedBox(height: 20),

                        // ── Coin rewards table ─────
                        _CoinRewardsCard(
                            difficulty: difficulty,
                            color: _color),
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

  void _onStageTap(
      BuildContext context, WidgetRef ref, Stage stage) {
    // Show stage detail bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => _StageDetailSheet(
        stage: stage,
        difficulty: difficulty,
        color: _color,
        onStart: () {
          Navigator.of(context).pop(); // close sheet
          // Start quiz — wired to QuestionScreen in Step 10
          ref.read(quizProvider.notifier).startQuiz(stage);
          context.goNamed(
            Routes.question,
            extra: StageExtra(
                stage: stage, difficulty: difficulty)
          );
        },
      ),
    );
  }
}

// ── App bar ────────────────────────────────────
class _StageAppBar extends StatelessWidget {
  const _StageAppBar({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.goNamed(Routes.difficulty),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const Spacer(),
          const Text(
            'Select Stage',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
           Padding(
            padding: EdgeInsets.only(right: 16),
            child: CoinBadge(size: CoinBadgeSize.small),
          ),
        ],
      ),
    );
  }
}

// ── Unlock info card ───────────────────────────
class _UnlockInfoCard extends StatelessWidget {
  const _UnlockInfoCard({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_open_rounded,
              color: color, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Complete a stage with 60% or more to unlock the next one.',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coin rewards card ──────────────────────────
class _CoinRewardsCard extends StatelessWidget {
  const _CoinRewardsCard({
    required this.difficulty,
    required this.color,
  });

  final Difficulty difficulty;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Correct answer', '10–20 coins'],
      ['3× streak bonus', '1.5× multiplier'],
      ['5× streak bonus', '2× multiplier'],
      ['Stage completion', '+50 bonus coins'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: AppColors.coin, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Coin Rewards',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  row[0],
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  row[1],
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── Stage detail bottom sheet ──────────────────
class _StageDetailSheet extends StatelessWidget {
  const _StageDetailSheet({
    required this.stage,
    required this.difficulty,
    required this.color,
    required this.onStart,
  });

  final Stage stage;
  final Difficulty difficulty;
  final Color color;
  final VoidCallback onStart;

  String get _difficultyName {
    switch (difficulty) {
      case Difficulty.easy:   return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard:   return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Stage number orb
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '${stage.stageNumber}',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'Stage ${stage.stageNumber} · $_difficultyName',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              stage.isCompleted
                  ? 'Best: ${stage.bestScore}% · ${stage.starsEarned} ⭐ — play again to improve'
                  : '5 questions · Pass with 60% to unlock next stage',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SheetStat(
                    icon: Icons.help_outline_rounded,
                    label: 'Questions',
                    value: '5',
                    color: color),
                const SizedBox(width: 24),
                _SheetStat(
                    icon: Icons.timer_outlined,
                    label: 'Per question',
                    value: '30s',
                    color: color),
                const SizedBox(width: 24),
                _SheetStat(
                    icon: Icons.monetization_on_outlined,
                    label: 'Max coins',
                    value: '100+',
                    color: AppColors.coin),
              ],
            ),

            const SizedBox(height: 24),

            // Start button
            GoldButton(
              label: stage.isCompleted
                  ? 'Play Again'
                  : 'Start Stage',
              onTap: onStart,
              icon: Icons.play_arrow_rounded,
            ),

            const SizedBox(height: 10),

            GoldButton(
              label: 'Cancel',
              onTap: () => Navigator.of(context).pop(),
              variant: GoldButtonVariant.ghost,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetStat extends StatelessWidget {
  const _SheetStat({
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
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}