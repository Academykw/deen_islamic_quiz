import '../local/question_seed.dart';

import '../models/quiz_model.dart';


import '../models/stages_seed.dart';

class QuizRepository {
  QuizRepository._();
  static final QuizRepository instance = QuizRepository._();

  // ── Questions ──────────────────────────────────────────────────

  /// All questions as a lookup map
  late final Map<String, Question> _questionMap = {
    for (final q in kSeedQuestions) q.id: q,
  };

  /// Get a single question by ID
  Question? getQuestion(String id) => _questionMap[id];

  /// Get all questions for a stage (ordered)
  List<Question> getQuestionsForStage(Stage stage) {
    return stage.questionIds
        .map((id) => _questionMap[id])
        .whereType<Question>()
        .toList();
  }

  /// Get questions filtered by difficulty
  List<Question> getQuestionsByDifficulty(Difficulty difficulty) {
    return kSeedQuestions
        .where((q) => q.difficulty == difficulty)
        .toList();
  }

  /// Get 10 random questions for daily challenge
  List<Question> getDailyChallengeQuestions() {
    final all = List<Question>.from(kSeedQuestions)..shuffle();
    return all.take(10).toList();
  }

  // ── Stages ────────────────────────────────────────────────────

  /// Get all stages for a difficulty
  List<Stage> getStages(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:   return kEasyStages;
      case Difficulty.medium: return kMediumStages;
      case Difficulty.hard:   return kHardStages;
    }
  }

  /// Get a specific stage
  Stage? getStage(Difficulty difficulty, int stageNumber) {
    return getStages(difficulty)
        .where((s) => s.stageNumber == stageNumber)
        .firstOrNull;
  }

  // ── Progress helpers ──────────────────────────────────────────

  /// Merge saved progress (from SharedPreferences) with seed stages
  /// progressMap: { 'easy_s1': {'stars': 3, 'bestScore': 95}, ... }
  List<Stage> getStagesWithProgress(
      Difficulty difficulty,
      Map<String, Map<String, int>> progressMap,
      ) {
    final stages = getStages(difficulty);
    final result = <Stage>[];

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final saved = progressMap[stage.id];

      if (saved != null) {
        // Has saved progress — completed
        result.add(stage.copyWith(
          status: StageStatus.completed,
          starsEarned: saved['stars'] ?? 0,
          bestScore: saved['bestScore'] ?? 0,
        ));
      } else if (i == 0 || result[i - 1].isCompleted) {
        // First stage OR previous stage completed — unlock as current
        result.add(stage.copyWith(status: StageStatus.current));
      } else {
        // Still locked
        result.add(stage.copyWith(status: StageStatus.locked));
      }
    }

    return result;
  }
}