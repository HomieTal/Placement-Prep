import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';
import '../../../../core/constants/app_constants.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get global leaderboard
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap(
        entry.value.data(),
        entry.value.id,
        entry.key + 1,
      );
    }).toList();
  }

  // Get college-wise leaderboard
  Future<List<LeaderboardEntry>> getCollegeLeaderboard(String college, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('college', isEqualTo: college)
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      return LeaderboardEntry.fromMap(
        entry.value.data(),
        entry.value.id,
        entry.key + 1,
      );
    }).toList();
  }

  // Get user's rank
  Future<int> getUserRank(String userId) async {
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (!userDoc.exists) return 0;

    final userPoints = userDoc.data()?['totalPoints'] ?? 0;

    final higherRanked = await _firestore
        .collection(AppConstants.usersCollection)
        .where('totalPoints', isGreaterThan: userPoints)
        .count()
        .get();

    return higherRanked.count! + 1;
  }

  // Award badge to user
  Future<void> awardBadge(String userId, String badgeId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'badges': FieldValue.arrayUnion([badgeId]),
    });
  }

  // Add points to user
  Future<void> addPoints(String userId, int points) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'totalPoints': FieldValue.increment(points),
    });
  }

  // Add coins to user
  Future<void> addCoins(String userId, int coins) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'coins': FieldValue.increment(coins),
    });
  }
}

