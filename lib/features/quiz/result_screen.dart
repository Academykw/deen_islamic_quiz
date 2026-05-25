import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constant/app_colors.dart';
import '../../core/widgets/geo_background.dart';
import '../../core/widgets/gold_button.dart';
import '../../data/models/quiz_model.dart';
import '../../state/quiz_provider.dart';
import '../../state/quiz_state.dart';
import 'widget/coin_earn_animation.dart';
import 'widget/star_display.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.stage,
  });

  final Stage stage;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  // Fade-in for the whole screen
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Slide up for content sections
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // Score percentage counter
  late AnimationController _scoreCtrl;
  late Animation<int> _scoreAnim;

  late QuizState _finalState;
  late int _stars;

  @override
  void initState() {
    super.initState();

    // Capture final state before any resets
    _finalState = ref.read(quizProvider);
    _stars = Stage.calculateStars(_finalState.scorePercent);

    // Fade in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
        parent: _fadeCtrl, curve: Curves.easeIn);

    // Slide up
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Score counter
    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scoreAnim = IntTween(
      begin: 0,
      end: _finalState.scorePercent,
    ).animate(
        CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scoreCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  String get _resultTitle {
    if (_finalState.scorePercent >= 90) return 'ما شاء الله!';
    if (_finalState.scorePercent >= 75) return 'أحسنت!';
    if (_finalState.scorePercent >= 60) return 'جيد جداً';
    return 'حاول مجدداً';
  }

  String get _resultTitleEn {
    if (_finalState.scorePercent >= 90) return 'Masha\'Allah!';
    if (_finalState.scorePercent >= 75) return 'Excellent!';
    if (_finalState.scorePercent >= 60) return 'Well Done!';
    return 'Keep Trying!';
  }

  String get _resultSubtitle {
    if (_finalState.scorePercent >= 90) {
      return 'Outstanding knowledge! May Allah bless your learning.';
    }
    if (_finalState.scorePercent >= 75) {
      return 'Great performance! Keep studying the Deen.';
    }
    if (_finalState.scorePercent >= 60) {
      return 'You passed! Next stage is now unlocked.';
    }
    return 'Don\'t worry, review and try again. Every attempt is worship.';
  }

  Color get _scoreColor {
    if (_finalState.scorePercent >= 75) return AppColors.emeraldLight;
    if (_finalState.scorePercent >= 60) return AppColors.gold;
    return AppColors.wrong;
  }

  Difficulty get _difficulty => widget.stage.difficulty;

  Color get _diffColor {
    switch (_difficulty) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),

          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // ── Header ─────────────────
                      _ResultHeader(
                        arabicTitle: _resultTitle,
                        englishTitle: _resultTitleEn,
                        subtitle: _resultSubtitle,
                        scorePercent: _finalState.scorePercent,
                        scoreColor: _scoreColor,
                        scoreAnim: _scoreAnim,
                        isPassing: _finalState.isPassing,
                      ),

                      const SizedBox(height: 24),

                      // ── Stars ───────────────────
                      StarDisplay(stars: _stars),

                      const SizedBox(height: 24),

                      // ── Coins earned ────────────
                      CoinEarnAnimation(
                          coinsEarned: _finalState.coinsEarned),

                      const SizedBox(height: 24),

                      // ── Stats grid ──────────────
                      _StatsGrid(
                        quizState: _finalState,
                        diffColor: _diffColor,
                      ),

                      const SizedBox(height: 24),

                      // ── Questions review ────────
                      _QuestionReview(
                        quizState: _finalState,
                        diffColor: _diffColor,
                      ),

                      const SizedBox(height: 28),

                      // ── Action buttons ──────────
                      _ActionButtons(
                        stage: widget.stage,
                        isPassing: _finalState.isPassing,
                        onHome: _goHome,
                        onRetry: _retry,
                        onNext: _finalState.isPassing
                            ? _goNext
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation actions ─────────────────────────
  void _goHome() {
    // Navigate home first to avoid UI flashes
    context.goNamed(Routes.home);
    
    // Reset the quiz state after a short delay to ensure navigation started
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(quizProvider.notifier).resetQuiz();
      }
    });
  }

  void _retry() {
    final s = widget.stage;
    ref.read(quizProvider.notifier).startQuiz(s);
    context.goNamed(
      Routes.question,
      extra: StageExtra(
        stage: s,
        difficulty: _difficulty,
      ),
    );
  }

  void _goNext() {
    final stages = ref
        .read(stageProgressProvider.notifier)
        .getStages(_difficulty);
    
    final nextStage = stages.firstWhere(
          (s) => s.stageNumber == widget.stage.stageNumber + 1,
      orElse: () => widget.stage,
    );

    if (nextStage.stageNumber != widget.stage.stageNumber) {
      ref.read(quizProvider.notifier).startQuiz(nextStage);
      context.goNamed(
        Routes.question,
        extra: StageExtra(
          stage: nextStage,
          difficulty: _difficulty,
        ),
      );
    } else {
      context.goNamed(Routes.difficulty);
    }
  }
}

