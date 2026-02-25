import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../preparation/data/models/question_model.dart';
import '../../../mock_test/data/models/mock_test_model.dart';
import '../../../coding/data/models/coding_problem_model.dart';
import '../../data/services/admin_service.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// All Questions Provider
final adminQuestionsProvider = FutureProvider<List<QuestionModel>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return await service.getAllQuestions();
});

// All Mock Tests Provider
final adminMockTestsProvider = FutureProvider<List<MockTestModel>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return await service.getAllMockTests();
});

// All Coding Problems Provider
final adminCodingProblemsProvider = FutureProvider<List<CodingProblemModel>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return await service.getAllCodingProblems();
});

// Overall Stats Provider
final overallStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return await service.getOverallStats();
});

// Admin Tab Provider
enum AdminTab { dashboard, questions, mockTests, coding, users }

final selectedAdminTabProvider = StateProvider<AdminTab>((ref) => AdminTab.dashboard);

