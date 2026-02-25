import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_models.dart';
import '../../../../core/constants/app_constants.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get dashboard stats for a user
  Future<DashboardStats> getDashboardStats(String userId) async {
    try {
      // Get test attempts
      final attemptsQuery = await _firestore
          .collection(AppConstants.testAttemptsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      if (attemptsQuery.docs.isEmpty) {
        return DashboardStats();
      }

      int totalTests = attemptsQuery.docs.length;
      double totalScore = 0;
      int totalQuestions = 0;
      int correctAnswers = 0;
      Map<String, List<double>> categoryAccuracy = {};

      for (var doc in attemptsQuery.docs) {
        final data = doc.data();
        totalScore += (data['score'] ?? 0).toDouble();
        final questionsInAttempt = ((data['totalQuestions'] ?? 0) as num).toInt();
        totalQuestions += questionsInAttempt;
        final scoreValue = (data['score'] ?? 0) as num;
        correctAnswers += (scoreValue * questionsInAttempt / 100).round();

        // Track category-wise accuracy
        if (data['categoryBreakdown'] != null) {
          (data['categoryBreakdown'] as Map<String, dynamic>).forEach((category, stats) {
            if (!categoryAccuracy.containsKey(category)) {
              categoryAccuracy[category] = [];
            }
            categoryAccuracy[category]!.add((stats['accuracy'] ?? 0).toDouble());
          });
        }
      }

      // Calculate strongest and weakest categories
      String strongest = 'N/A';
      String weakest = 'N/A';
      double maxAccuracy = 0;
      double minAccuracy = 100;

      categoryAccuracy.forEach((category, accuracies) {
        double avgAccuracy = accuracies.reduce((a, b) => a + b) / accuracies.length;
        if (avgAccuracy > maxAccuracy) {
          maxAccuracy = avgAccuracy;
          strongest = category;
        }
        if (avgAccuracy < minAccuracy) {
          minAccuracy = avgAccuracy;
          weakest = category;
        }
      });

      // Get user data for streak and points
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      final userData = userDoc.data() ?? {};

      return DashboardStats(
        totalTestsTaken: totalTests,
        overallAccuracy: totalQuestions > 0 ? (correctAnswers / totalQuestions * 100) : 0,
        averageScore: totalTests > 0 ? totalScore / totalTests : 0,
        currentStreak: userData['currentStreak'] ?? 0,
        strongestCategory: strongest,
        weakestCategory: weakest,
        totalQuestionsAttempted: totalQuestions,
        correctAnswers: correctAnswers,
        totalPoints: userData['totalPoints'] ?? 0,
        coins: userData['coins'] ?? 0,
      );
    } catch (e) {
      return DashboardStats();
    }
  }

  // Get recent activities
  Future<List<RecentActivity>> getRecentActivities(String userId, {int limit = 10}) async {
    try {
      final activities = <RecentActivity>[];

      // Get recent test attempts
      final attemptsQuery = await _firestore
          .collection(AppConstants.testAttemptsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      for (var doc in attemptsQuery.docs) {
        final data = doc.data();
        activities.add(RecentActivity(
          id: doc.id,
          type: 'test',
          title: 'Mock Test Completed',
          description: 'Score: ${data['score']}%',
          timestamp: (data['date'] as Timestamp).toDate(),
          score: data['score'],
          category: data['category'],
        ));
      }

      // Sort by timestamp
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Update user stats after completing a test
  Future<void> updateUserStats({
    required String userId,
    required int pointsEarned,
    required int coinsEarned,
  }) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'totalPoints': FieldValue.increment(pointsEarned),
      'coins': FieldValue.increment(coinsEarned),
    });
  }
}

