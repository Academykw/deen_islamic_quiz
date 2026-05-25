import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/quiz_model.dart';
import 'quiz_state.dart';

import '../data/repositories/quiz_repository.dart';

// ─────────────────────────────────────────────
// QUIZ PROVIDER
// Manages the active quiz session
// ─────────────────────────────────────────────

class QuizNotifier extends Notifier<QuizState> {
  @override
  QuizState build() => const QuizState();

  // ── Start a new quiz session ──────────────────
  void startQuiz(Stage stage) {
    final questions = QuizRepository.instance.getQuestionsForStage(stage);
    // Shuffle so replaying a stage feels fresh
    final shuffled = List<Question>.from(questions)..shuffle();
    state = QuizState(
      questions: shuffled,
      status: QuizStatus.active,
      currentStage: stage,
    );
  }

  // ── User taps an answer ───────────────────────
  void selectAnswer(int index) {
    // Ignore if already answered or no active question
    if (state.isAnswered || state.status != QuizStatus.active) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final correct = index == question.correctIndex;
    final newStreak = correct ? state.streak + 1 : 0;
    final newBestStreak =
    newStreak > state.bestStreak ? newStreak : state.bestStreak;
    final newScore = correct ? state.score + 1 : state.score;
    final coinsForAnswer = correct ? _calculateCoins(question, newStreak) : 0;

    state = state.copyWith(
      selectedAnswerIndex: index,
      isAnswered: true,
      isCorrect: correct,
      score: newScore,
      streak: newStreak,
      bestStreak: newBestStreak,
      coinsEarned: state.coinsEarned + coinsForAnswer,
      status: QuizStatus.answered,
    );
  }

  // ── Advance to next question ──────────────────
  void nextQuestion() {
    if (state.status != QuizStatus.answered) return;

    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= state.totalQuestions;

    state = state.copyWith(
      currentIndex: nextIndex,
      clearSelectedAnswer: true,
      isAnswered: false,
      isCorrect: false,
      status: isComplete ? QuizStatus.complete : QuizStatus.active,
    );
  }

  // ── Reset back to idle ────────────────────────
  void resetQuiz() {
    state = const QuizState();
  }

  // ── Coin calculation with streak multiplier ───
  int _calculateCoins(Question question, int streak) {
    final base = question.adjustedCoinReward;
    if (streak >= 5) return (base * 2).round();
    if (streak >= 3) return (base * 1.5).round();
    return base;
  }
}

/// The single provider your widgets will watch
final quizProvider = NotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);

// ─────────────────────────────────────────────
// STAGE PROGRESS PROVIDER
// Persists stage completion to SharedPreferences
// ─────────────────────────────────────────────

class StageProgressState {
  const StageProgressState({
    this.easyProgress = const {},
    this.mediumProgress = const {},
    this.hardProgress = const {},
  });

  // Map<stageId, {'stars': int, 'bestScore': int}>
  final Map<String, Map<String, int>> easyProgress;
  final Map<String, Map<String, int>> mediumProgress;
  final Map<String, Map<String, int>> hardProgress;

  Map<String, Map<String, int>> forDifficulty(Difficulty d) {
    switch (d) {
      case Difficulty.easy:   return easyProgress;
      case Difficulty.medium: return mediumProgress;
      case Difficulty.hard:   return hardProgress;
    }
  }

  StageProgressState copyWithDifficulty(
      Difficulty d,
      Map<String, Map<String, int>> updated,
      ) {
    return StageProgressState(
      easyProgress:   d == Difficulty.easy   ? updated : easyProgress,
      mediumProgress: d == Difficulty.medium ? updated : mediumProgress,
      hardProgress:   d == Difficulty.hard   ? updated : hardProgress,
    );
  }
}

class StageProgressNotifier extends Notifier<StageProgressState> {
  @override
  StageProgressState build() {
    _loadAll();
    return const StageProgressState();
  }

  static const _keyEasy   = 'deen_progress_easy';
  static const _keyMedium = 'deen_progress_medium';
  static const _keyHard   = 'deen_progress_hard';

  String _keyFor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:   return _keyEasy;
      case Difficulty.medium: return _keyMedium;
      case Difficulty.hard:   return _keyHard;
    }
  }

  // ── Load saved progress from SharedPreferences ─
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, Map<String, int>> decode(String key) {
      final raw = prefs.getString(key);
      if (raw == null) return {};
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>).map(
                (ik, iv) => MapEntry(ik, iv as int),
          ),
        ));
      } catch (_) {
        return {};
      }
    }

    state = StageProgressState(
      easyProgress:   decode(_keyEasy),
      mediumProgress: decode(_keyMedium),
      hardProgress:   decode(_keyHard),
    );
  }

  // ── Save progress after completing a stage ─────
  Future<void> completeStage(Stage stage, int scorePercent) async {
    final stars = Stage.calculateStars(scorePercent);
    final current = Map<String, Map<String, int>>.from(
      state.forDifficulty(stage.difficulty),
    );

    // Only update if this is a better score
    final existing = current[stage.id];
    final existingBest = existing?['bestScore'] ?? 0;
    if (scorePercent >= existingBest) {
      current[stage.id] = {
        'stars': stars,
        'bestScore': scorePercent,
      };
    }

    final updated = state.copyWithDifficulty(stage.difficulty, current);
    state = updated;

    // Persist
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      current.map((k, v) => MapEntry(k, v)),
    );
    await prefs.setString(_keyFor(stage.difficulty), encoded);
  }

  // ── Get stages with progress applied ──────────
  List<Stage> getStages(Difficulty difficulty) {
    return QuizRepository.instance.getStagesWithProgress(
      difficulty,
      state.forDifficulty(difficulty),
    );
  }

  // ── Clear all progress (for testing) ──────────
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEasy);
    await prefs.remove(_keyMedium);
    await prefs.remove(_keyHard);
    state = const StageProgressState();
  }
}

final stageProgressProvider =
NotifierProvider<StageProgressNotifier, StageProgressState>(StageProgressNotifier.new);

/// Convenience provider — get stages for a specific difficulty
final easyStagesProvider = Provider<List<Stage>>(
      (ref) => ref.watch(stageProgressProvider.notifier).getStages(Difficulty.easy),
);

final mediumStagesProvider = Provider<List<Stage>>(
      (ref) => ref.watch(stageProgressProvider.notifier).getStages(Difficulty.medium),
);

final hardStagesProvider = Provider<List<Stage>>(
      (ref) => ref.watch(stageProgressProvider.notifier).getStages(Difficulty.hard),
);
