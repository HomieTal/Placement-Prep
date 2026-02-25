import 'package:cloud_firestore/cloud_firestore.dart';

class MockTestModel {
  final String id;
  final String title;
  final String description;
  final int totalQuestions;
  final int durationMinutes;
  final List<String> categories;
  final String difficulty;
  final bool isActive;
  final DateTime createdAt;

  MockTestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.categories,
    required this.difficulty,
    this.isActive = true,
    required this.createdAt,
  });

  factory MockTestModel.fromMap(Map<String, dynamic> map, String id) {
    return MockTestModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 60,
      categories: List<String>.from(map['categories'] ?? []),
      difficulty: map['difficulty'] ?? 'Mixed',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'totalQuestions': totalQuestions,
      'durationMinutes': durationMinutes,
      'categories': categories,
      'difficulty': difficulty,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TestAttemptModel {
  final String id;
  final String testId;
  final String userId;
  final DateTime date;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final Map<String, dynamic> categoryBreakdown;
  final Map<String, dynamic> difficultyBreakdown;
  final int timeTakenSeconds;
  final Map<String, String> answers;
  final bool isCompleted;

  TestAttemptModel({
    required this.id,
    required this.testId,
    required this.userId,
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    this.categoryBreakdown = const {},
    this.difficultyBreakdown = const {},
    required this.timeTakenSeconds,
    this.answers = const {},
    this.isCompleted = false,
  });

  factory TestAttemptModel.fromMap(Map<String, dynamic> map, String id) {
    return TestAttemptModel(
      id: id,
      testId: map['testId'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      categoryBreakdown: Map<String, dynamic>.from(map['categoryBreakdown'] ?? {}),
      difficultyBreakdown: Map<String, dynamic>.from(map['difficultyBreakdown'] ?? {}),
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      answers: Map<String, String>.from(map['answers'] ?? {}),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'categoryBreakdown': categoryBreakdown,
      'difficultyBreakdown': difficultyBreakdown,
      'timeTakenSeconds': timeTakenSeconds,
      'answers': answers,
      'isCompleted': isCompleted,
    };
  }
}

