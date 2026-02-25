import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../../../../core/constants/app_constants.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get questions by category
  Future<List<QuestionModel>> getQuestionsByCategory(
    String category, {
    String? difficulty,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(AppConstants.questionsCollection)
        .where('category', isEqualTo: category);

    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get questions by topic
  Future<List<QuestionModel>> getQuestionsByTopic(
    String topic, {
    String? difficulty,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(AppConstants.questionsCollection)
        .where('metadata.topic', isEqualTo: topic);

    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get random questions for practice
  Future<List<QuestionModel>> getRandomQuestions({
    String? category,
    String? difficulty,
    int count = 10,
  }) async {
    Query query = _firestore.collection(AppConstants.questionsCollection);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    // Get more questions and randomly select
    final snapshot = await query.limit(count * 3).get();
    final questions = snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    questions.shuffle();
    return questions.take(count).toList();
  }

  // Get single question by ID
  Future<QuestionModel?> getQuestionById(String id) async {
    final doc = await _firestore
        .collection(AppConstants.questionsCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return QuestionModel.fromMap(doc.data()!, doc.id);
  }

  // Add new question (for admin)
  Future<String> addQuestion(QuestionModel question) async {
    final doc = await _firestore
        .collection(AppConstants.questionsCollection)
        .add(question.toMap());
    return doc.id;
  }

  // Update question (for admin)
  Future<void> updateQuestion(QuestionModel question) async {
    await _firestore
        .collection(AppConstants.questionsCollection)
        .doc(question.id)
        .update(question.toMap());
  }

  // Delete question (for admin)
  Future<void> deleteQuestion(String id) async {
    await _firestore
        .collection(AppConstants.questionsCollection)
        .doc(id)
        .delete();
  }

  // Get all categories with question counts
  Future<Map<String, int>> getCategoryCounts() async {
    final snapshot = await _firestore
        .collection(AppConstants.questionsCollection)
        .get();

    final counts = <String, int>{};
    for (var doc in snapshot.docs) {
      final category = doc.data()['category'] as String?;
      if (category != null) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
    }
    return counts;
  }

  // Save practice session result
  Future<void> savePracticeResult({
    required String userId,
    required String category,
    required int score,
    required int totalQuestions,
    required Map<String, String> answers,
    String? difficulty,
  }) async {
    await _firestore.collection('practice_results').add({
      'userId': userId,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': totalQuestions > 0 ? (score / totalQuestions * 100) : 0,
      'difficulty': difficulty,
      'answers': answers,
      'completedAt': Timestamp.now(),
    });

    // Update user stats
    await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
      'totalPoints': FieldValue.increment(score * 10),
      'coins': FieldValue.increment(score),
    });
  }
}

