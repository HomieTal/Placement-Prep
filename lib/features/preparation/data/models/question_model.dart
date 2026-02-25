import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String category;
  final String difficulty;
  final DateTime createdAt;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    this.imageUrl,
    this.metadata,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      id: id,
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    String? category,
    String? difficulty,
    DateTime? createdAt,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  bool isCorrect(String answer) => answer == correctAnswer;
}

class TopicModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? notes;
  final int totalQuestions;
  final String? iconUrl;

  TopicModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.notes,
    this.totalQuestions = 0,
    this.iconUrl,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map, String id) {
    return TopicModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      notes: map['notes'],
      totalQuestions: map['totalQuestions'] ?? 0,
      iconUrl: map['iconUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'notes': notes,
      'totalQuestions': totalQuestions,
      'iconUrl': iconUrl,
    };
  }
}

class PracticeSession {
  final String id;
  final String userId;
  final String category;
  final String? topic;
  final String difficulty;
  final List<QuestionModel> questions;
  final Map<String, String> userAnswers;
  final int score;
  final int totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;

  PracticeSession({
    required this.id,
    required this.userId,
    required this.category,
    this.topic,
    required this.difficulty,
    required this.questions,
    this.userAnswers = const {},
    this.score = 0,
    required this.totalQuestions,
    required this.startedAt,
    this.completedAt,
  });

  double get accuracy => totalQuestions > 0 ? (score / totalQuestions * 100) : 0;

  int get correctAnswers {
    int correct = 0;
    for (var question in questions) {
      if (userAnswers[question.id] == question.correctAnswer) {
        correct++;
      }
    }
    return correct;
  }
}

