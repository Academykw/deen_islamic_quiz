import 'package:deen_iq/features/quiz/widget/answer_option.dart';
import 'package:deen_iq/features/quiz/widget/combo_burst.dart';
import 'package:deen_iq/features/quiz/widget/streak_indicator.dart';
import 'package:deen_iq/features/quiz/widget/timer_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/geo_background.dart';

import '../../data/models/quiz_model.dart';
import '../../data/repositories/daily_challenge_repository.dart';
import '../../state/daily_challenge_provider.dart';
import '../../app/router.dart';
import 'daily_result_screen.dart';

class DailyQuestionScreen extends ConsumerStatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  ConsumerState<DailyQuestionScreen> createState() =>
      _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends ConsumerState<DailyQuestionScreen>
    with TickerProviderStateMixin {
  // Current question index (local — not using QuizProvider stages)
  int _currentIndex = 0;
  Question? _question;
  Question? _nextQuestion;
  String? _sessionId;
  int _totalQuestions = 10;
  bool _isComplete = false;
  bool _isSubmitting = false;
  bool _isLoaded = false;
  String? _loadError;

  // Per-question state
  int? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _timerPaused = false;

  // Session stats
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _coinsEarned = 0;

  // Combo burst
  bool _showComboBurst = false;

  // Animations
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;
  late AnimationController _coinPopCtrl;
  late Animation<Offset> _coinPopSlide;
  late Animation<double> _coinPopFade;
  int _lastCoinDelta = 0;
  bool _showCoinPop = false;

  // Timer key
  final GlobalKey<TimerBarState> _timerBarKey = GlobalKey<TimerBarState>();

  @override
  void initState() {
    super.initState();

    // Slide animation
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    // Coin pop animation
    _coinPopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _coinPopSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.5),
    ).animate(CurvedAnimation(parent: _coinPopCtrl, curve: Curves.easeOut));
    _coinPopFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _coinPopCtrl, curve: Curves.easeIn));

    _startSession();
  }

  Future<void> _startSession() async {
    try {
      final response = await DailyChallengeRepository.instance.startSession();
      if (!mounted) return;
      if (response['complete'] == true) {
        _score = response['score'] as int? ?? 0;
        _coinsEarned = response['earned'] as int? ?? 0;
        _bestStreak = response['bestStreak'] as int? ?? 0;
        _totalQuestions = response['totalQuestions'] as int? ?? 10;
        await ref.read(dailyChallengeProvider.notifier).refresh();
        if (mounted) _openResult();
        return;
      }
      final data = Map<String, dynamic>.from(response['question'] as Map);
      setState(() {
        _sessionId = response['sessionId'] as String;
        _question = Question.fromMap(data, data['id'] as String);
        _currentIndex = (response['questionNumber'] as int? ?? 1) - 1;
        _totalQuestions = response['totalQuestions'] as int? ?? 10;
        _score = response['score'] as int? ?? 0;
        _streak = response['streak'] as int? ?? 0;
        _bestStreak = response['bestStreak'] as int? ?? 0;
        _coinsEarned = response['earned'] as int? ?? 0;
        _isLoaded = true;
      });
      _slideCtrl.forward();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Could not start the daily challenge. Please try again.';
          _isLoaded = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _coinPopCtrl.dispose();
    super.dispose();
  }

  Question get _currentQuestion => _question!;

  // ── Answer tap ─────────────────────────────────
  Future<void> _onAnswerTap(int index) async {
    if (_isAnswered || _isSubmitting) return;
    HapticFeedback.lightImpact();
    await _submitServerAnswer(index);
    return;
    // ignore: dead_code
    final correct = false;
    // ignore: dead_code
    final newStreak = 0;
    // ignore: dead_code
    final newBestStreak = 0;

    // Calculate coins with 2× daily multiplier
    int coins = 0;
    if (correct) {
      final base = _currentQuestion.adjustedCoinReward;
      double multiplier = 2.0; // Daily challenge base 2×
      if (newStreak >= 5) multiplier = 4.0; // 2× daily × 2× streak
      if (newStreak >= 3) multiplier = 3.0; // 2× daily × 1.5× streak
      coins = (base * multiplier).round();
    }

    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;
      _isCorrect = correct;
      _timerPaused = true;
      _streak = newStreak;
      _bestStreak = newBestStreak;
      if (correct) {
        _score++;
        _coinsEarned += coins;
      }
    });
    final audio = ref.read(audioServiceProvider);

    if (correct) {
      HapticFeedback.mediumImpact();
      _triggerCoinPop(coins);
      Future.delayed(const Duration(milliseconds: 200), () {
        audio.play(SoundEffect.coinEarn);
      });

      // Combo burst at milestones
      if (newStreak == 3 || newStreak == 5 || newStreak == 7) {
        audio.play(SoundEffect.comboBurst);
        setState(() => _showComboBurst = true);
        return; // Advance handled by burst dismiss
      }
    } else {
      HapticFeedback.heavyImpact();
      audio.play(SoundEffect.wrong);
    }

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _advance();
    });
  }

  // ── Timer up ───────────────────────────────────
  Future<void> _submitServerAnswer(int selectedIndex) async {
    if (_isAnswered || _isSubmitting || _sessionId == null) return;
    setState(() {
      _isSubmitting = true;
      _timerPaused = true;
    });
    try {
      final response = await DailyChallengeRepository.instance.submitAnswer(
        sessionId: _sessionId!,
        questionId: _currentQuestion.id,
        selectedIndex: selectedIndex,
        requestId:
            '${_currentQuestion.id}_${DateTime.now().microsecondsSinceEpoch}',
      );
      if (!mounted) return;
      final correct = response['correct'] == true;
      final reward = response['reward'] as int? ?? 0;
      final nextData = response['nextQuestion'];
      setState(() {
        _selectedAnswer = selectedIndex < 0 ? null : selectedIndex;
        _isAnswered = true;
        _isSubmitting = false;
        _isCorrect = correct;
        _score = response['score'] as int? ?? _score;
        _streak = response['streak'] as int? ?? 0;
        _bestStreak = response['bestStreak'] as int? ?? _bestStreak;
        _coinsEarned = response['earned'] as int? ?? _coinsEarned;
        _isComplete = response['complete'] == true;
        _question = _currentQuestion.copyWith(
          correctIndex: response['correctIndex'] as int,
          explanation: response['explanation'] as String? ?? '',
        );
        if (nextData is Map) {
          final data = Map<String, dynamic>.from(nextData);
          _nextQuestion = Question.fromMap(data, data['id'] as String);
        }
      });
      final audio = ref.read(audioServiceProvider);
      if (correct) {
        HapticFeedback.mediumImpact();
        if (reward > 0) _triggerCoinPop(reward);
        audio.play(SoundEffect.coinEarn);
        if (_streak == 3 || _streak == 5 || _streak == 7) {
          audio.play(SoundEffect.comboBurst);
          setState(() => _showComboBurst = true);
          return;
        }
      } else {
        HapticFeedback.heavyImpact();
        audio.play(SoundEffect.wrong);
      }
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _advance();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _timerPaused = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer was not submitted. Please try again.'),
        ),
      );
    }
  }

  void _onTimeUp() {
    if (_isAnswered || _isSubmitting) return;
    _submitServerAnswer(-1);
  }

  // ── Advance ────────────────────────────────────
  void _advance() {
    final isLast = _isComplete;

    if (isLast) {
      _finishChallenge();
      return;
    }

    if (_nextQuestion == null) return;

    setState(() {
      _currentIndex++;
      _question = _nextQuestion;
      _nextQuestion = null;
      _selectedAnswer = null;
      _isAnswered = false;
      _isCorrect = false;
      _timerPaused = false;
    });

    _slideCtrl
      ..reset()
      ..forward();
  }

  // ── Finish ─────────────────────────────────────
  Future<void> _finishChallenge() async {
    ref.read(audioServiceProvider).play(SoundEffect.stageComplete);
    await ref.read(dailyChallengeProvider.notifier).refresh();
    if (mounted) _openResult();
  }

  void _openResult() {
    context.goNamed(
      Routes.dailyResult,
      extra: DailyResultExtra(
        score: _score,
        total: _totalQuestions,
        coinsEarned: _coinsEarned,
        bestStreak: _bestStreak,
      ),
    );
  }

  // ── Coin pop ───────────────────────────────────
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

  AnswerState _answerState(int index) {
    if (!_isAnswered) return AnswerState.idle;
    if (index == _currentQuestion.correctIndex) return AnswerState.correct;
    if (index == _selectedAnswer) return AnswerState.wrong;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    if (_loadError != null || _question == null) {
      return Scaffold(
        backgroundColor: AppColors.dark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadError ?? 'The daily challenge is unavailable.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _isLoaded = false;
                      _loadError = null;
                    });
                    _startSession();
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _currentQuestion;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────
                _DailyTopBar(
                  currentIndex: _currentIndex,
                  total: _totalQuestions,
                  coinsEarned: _coinsEarned,
                  streak: _streak,
                ),

                // ── Content ──────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timer
                        TimerBar(
                          key: _timerBarKey,
                          seconds: 30,
                          onTimeUp: _onTimeUp,
                          isPaused: _timerPaused,
                        ),

                        const SizedBox(height: 12),

                        // Streak
                        if (_streak > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: StreakIndicator(streak: _streak),
                          ),

                        // Question card
                        SlideTransition(
                          position: _slideIn,
                          child: _DailyQuestionCard(
                            question: question,
                            currentIndex: _currentIndex,
                            total: _totalQuestions,
                            score: _score,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Answer options
                        SlideTransition(
                          position: _slideIn,
                          child: Column(
                            children: List.generate(
                              question.options.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AnswerOption(
                                  label: question.options[i],
                                  index: i,
                                  state: _answerState(i),
                                  onTap: () => _onAnswerTap(i),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Explanation
                        if (_isAnswered && question.explanation != null)
                          _ExplanationCard(
                            explanation: question.explanation!,
                            isCorrect: _isCorrect,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Coin pop overlay ──────────────────
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
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coin.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.coin.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.coin,
                          size: 14,
                        ),
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

          // ── Combo burst overlay ───────────────
          if (_showComboBurst)
            ComboBurst(
              streak: _streak,
              onComplete: () {
                setState(() => _showComboBurst = false);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) _advance();
                });
              },
            ),
        ],
      ),
    );
  }
}

