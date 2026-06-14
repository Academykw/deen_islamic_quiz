import 'package:flutter/foundation.dart';

import '../data/models/quiz_model.dart';

import '../data/models/lifeline.dart';

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

    this.lifelines = const [
      Lifeline(type: LifelineType.fiftyFifty, isUsed: false),
      Lifeline(type: LifelineType.askFriend,  isUsed: false),
      Lifeline(type: LifelineType.extraTime,  isUsed: false),
    ],
    this.eliminatedIndices = const [],
    this.friendHint,
    this.friendConfidence = 0,
    this.showComboBurst = false,
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

  // ── Lifeline state ─────────────────────────────
  final List<Lifeline> lifelines;
  final List<int> eliminatedIndices; // indices hidden by 50/50
  final String? friendHint;          // hint text from Ask Friend
  final int friendConfidence;        // 0–100 confidence %
  final bool showComboBurst;

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

  Lifeline lifelineOf(LifelineType type) {
    return lifelines.firstWhere((l) => l.type == type);
  }

  bool isEliminatedIndex(int index) => eliminatedIndices.contains(index);

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
    List<Lifeline>? lifelines,
    List<int>? eliminatedIndices,
    String? friendHint,
    bool clearFriendHint = false,
    int? friendConfidence,
    bool? showComboBurst,
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
      lifelines: lifelines ?? this.lifelines,
      eliminatedIndices:
      eliminatedIndices ?? this.eliminatedIndices,
      friendHint: clearFriendHint
          ? null
          : friendHint ?? this.friendHint,
      friendConfidence:
      friendConfidence ?? this.friendConfidence,
      showComboBurst: showComboBurst ?? this.showComboBurst,
    );
  }

  /*@override
  String toString() =>
      'QuizState(index: $currentIndex/$totalQuestions, score: $score, streak: $streak, coins: $coinsEarned, status: $status)';*/
}