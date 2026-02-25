import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mock_test_model.dart';
import '../../data/services/mock_test_service.dart';
import '../../../preparation/data/models/question_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Mock Test Service Provider
final mockTestServiceProvider = Provider<MockTestService>((ref) {
  return MockTestService();
});

// Available Tests Provider
final availableTestsProvider = FutureProvider<List<MockTestModel>>((ref) async {
  final service = ref.watch(mockTestServiceProvider);
  return await service.getMockTests();
});

// Selected Test Provider
final selectedTestProvider = StateProvider<MockTestModel?>((ref) => null);

// Test Engine State
class TestEngineState {
  final MockTestModel? test;
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, String> userAnswers;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;
  final bool isLoading;
  final String? error;
  final TestAttemptModel? result;

  const TestEngineState({
    this.test,
    this.questions = const [],
    this.currentIndex = 0,
    this.userAnswers = const {},
    this.remainingSeconds = 0,
    this.isRunning = false,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
    this.result,
  });

  TestEngineState copyWith({
    MockTestModel? test,
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, String>? userAnswers,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    TestAttemptModel? result,
  }) {
    return TestEngineState(
      test: test ?? this.test,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      result: result ?? this.result,
    );
  }

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  bool get hasNext => currentIndex < questions.length - 1;
  bool get hasPrevious => currentIndex > 0;

  int get answeredCount => userAnswers.length;
  int get unansweredCount => questions.length - userAnswers.length;

  int get correctAnswers {
    int count = 0;
    for (var question in questions) {
      if (userAnswers[question.id] == question.correctAnswer) {
        count++;
      }
    }
    return count;
  }

  double get accuracy =>
      questions.isNotEmpty ? (correctAnswers / questions.length * 100) : 0;

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Test Engine Notifier
class TestEngineNotifier extends StateNotifier<TestEngineState> {
  final MockTestService _service;
  final String? _userId;
  Timer? _timer;

  TestEngineNotifier(this._service, this._userId) : super(const TestEngineState());

  Future<void> startTest(MockTestModel test) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final questions = await _service.getTestQuestions(test);

      state = state.copyWith(
        test: test,
        questions: questions,
        currentIndex: 0,
        userAnswers: {},
        remainingSeconds: test.durationMinutes * 60,
        isRunning: true,
        isCompleted: false,
        isLoading: false,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0) {
        submitTest();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void pauseTest() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resumeTest() {
    state = state.copyWith(isRunning: true);
    _startTimer();
  }

  void answerQuestion(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(state.userAnswers);
    newAnswers[questionId] = answer;
    state = state.copyWith(userAnswers: newAnswers);
  }

  void clearAnswer(String questionId) {
    final newAnswers = Map<String, String>.from(state.userAnswers);
    newAnswers.remove(questionId);
    state = state.copyWith(userAnswers: newAnswers);
  }

  void nextQuestion() {
    if (state.hasNext) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.hasPrevious) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  Future<void> submitTest() async {
    if (_userId == null || state.test == null) return;

    _timer?.cancel();
    state = state.copyWith(isRunning: false, isLoading: true);

    try {
      final timeTaken = (state.test!.durationMinutes * 60) - state.remainingSeconds;

      final categoryBreakdown = _service.calculateCategoryBreakdown(
        state.questions,
        state.userAnswers,
      );

      final difficultyBreakdown = _service.calculateDifficultyBreakdown(
        state.questions,
        state.userAnswers,
      );

      final attempt = TestAttemptModel(
        id: '',
        testId: state.test!.id,
        userId: _userId!,
        date: DateTime.now(),
        score: state.correctAnswers,
        totalQuestions: state.questions.length,
        accuracy: state.accuracy,
        categoryBreakdown: categoryBreakdown,
        difficultyBreakdown: difficultyBreakdown,
        timeTakenSeconds: timeTaken,
        answers: state.userAnswers,
        isCompleted: true,
      );

      await _service.saveTestAttempt(attempt);

      state = state.copyWith(
        isCompleted: true,
        isLoading: false,
        result: attempt,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    _timer?.cancel();
    state = const TestEngineState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Test Engine Provider
final testEngineProvider = StateNotifierProvider<TestEngineNotifier, TestEngineState>((ref) {
  final service = ref.watch(mockTestServiceProvider);
  final authState = ref.watch(authProvider);
  return TestEngineNotifier(service, authState.user?.uid);
});

// User Test History Provider
final userTestHistoryProvider = FutureProvider<List<TestAttemptModel>>((ref) async {
  final service = ref.watch(mockTestServiceProvider);
  final authState = ref.watch(authProvider);

  if (authState.user == null) return [];
  return await service.getUserAttempts(authState.user!.uid);
});

