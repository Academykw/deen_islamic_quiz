import 'package:flutter/foundation.dart';

import '../data/models/quiz_model.dart';


enum QuizStatus { idle, active, answered, complete }

@immutable
class QuizState {
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswerIndex,
    this.isAnswered = false,
    this.isCorrect = false,
    this.score = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.coinsEarned = 0,
    this.status = QuizStatus.idle,
    this.currentStage,
  });

  final List<Question> questions;
  final int currentIndex;
  final int? selectedAnswerIndex;
  final bool isAnswered;
  final bool isCorrect;
  final int score;
  final int streak;
  final int bestStreak;
  final int coinsEarned;
  final QuizStatus status;
  final Stage? currentStage;

  // ── Computed ──────────────────────────────────
  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int get totalQuestions => questions.length;

  int get scorePercent => totalQuestions == 0
      ? 0
      : ((score / totalQuestions) * 100).round();

  double get progressPercent => totalQuestions == 0
      ? 0
      : currentIndex / totalQuestions;

  bool get isPassing => scorePercent >= Stage.passingScore;

  bool get isLastQuestion => currentIndex >= totalQuestions - 1;

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? selectedAnswerIndex,
    bool clearSelectedAnswer = false,
    bool? isAnswered,
    bool? isCorrect,
    int? score,
    int? streak,
    int? bestStreak,
    int? coinsEarned,
    QuizStatus? status,
    Stage? currentStage,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswerIndex: clearSelectedAnswer
          ? null
          : selectedAnswerIndex ?? this.selectedAnswerIndex,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
    );
  }

  @override
  String toString() =>
      'QuizState(index: $currentIndex/$totalQuestions, score: $score, streak: $streak, coins: $coinsEarned, status: $status)';
}