import 'package:cloud_firestore/cloud_firestore.dart';


class DailyChallenge {
  const DailyChallenge({
    required this.date,
    required this.questionIds,
    this.isCompleted = false,
    this.score = 0,
    this.coinsEarned = 0,
    this.completedAt,
  });

  final String date; // Format: 'yyyy-MM-dd'
  final List<String> questionIds;
  final bool isCompleted;
  final int score;
  final int coinsEarned;
  final DateTime? completedAt;

  // ── Firestore serialisation ───────────────────
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'questionIds': questionIds,
      'isCompleted': isCompleted,
      'score': score,
      'coinsEarned': coinsEarned,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      date: map['date'] ?? '',
      questionIds: List<String>.from(
          map['questionIds'] ?? []),
      isCompleted: map['isCompleted'] ?? false,
      score: map['score'] ?? 0,
      coinsEarned: map['coinsEarned'] ?? 0,
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  DailyChallenge copyWith({
    bool? isCompleted,
    int? score,
    int? coinsEarned,
    DateTime? completedAt,
  }) {
    return DailyChallenge(
      date: date,
      questionIds: questionIds,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Today's date key
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}