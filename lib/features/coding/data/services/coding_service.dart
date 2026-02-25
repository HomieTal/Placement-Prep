import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coding_problem_model.dart';

class CodingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all coding problems
  Future<List<CodingProblemModel>> getCodingProblems({
    String? difficulty,
    List<String>? tags,
    int limit = 20,
  }) async {
    Query query = _firestore.collection('coding_problems');

    if (difficulty != null && difficulty.isNotEmpty) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CodingProblemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Get coding problem by ID
  Future<CodingProblemModel?> getCodingProblemById(String id) async {
    final doc = await _firestore.collection('coding_problems').doc(id).get();

    if (!doc.exists) return null;
    return CodingProblemModel.fromMap(doc.data()!, doc.id);
  }

  // Submit code (mock execution - returns simulated results)
  Future<CodeSubmission> submitCode({
    required String problemId,
    required String userId,
    required String language,
    required String code,
    required List<TestCase> testCases,
  }) async {
    // Mock code execution
    final results = <TestCaseResult>[];
    int passedCount = 0;

    for (int i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];

      // Simulate execution - in real scenario, this would call an execution API
      final mockResult = _mockExecuteCode(code, testCase.input, testCase.expectedOutput);

      results.add(TestCaseResult(
        testCaseIndex: i,
        input: testCase.isHidden ? '(Hidden)' : testCase.input,
        expectedOutput: testCase.isHidden ? '(Hidden)' : testCase.expectedOutput,
        actualOutput: mockResult.output,
        passed: mockResult.passed,
        error: mockResult.error,
      ));

      if (mockResult.passed) passedCount++;
    }

    final status = passedCount == testCases.length
        ? SubmissionStatus.accepted
        : SubmissionStatus.wrongAnswer;

    final submission = CodeSubmission(
      id: '',
      problemId: problemId,
      userId: userId,
      language: language,
      code: code,
      status: status,
      results: results,
      passedTestCases: passedCount,
      totalTestCases: testCases.length,
      submittedAt: DateTime.now(),
    );

    // Save submission to Firestore
    final doc = await _firestore.collection('code_submissions').add(submission.toMap());

    // Update user points if all test cases passed
    if (status == SubmissionStatus.accepted) {
      await _firestore.collection('users').doc(userId).update({
        'totalPoints': FieldValue.increment(10),
        'coins': FieldValue.increment(5),
      });
    }

    return CodeSubmission(
      id: doc.id,
      problemId: submission.problemId,
      userId: submission.userId,
      language: submission.language,
      code: submission.code,
      status: submission.status,
      results: submission.results,
      passedTestCases: submission.passedTestCases,
      totalTestCases: submission.totalTestCases,
      submittedAt: submission.submittedAt,
    );
  }

  // Run code against sample test cases only
  Future<List<TestCaseResult>> runCode({
    required String code,
    required String language,
    required List<TestCase> sampleTestCases,
  }) async {
    final results = <TestCaseResult>[];

    for (int i = 0; i < sampleTestCases.length; i++) {
      final testCase = sampleTestCases[i];
      final mockResult = _mockExecuteCode(code, testCase.input, testCase.expectedOutput);

      results.add(TestCaseResult(
        testCaseIndex: i,
        input: testCase.input,
        expectedOutput: testCase.expectedOutput,
        actualOutput: mockResult.output,
        passed: mockResult.passed,
        error: mockResult.error,
      ));
    }

    return results;
  }

  // Get user's submissions for a problem
  Future<List<CodeSubmission>> getUserSubmissions(String userId, String problemId) async {
    final snapshot = await _firestore
        .collection('code_submissions')
        .where('userId', isEqualTo: userId)
        .where('problemId', isEqualTo: problemId)
        .orderBy('submittedAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => CodeSubmission.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Mock code execution (simulates running code)
  _MockExecutionResult _mockExecuteCode(String code, String input, String expectedOutput) {
    // This is a mock implementation
    // In a real scenario, this would call an external code execution API

    // Simulate some basic validation
    if (code.trim().isEmpty) {
      return _MockExecutionResult(
        output: '',
        passed: false,
        error: 'Empty code submission',
      );
    }

    // Simulate random success/failure for demonstration
    // In production, this would actually execute the code
    final hasBasicStructure = code.contains('main') ||
                              code.contains('def ') ||
                              code.contains('function');

    if (!hasBasicStructure) {
      return _MockExecutionResult(
        output: 'Syntax Error',
        passed: false,
        error: 'Code does not contain required entry point',
      );
    }

    // Mock: assume the code produces the expected output
    // This should be replaced with actual code execution
    return _MockExecutionResult(
      output: expectedOutput,
      passed: true,
      error: null,
    );
  }

  // Add coding problem (for admin)
  Future<String> addCodingProblem(CodingProblemModel problem) async {
    final doc = await _firestore.collection('coding_problems').add(problem.toMap());
    return doc.id;
  }

  // Update coding problem (for admin)
  Future<void> updateCodingProblem(CodingProblemModel problem) async {
    await _firestore.collection('coding_problems').doc(problem.id).update(problem.toMap());
  }

  // Delete coding problem (for admin)
  Future<void> deleteCodingProblem(String id) async {
    await _firestore.collection('coding_problems').doc(id).delete();
  }
}

class _MockExecutionResult {
  final String output;
  final bool passed;
  final String? error;

  _MockExecutionResult({
    required this.output,
    required this.passed,
    this.error,
  });
}

