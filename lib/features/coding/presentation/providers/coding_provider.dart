import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/coding_problem_model.dart';
import '../../data/services/coding_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Coding Service Provider
final codingServiceProvider = Provider<CodingService>((ref) {
  return CodingService();
});

// Coding Problems Provider
final codingProblemsProvider = FutureProvider<List<CodingProblemModel>>((ref) async {
  final service = ref.watch(codingServiceProvider);
  return await service.getCodingProblems();
});

// Selected Problem Provider
final selectedProblemProvider = StateProvider<CodingProblemModel?>((ref) => null);

// Selected Language Provider
final selectedLanguageProvider = StateProvider<ProgrammingLanguage>((ref) {
  return ProgrammingLanguage.supportedLanguages.first;
});

// Code Editor State
class CodeEditorState {
  final String code;
  final bool isRunning;
  final bool isSubmitting;
  final List<TestCaseResult>? runResults;
  final CodeSubmission? submission;
  final String? error;

  const CodeEditorState({
    this.code = '',
    this.isRunning = false,
    this.isSubmitting = false,
    this.runResults,
    this.submission,
    this.error,
  });

  CodeEditorState copyWith({
    String? code,
    bool? isRunning,
    bool? isSubmitting,
    List<TestCaseResult>? runResults,
    CodeSubmission? submission,
    String? error,
  }) {
    return CodeEditorState(
      code: code ?? this.code,
      isRunning: isRunning ?? this.isRunning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      runResults: runResults ?? this.runResults,
      submission: submission ?? this.submission,
      error: error ?? this.error,
    );
  }
}

// Code Editor Notifier
class CodeEditorNotifier extends StateNotifier<CodeEditorState> {
  final CodingService _service;
  final String? _userId;

  CodeEditorNotifier(this._service, this._userId) : super(const CodeEditorState());

  void setCode(String code) {
    state = state.copyWith(code: code);
  }

  void initializeCode(String? starterCode) {
    state = state.copyWith(
      code: starterCode ?? '',
      runResults: null,
      submission: null,
      error: null,
    );
  }

  Future<void> runCode(CodingProblemModel problem, String language) async {
    state = state.copyWith(isRunning: true, error: null, runResults: null);

    try {
      // Get only sample (non-hidden) test cases
      final sampleTestCases = problem.testCases.where((tc) => !tc.isHidden).toList();

      final results = await _service.runCode(
        code: state.code,
        language: language,
        sampleTestCases: sampleTestCases,
      );

      state = state.copyWith(
        isRunning: false,
        runResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> submitCode(CodingProblemModel problem, String language) async {
    if (_userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null, submission: null);

    try {
      final submission = await _service.submitCode(
        problemId: problem.id,
        userId: _userId!,
        language: language,
        code: state.code,
        testCases: problem.testCases,
      );

      state = state.copyWith(
        isSubmitting: false,
        submission: submission,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const CodeEditorState();
  }
}

// Code Editor Provider
final codeEditorProvider = StateNotifierProvider<CodeEditorNotifier, CodeEditorState>((ref) {
  final service = ref.watch(codingServiceProvider);
  final authState = ref.watch(authProvider);
  return CodeEditorNotifier(service, authState.user?.uid);
});

