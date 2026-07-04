import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  QuizRepository._();
  static final QuizRepository instance = QuizRepository._();

  final _db = FirebaseFirestore.instance;

  // ── Questions ──────────────────────────────────────────────────

  /// Get a single question by ID from Firestore
  Future<Question?> getQuestion(String id) async {
    final doc = await _db.collection('questions').doc(id).get();
    if (!doc.exists) return null;
    return Question.fromMap(doc.data()!, doc.id);
  }

  /// Get multiple questions by their IDs
  Future<List<Question>> getQuestionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    // Firestore 'in' query supports up to 10-30 items depending on size
    // For stages of 5-10 questions, this is perfect.
    final snapshot = await _db
        .collection('questions')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    final questions = snapshot.docs
        .map((doc) => Question.fromMap(doc.data(), doc.id))
        .toList();
        
    // Order them as requested in the 'ids' list
    return ids
        .map((id) => questions.firstWhere((q) => q.id == id))
        .toList();
  }

  /// Get all questions for a stage (ordered)
  Future<List<Question>> getQuestionsForStage(Stage stage) async {
    return getQuestionsByIds(stage.questionIds);
  }

  // ── Stages ────────────────────────────────────────────────────

  /// Get all stages for a difficulty from Firestore
  Future<List<Stage>> getStages(Difficulty difficulty) async {
    final snapshot = await _db
        .collection('stages')
        .where('difficulty', isEqualTo: difficulty.name)
        .orderBy('stageNumber')
        .get();

    return snapshot.docs
        .map((doc) => Stage.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ── Progress helpers ──────────────────────────────────────────

  /// Merge saved progress (from SharedPreferences) with Firestore stages
  Future<List<Stage>> getStagesWithProgress(
      Difficulty difficulty,
      Map<String, Map<String, int>> progressMap,
      ) async {
    final stages = await getStages(difficulty);
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