// ── Result header ──────────────────────────────
class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.arabicTitle,
    required this.englishTitle,
    required this.subtitle,
    required this.scorePercent,
    required this.scoreColor,
    required this.scoreAnim,
    required this.isPassing,
  });

  final String arabicTitle;
  final String englishTitle;
  final String subtitle;
  final int scorePercent;
  final Color scoreColor;
  final Animation<int> scoreAnim;
  final bool isPassing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Score orb
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scoreColor.withValues(alpha: 0.3),
                scoreColor.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(color: scoreColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: 0.3),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: scoreAnim,
                  builder: (context, child) => Text(
                    '${scoreAnim.value}%',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                ),
                Text(
                  isPassing ? 'PASSED' : 'FAILED',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Arabic title
        Text(
          arabicTitle,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
          ),
          textDirection: TextDirection.rtl,
        ),

        const SizedBox(height: 4),

        // English title
        Text(
          englishTitle,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Stats grid ─────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.quizState,
    required this.diffColor,
  });

  final QuizState quizState;
  final Color diffColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Session Stats',
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatItem(
                  label: 'Correct',
                  value: '${quizState.score}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.correct,
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Wrong',
                  value:
                  '${quizState.totalQuestions - quizState.score}',
                  icon: Icons.cancel_rounded,
                  color: AppColors.wrong,
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Best Streak',
                  value: '${quizState.bestStreak}',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.gold,
                ),
                _StatDivider(),
                _StatItem(
                  label: 'Accuracy',
                  value: '${quizState.scorePercent}%',
                  icon: Icons.gps_fixed_rounded,
                  color: diffColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.darkBorder,
    );
  }
}

// ── Question review ────────────────────────────
class _QuestionReview extends StatelessWidget {
  const _QuestionReview({
    required this.quizState,
    required this.diffColor,
  });

  final QuizState quizState;
  final Color diffColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.list_alt_rounded,
                    color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Question Review',
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quizState.questions.length,
            separatorBuilder: (context, index) => const Divider(
                height: 1, color: AppColors.darkBorder),
            itemBuilder: (context, i) {
              final q = quizState.questions[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: diffColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: diffColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.text,
                            style: const TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.correct,
                                  size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  q.correctAnswer,
                                  style: const TextStyle(
                                    fontFamily: 'Tajawal',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.correct,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Action buttons ─────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.stage,
    required this.isPassing,
    required this.onHome,
    required this.onRetry,
    this.onNext,
  });

  final Stage stage;
  final bool isPassing;
  final VoidCallback onHome;
  final VoidCallback onRetry;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Next stage button (only if passed)
        if (isPassing && onNext != null) ...[
          GoldButton(
            label: 'Next Stage',
            onTap: onNext,
            icon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(height: 10),
        ],

        // Retry button
        GoldButton(
          label: isPassing ? 'Play Again' : 'Try Again',
          onTap: onRetry,
          variant: isPassing
              ? GoldButtonVariant.outlined
              : GoldButtonVariant.filled,
          icon: Icons.replay_rounded,
        ),

        const SizedBox(height: 10),

        // Home button
        GoldButton(
          label: 'Back to Home',
          onTap: onHome,
          variant: GoldButtonVariant.ghost,
          icon: Icons.home_rounded,
        ),
      ],
    );
  }
}
