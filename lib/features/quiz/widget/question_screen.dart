import 'dart:async';
import 'package:deen_iq/features/quiz/widget/streak_indicator.dart';
import 'package:deen_iq/features/quiz/widget/timer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/geo_background.dart';
import '../../../data/models/lifeline.dart';
import '../../../data/models/quiz_model.dart';
import '../../../state/coin_provider.dart';
import '../../../state/quiz_provider.dart';
import '../../../state/quiz_state.dart';
import 'answer_option.dart';
import 'ask_friend_card.dart';
import 'combo_burst.dart';
import 'lifeline_button.dart';


class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({
    super.key,
    required this.stage,
  });

  final Stage stage;

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen>
    with TickerProviderStateMixin {
  final GlobalKey<TimerBarState> _timerBarKey = GlobalKey<TimerBarState>();
  bool _timerPaused = false;

  // Coin pop animation
  late AnimationController _coinPopCtrl;
  late Animation<Offset> _coinPopSlide;
  late Animation<double> _coinPopFade;
  int _lastCoinDelta = 0;
  bool _showCoinPop = false;

  // Question slide animation
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    // Coin pop
    _coinPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _coinPopSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(
        CurvedAnimation(parent: _coinPopCtrl, curve: Curves.easeOut));
    _coinPopFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _coinPopCtrl, curve: Curves.easeIn));

    // Question slide
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _slideCtrl.forward();
  }

  void _confirmQuit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Quit Quiz?',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Your progress will be lost. Coins earned so far will not be saved.',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Keep Playing',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.emeraldLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              ref.read(quizProvider.notifier).resetQuiz();
              context.goNamed(Routes.home);
            },
            child: const Text(
              'Quit',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.wrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _coinPopCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  // ── Handle answer tap ────────────────────────
  void _onAnswerTap(int index) {
    final quizState = ref.read(quizProvider);
    if (quizState.isAnswered) return;

    // Haptic
    HapticFeedback.lightImpact();

    final prevCoins = quizState.coinsEarned;
    ref.read(quizProvider.notifier).selectAnswer(index);
    final newState = ref.read(quizProvider);

    // Pause timer
    setState(() => _timerPaused = true);

    // Show coin pop if correct
    if (newState.isCorrect) {
      HapticFeedback.mediumImpact();
      final delta = newState.coinsEarned - prevCoins;
      _triggerCoinPop(delta);
    } else {
      HapticFeedback.heavyImpact();
    }

    // Auto-advance after 1.4 seconds (if no combo burst showing)
    if (!newState.showComboBurst) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _advance();
      });
    }
  }

  // ── Advance to next question or result ───────
  void _advance() {
    final quizState = ref.read(quizProvider);

    if (quizState.status == QuizStatus.complete ||
        quizState.isLastQuestion) {
      // Save stage progress
      ref.read(stageProgressProvider.notifier).completeStage(
        widget.stage,
        quizState.scorePercent,
      );

      // Go to result screen
      context.goNamed(
        Routes.result,
        extra: ResultExtra(stage: widget.stage),
      );
      return;
    }

    ref.read(quizProvider.notifier).nextQuestion();

    // Reset timer + slide animation
    _timerBarKey.currentState?.reset();
    setState(() {
      _timerPaused = false;
    });
    _slideCtrl
      ..reset()
      ..forward();
  }

  // ── Timer ran out ────────────────────────────
  void _onTimeUp() {
    if (!mounted) return;
    final quizState = ref.read(quizProvider);
    if (quizState.isAnswered) return;

    HapticFeedback.heavyImpact();
    // Treat as wrong — select an impossible index
    ref.read(quizProvider.notifier).selectAnswer(-1);
    setState(() => _timerPaused = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _advance();
    });
  }

  // ── Coin pop animation ───────────────────────
  void _triggerCoinPop(int delta) {
    setState(() {
      _lastCoinDelta = delta;
      _showCoinPop = true;
    });
    _coinPopCtrl
      ..reset()
      ..forward().then((_) {
        if (mounted) setState(() => _showCoinPop = false);
      });
  }

  // ── Determine answer state for each option ───
  AnswerState _answerState(int index, QuizState quizState) {
    // Eliminated by 50/50
    if (quizState.isEliminatedIndex(index) &&
        !quizState.isAnswered) {
      return AnswerState.idle; // handled by opacity below
    }

    if (!quizState.isAnswered) return AnswerState.idle;
    final correct = quizState.currentQuestion?.correctIndex;
    if (index == correct) return AnswerState.correct;
    if (index == quizState.selectedAnswerIndex) {
      return AnswerState.wrong;
    }
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final question = quizState.currentQuestion;

    // Safety — no question loaded
    if (question == null) {
      return const Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmQuit();
      },
      child: Scaffold(
        backgroundColor: AppColors.dark,
        body: Stack(
        children: [
          const GeoBackground(),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────
                _TopBar(
                  quizState: quizState,
                  onQuit: _confirmQuit,
                ),

                // ── Scrollable question area ────
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // Timer
                        TimerBar(
                          key: _timerBarKey,
                          seconds: 30,
                          onTimeUp: _onTimeUp,
                          isPaused: _timerPaused,
                        ),

                        // ── Lifeline row ─────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _LifelineRow(
                            timerKey: _timerBarKey,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Streak indicator
                        if (quizState.streak > 0)
                          Padding(
                            padding:
                            const EdgeInsets.only(bottom: 12),
                            child: StreakIndicator(
                                streak: quizState.streak),
                          ),

                        // Question card
                        SlideTransition(
                          position: _slideIn,
                          child: _QuestionCard(
                            quizState: quizState,
                            question: question,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Answer options
                        SlideTransition(
                          position: _slideIn,
                          child: Column(
                            children: List.generate(
                              question.options.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: quizState.isEliminatedIndex(i) &&
                                          !quizState.isAnswered
                                      ? 0.18
                                      : 1.0,
                                  child: IgnorePointer(
                                    ignoring: quizState.isEliminatedIndex(i) &&
                                        !quizState.isAnswered,
                                    child: AnswerOption(
                                      label: question.options[i],
                                      index: i,
                                      state: _answerState(i, quizState),
                                      onTap: () => _onAnswerTap(i),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Ask friend hint card
                        if (quizState.friendHint != null)
                          AskFriendCard(
                            hint: quizState.friendHint!,
                            confidence: quizState.friendConfidence,
                          ),

                        // Explanation (shown after answer)
                        if (quizState.isAnswered &&
                            question.explanation != null)
                          _ExplanationCard(
                            explanation: question.explanation!,
                            isCorrect: quizState.isCorrect,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Coin pop overlay ────────────────────
          if (_showCoinPop)
            Positioned(
              top: 80,
              right: 24,
              child: SlideTransition(
                position: _coinPopSlide,
                child: FadeTransition(
                  opacity: _coinPopFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.coin.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.coin.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            color: AppColors.coin, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+$_lastCoinDelta',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.coin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Combo burst overlay ─────────────────────
          Consumer(
            builder: (context, ref, _) {
              final showBurst = ref.watch(
                quizProvider.select((s) => s.showComboBurst),
              );
              final streak = ref.watch(
                quizProvider.select((s) => s.streak),
              );

              if (!showBurst) return const SizedBox.shrink();

              return ComboBurst(
                streak: streak,
                onComplete: () {
                  ref
                      .read(quizProvider.notifier)
                      .dismissComboBurst();
                  // Resume auto-advance
                  Future.delayed(
                      const Duration(milliseconds: 200),
                          () {
                        if (mounted) _advance();
                      });
                },
              );
            },
          ),
        ],
      ),
      )
    );
  }
}

// ── Top bar ────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.quizState,
    required this.onQuit,
  });

  final QuizState quizState;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Quit button
          GestureDetector(
            onTap: onQuit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Progress dots
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                quizState.totalQuestions,
                    (i) {
                  final isDone = i < quizState.currentIndex;
                  final isCurrent = i == quizState.currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 3),
                    width: isCurrent ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isDone
                          ? AppColors.emeraldLight
                          : isCurrent
                          ? AppColors.gold
                          : AppColors.darkBorder,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Coin badge
          const CoinBadge(size: CoinBadgeSize.small),
        ],
      ),
    );
  }
}

// ── Question card ──────────────────────────────
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.quizState,
    required this.question,
  });

  final QuizState quizState;
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top accent line
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Question number + category
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Question ${quizState.currentIndex + 1} of ${quizState.totalQuestions}',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const Spacer(),
              // Score so far
              Text(
                '${quizState.score} correct',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Arabic text (if available)
          if (question.arabicText != null && question.arabicText!.isNotEmpty) ...[
            Text(
              question.arabicText!,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                color: AppColors.goldLight,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.darkBorder, height: 1),
            const SizedBox(height: 16),
          ],

          // English question text
          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Explanation card ───────────────────────────
class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.explanation,
    required this.isCorrect,
  });

  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color =
    isCorrect ? AppColors.correct : AppColors.wrong;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct! 🎉' : 'Not quite',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
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



