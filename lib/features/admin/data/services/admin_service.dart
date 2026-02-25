import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../preparation/data/models/question_model.dart';
import '../../../mock_test/data/models/mock_test_model.dart';
import '../../../coding/data/models/coding_problem_model.dart';
import '../../../../core/constants/app_constants.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Questions Management
  Future<List<QuestionModel>> getAllQuestions({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.questionsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addQuestion(QuestionModel question) async {
    final doc = await _firestore
        .collection(AppConstants.questionsCollection)
        .add(question.toMap());
    return doc.id;
  }

  Future<void> updateQuestion(QuestionModel question) async {
    await _firestore
        .collection(AppConstants.questionsCollection)
        .doc(question.id)
        .update(question.toMap());
  }

  Future<void> deleteQuestion(String id) async {
    await _firestore
        .collection(AppConstants.questionsCollection)
        .doc(id)
        .delete();
  }

  // Mock Tests Management
  Future<List<MockTestModel>> getAllMockTests() async {
    final snapshot = await _firestore
        .collection(AppConstants.mockTestsCollection)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MockTestModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addMockTest(MockTestModel test) async {
    final doc = await _firestore
        .collection(AppConstants.mockTestsCollection)
        .add(test.toMap());
    return doc.id;
  }

  Future<void> updateMockTest(MockTestModel test) async {
    await _firestore
        .collection(AppConstants.mockTestsCollection)
        .doc(test.id)
        .update(test.toMap());
  }

  Future<void> deleteMockTest(String id) async {
    await _firestore
        .collection(AppConstants.mockTestsCollection)
        .doc(id)
        .delete();
  }

  // Coding Problems Management
  Future<List<CodingProblemModel>> getAllCodingProblems() async {
    final snapshot = await _firestore
        .collection('coding_problems')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CodingProblemModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> addCodingProblem(CodingProblemModel problem) async {
    final doc = await _firestore
        .collection('coding_problems')
        .add(problem.toMap());
    return doc.id;
  }

  Future<void> updateCodingProblem(CodingProblemModel problem) async {
    await _firestore
        .collection('coding_problems')
        .doc(problem.id)
        .update(problem.toMap());
  }

  Future<void> deleteCodingProblem(String id) async {
    await _firestore.collection('coding_problems').doc(id).delete();
  }

  // User Analytics
  Future<Map<String, dynamic>> getOverallStats() async {
    final usersCount = await _firestore
        .collection(AppConstants.usersCollection)
        .count()
        .get();

    final questionsCount = await _firestore
        .collection(AppConstants.questionsCollection)
        .count()
        .get();

    final attemptsCount = await _firestore
        .collection(AppConstants.testAttemptsCollection)
        .count()
        .get();

    final testsCount = await _firestore
        .collection(AppConstants.mockTestsCollection)
        .count()
        .get();

    return {
      'totalUsers': usersCount.count,
      'totalQuestions': questionsCount.count,
      'totalAttempts': attemptsCount.count,
      'totalTests': testsCount.count,
    };
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 20}) async {
    final activities = <Map<String, dynamic>>[];

    // Get recent test attempts
    final attempts = await _firestore
        .collection(AppConstants.testAttemptsCollection)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    for (var doc in attempts.docs) {
      final data = doc.data();
      activities.add({
        'type': 'test_attempt',
        'userId': data['userId'],
        'score': data['score'],
        'date': data['date'],
      });
    }

    return activities;
  }
}