// ── Daily top bar ──────────────────────────────
class _DailyTopBar extends StatelessWidget {
  const _DailyTopBar({
    required this.currentIndex,
    required this.total,
    required this.coinsEarned,
    required this.streak,
  });

  final int currentIndex;
  final int total;
  final int coinsEarned;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Daily badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.emeraldLight.withOpacity(0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.emeraldLight,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'DAILY',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emeraldLight,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Progress dots
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final isDone = i < currentIndex;
                final isCurrent = i == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: isCurrent ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDone
                        ? AppColors.emeraldLight
                        : isCurrent
                        ? AppColors.gold
                        : AppColors.darkBorder,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(width: 10),

          // Coins earned
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.coin,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '+$coinsEarned',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily question card ────────────────────────
class _DailyQuestionCard extends StatelessWidget {
  const _DailyQuestionCard({
    required this.question,
    required this.currentIndex,
    required this.total,
    required this.score,
  });

  final Question question;
  final int currentIndex;
  final int total;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: const Border(
          top: BorderSide(color: AppColors.emeraldLight, width: 2),
          left: BorderSide(color: AppColors.darkBorder),
          right: BorderSide(color: AppColors.darkBorder),
          bottom: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.emeraldLight.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Question ${currentIndex + 1} of $total',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emeraldLight,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$score correct',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (question.arabicText != null) ...[
            Text(
              question.arabicText!,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                color: AppColors.goldLight,
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.darkBorder, height: 1),
            const SizedBox(height: 10),
          ],

          Text(
            question.text,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Explanation card ───────────────────────────
class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.explanation, required this.isCorrect});

  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.correct : AppColors.wrong;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
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
