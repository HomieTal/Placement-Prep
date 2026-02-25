import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analytics_model.dart';
import '../../../../core/constants/app_constants.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get comprehensive analytics for a user
  Future<AnalyticsModel> getUserAnalytics(String userId) async {
    try {
      // Get test attempts
      final attemptsQuery = await _firestore
          .collection(AppConstants.testAttemptsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      // Get practice results
      final practiceQuery = await _firestore
          .collection('practice_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      // Calculate performance history
      final performanceHistory = <PerformanceData>[];
      final categoryStats = <String, CategoryStats>{};
      final difficultyStats = <String, DifficultyStats>{};

      double totalAccuracy = 0;
      double totalScore = 0;
      int totalAttempts = 0;

      // Process test attempts
      for (var doc in attemptsQuery.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final accuracy = (data['accuracy'] ?? 0).toDouble();

        performanceHistory.add(PerformanceData(
          date: date,
          score: accuracy,
          category: 'Mock Test',
          type: 'test',
        ));

        totalAccuracy += accuracy;
        totalScore += (data['score'] ?? 0).toDouble();
        totalAttempts++;

        // Process category breakdown
        if (data['categoryBreakdown'] != null) {
          (data['categoryBreakdown'] as Map<String, dynamic>).forEach((category, stats) {
            if (!categoryStats.containsKey(category)) {
              categoryStats[category] = CategoryStats(
                category: category,
                totalAttempts: 0,
                correctAnswers: 0,
                accuracy: 0,
                scores: [],
              );
            }

            final current = categoryStats[category]!;
            final newScores = List<double>.from(current.scores)..add((stats['accuracy'] ?? 0).toDouble());

            categoryStats[category] = CategoryStats(
              category: category,
              totalAttempts: current.totalAttempts + (stats['total'] ?? 0) as int,
              correctAnswers: current.correctAnswers + (stats['correct'] ?? 0) as int,
              accuracy: newScores.reduce((a, b) => a + b) / newScores.length,
              scores: newScores,
            );
          });
        }

        // Process difficulty breakdown
        if (data['difficultyBreakdown'] != null) {
          (data['difficultyBreakdown'] as Map<String, dynamic>).forEach((difficulty, stats) {
            if (!difficultyStats.containsKey(difficulty)) {
              difficultyStats[difficulty] = DifficultyStats(
                difficulty: difficulty,
                totalAttempts: 0,
                correctAnswers: 0,
                accuracy: 0,
              );
            }

            final current = difficultyStats[difficulty]!;
            final newTotal = current.totalAttempts + (stats['total'] ?? 0) as int;
            final newCorrect = current.correctAnswers + (stats['correct'] ?? 0) as int;

            difficultyStats[difficulty] = DifficultyStats(
              difficulty: difficulty,
              totalAttempts: newTotal,
              correctAnswers: newCorrect,
              accuracy: newTotal > 0 ? (newCorrect / newTotal * 100) : 0,
            );
          });
        }
      }

      // Process practice results
      for (var doc in practiceQuery.docs) {
        final data = doc.data();
        final date = (data['completedAt'] as Timestamp).toDate();
        final accuracy = (data['accuracy'] ?? 0).toDouble();
        final category = data['category'] ?? 'Practice';

        performanceHistory.add(PerformanceData(
          date: date,
          score: accuracy,
          category: category,
          type: 'practice',
        ));

        if (!categoryStats.containsKey(category)) {
          categoryStats[category] = CategoryStats(
            category: category,
            totalAttempts: 0,
            correctAnswers: 0,
            accuracy: 0,
            scores: [],
          );
        }

        final current = categoryStats[category]!;
        final newScores = List<double>.from(current.scores)..add(accuracy);

        categoryStats[category] = CategoryStats(
          category: category,
          totalAttempts: current.totalAttempts + (data['totalQuestions'] ?? 0) as int,
          correctAnswers: current.correctAnswers + (data['score'] ?? 0) as int,
          accuracy: newScores.reduce((a, b) => a + b) / newScores.length,
          scores: newScores,
        );
      }

      // Sort performance history
      performanceHistory.sort((a, b) => a.date.compareTo(b.date));

      // Calculate strongest and weakest categories
      String strongest = 'N/A';
      String weakest = 'N/A';
      double maxAccuracy = 0;
      double minAccuracy = 100;

      categoryStats.forEach((category, stats) {
        if (stats.accuracy > maxAccuracy) {
          maxAccuracy = stats.accuracy;
          strongest = category;
        }
        if (stats.accuracy < minAccuracy && stats.totalAttempts > 0) {
          minAccuracy = stats.accuracy;
          weakest = category;
        }
      });

      // Calculate improvement trend
      double improvementTrend = 0;
      if (performanceHistory.length >= 2) {
        final recent = performanceHistory.sublist(
          performanceHistory.length > 5 ? performanceHistory.length - 5 : 0,
        );
        final older = performanceHistory.sublist(
          0,
          performanceHistory.length > 10 ? 5 : performanceHistory.length ~/ 2,
        );

        if (recent.isNotEmpty && older.isNotEmpty) {
          final recentAvg = recent.map((e) => e.score).reduce((a, b) => a + b) / recent.length;
          final olderAvg = older.map((e) => e.score).reduce((a, b) => a + b) / older.length;
          improvementTrend = recentAvg - olderAvg;
        }
      }

      // Get weekly activity
      final weeklyActivity = await _getWeeklyActivity(userId);

      return AnalyticsModel(
        userId: userId,
        performanceHistory: performanceHistory,
        categoryStats: categoryStats,
        difficultyStats: difficultyStats,
        weeklyActivity: weeklyActivity,
        overallAccuracy: totalAttempts > 0 ? totalAccuracy / totalAttempts : 0,
        averageScore: totalAttempts > 0 ? totalScore / totalAttempts : 0,
        strongestCategory: strongest,
        weakestCategory: weakest,
        improvementTrend: improvementTrend,
      );
    } catch (e) {
      return AnalyticsModel(userId: userId);
    }
  }

  // Get weekly activity data
  Future<List<WeeklyActivity>> _getWeeklyActivity(String userId) async {
    final weeklyActivity = <WeeklyActivity>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Count test attempts for this day
      final testsQuery = await _firestore
          .collection(AppConstants.testAttemptsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Count practice sessions for this day
      final practiceQuery = await _firestore
          .collection('practice_results')
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('completedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      int questionsAttempted = 0;
      for (var doc in practiceQuery.docs) {
        questionsAttempted += (doc.data()['totalQuestions'] ?? 0) as int;
      }
      for (var doc in testsQuery.docs) {
        questionsAttempted += (doc.data()['totalQuestions'] ?? 0) as int;
      }

      weeklyActivity.add(WeeklyActivity(
        date: startOfDay,
        questionsAttempted: questionsAttempted,
        testsCompleted: testsQuery.docs.length,
        codingProblems: 0, // Would need to query code submissions
        studyMinutes: questionsAttempted * 2, // Estimate
      ));
    }

    return weeklyActivity;
  }

  // Get rank data
  Future<RankData> getRankData(String userId) async {
    try {
      final leaderboardQuery = await _firestore
          .collection(AppConstants.leaderboardCollection)
          .orderBy('totalPoints', descending: true)
          .get();

      int currentRank = 0;
      for (int i = 0; i < leaderboardQuery.docs.length; i++) {
        if (leaderboardQuery.docs[i].id == userId) {
          currentRank = i + 1;
          break;
        }
      }

      return RankData(
        currentRank: currentRank,
        previousRank: currentRank + 2, // Mock data
        totalUsers: leaderboardQuery.docs.length,
        rankHistory: [],
      );
    } catch (e) {
      return RankData();
    }
  }
}

