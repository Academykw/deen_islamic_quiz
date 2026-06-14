import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository._();
  static final LeaderboardRepository instance = LeaderboardRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('totalCoins', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap(
        entry.value.data(),
        entry.key + 1,
      );
    }).toList();
  }

  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    // This would typically involve a 'weeklyCoins' field that resets
    // For now, falling back to global for demonstration
    return getGlobalLeaderboard();
  }

  Future<List<LeaderboardEntry>> getCountryLeaderboard(String country) async {
    final snapshot = await _firestore
        .collection('users')
        .where('country', isEqualTo: country)
        .orderBy('totalCoins', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap(
        entry.value.data(),
        entry.key + 1,
      );
    }).toList();
  }

  Future<int> getUserRank(String uid) async {
    // A more efficient way would be using a Cloud Function or keeping rank in user doc
    // For a small scale app, we can just find the user's position
    final snapshot = await _firestore
        .collection('users')
        .orderBy('totalCoins', descending: true)
        .get();

    final docs = snapshot.docs;
    for (int i = 0; i < docs.length; i++) {
      if (docs[i].id == uid) return i + 1;
    }
    return 0;
  }
}