// ── Lifeline row widget ────────────────────────
class _LifelineRow extends ConsumerWidget {
  const _LifelineRow({required this.timerKey});
  final GlobalKey<TimerBarState> timerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final coins = ref.watch(coinProvider);

    if (quizState.lifelines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: quizState.lifelines.map((lifeline) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: LifelineButton(
                lifeline: lifeline.copyWith(
                  // Indicate if not enough coins
                  isDisabled: coins < lifeline.coinCost,
                ),
                onTap: () => _onLifelineTap(
                    context, ref, lifeline, coins),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _onLifelineTap(
      BuildContext context,
      WidgetRef ref,
      Lifeline lifeline,
      int coins,
      ) async {
    final quizNotifier = ref.read(quizProvider.notifier);
    final quizState = ref.read(quizProvider);

    // Prevent use if already answered
    if (quizState.isAnswered) return;

    // Check coins
    if (coins < lifeline.coinCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough coins! Need ${lifeline.coinCost} coins.',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.wrong,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Apply lifeline first to get immediate feedback if possible
    bool usedSuccessfully = false;

    switch (lifeline.type) {
      case LifelineType.fiftyFifty:
        quizNotifier.useFiftyFifty();
        usedSuccessfully = true;
        break;
      case LifelineType.askFriend:
        quizNotifier.useAskFriend();
        usedSuccessfully = true;
        break;
      case LifelineType.extraTime:
        usedSuccessfully = quizNotifier.useExtraTime();
        if (usedSuccessfully) {
          timerKey.currentState?.addTime(15);
        }
        break;
    }

    if (usedSuccessfully) {
      // Deduct coins only if used successfully
      await ref.read(coinProvider.notifier).spendCoins(
        lifeline.coinCost,
      );
    }
  }
}

