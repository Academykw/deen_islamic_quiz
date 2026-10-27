import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository._();
  static final LeaderboardRepository instance = LeaderboardRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .orderBy('totalCoins', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap({
        ...entry.value.data(),
        'uid': entry.value.id,
      }, entry.key + 1);
    }).toList();
  }

  Future<List<LeaderboardEntry>> getCountryLeaderboard(String country) async {
    final snapshot = await _firestore
        .collection('leaderboards')
        .where('country', isEqualTo: country)
        .orderBy('totalCoins', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap({
        ...entry.value.data(),
        'uid': entry.value.id,
      }, entry.key + 1);
    }).toList();
  }
}
