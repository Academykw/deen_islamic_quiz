import 'package:flutter/foundation.dart';

enum Difficulty { easy, medium, hard }

enum QuestionCategory {
  pillars,      // Five Pillars of Islam
  quran,        // Quran & Tafsir
  hadith,       // Hadith & Sunnah
  prophets,     // Prophets & Messengers
  history,      // Islamic History
  fiqh,         // Islamic Jurisprudence
  aqeedah,      // Islamic Creed
  morals,       // Akhlaq & Ethics
}

enum StageStatus {
  locked,
  unlocked,
  current,
  completed,
}

@immutable
class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.category,
    this.arabicText,
    this.explanation,
    this.coinReward = 10,
  }) : assert(correctIndex >= 0 && correctIndex <= 3, 'correctIndex must be 0–3');

  final String id;
  final String text;           // English question text
  final String? arabicText;    // Optional Arabic version
  final List<String> options;  // Always 4 options
  final int correctIndex;      // 0-based index of correct answer
  final Difficulty difficulty;
  final QuestionCategory category;
  final String? explanation;   // Shown after answering (Phase 2)
  final int coinReward;        // Base coins for correct answer

  String get correctAnswer => options[correctIndex];

  /// Coins adjusted by difficulty
  int get adjustedCoinReward {
    switch (difficulty) {
      case Difficulty.easy:   return coinReward;
      case Difficulty.medium: return (coinReward * 1.5).round();
      case Difficulty.hard:   return coinReward * 2;
    }
  }

  @override
  String toString() => 'Question($id: $text)';
}

@immutable
class Stage {
  const Stage({
    required this.id,
    required this.stageNumber,
    required this.difficulty,
    required this.questionIds,
    this.status = StageStatus.locked,
    this.starsEarned = 0,
    this.bestScore = 0,
  });

  static const int passingScore = 80;

  static int calculateStars(int scorePercent) {
    if (scorePercent >= 100) return 3;
    if (scorePercent >= 90) return 2;
    if (scorePercent >= 80) return 1;
    return 0;
  }

  final String id;
  final int stageNumber;
  final Difficulty difficulty;
  final List<String> questionIds;
  final StageStatus status;
  final int starsEarned;
  final int bestScore;

  bool get isUnlocked => status != StageStatus.locked;
  bool get isLocked => status == StageStatus.locked;
  bool get isCompleted => status == StageStatus.completed;

  Stage copyWith({
    String? id,
    int? stageNumber,
    Difficulty? difficulty,
    List<String>? questionIds,
    StageStatus? status,
    int? starsEarned,
    int? bestScore,
  }) {
    return Stage(
      id: id ?? this.id,
      stageNumber: stageNumber ?? this.stageNumber,
      difficulty: difficulty ?? this.difficulty,
      questionIds: questionIds ?? this.questionIds,
      status: status ?? this.status,
      starsEarned: starsEarned ?? this.starsEarned,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  @override
  String toString() => 'Stage($id: #$stageNumber)';
}
