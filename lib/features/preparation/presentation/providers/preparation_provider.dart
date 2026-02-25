import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/question_model.dart';
import '../../data/services/question_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Question Service Provider
final questionServiceProvider = Provider<QuestionService>((ref) {
  return QuestionService();
});

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Selected Difficulty Provider
final selectedDifficultyProvider = StateProvider<String?>((ref) => null);

// Questions Provider
final questionsProvider = FutureProvider.family<List<QuestionModel>, String>((ref, category) async {
  final service = ref.watch(questionServiceProvider);
  final difficulty = ref.watch(selectedDifficultyProvider);
  return await service.getQuestionsByCategory(category, difficulty: difficulty);
});

// Practice State
class PracticeState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final Map<String, String> userAnswers;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const PracticeState({
    this.questions = const [],
    this.currentIndex = 0,
    this.userAnswers = const {},
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  PracticeState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    Map<String, String>? userAnswers,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return PracticeState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  QuestionModel? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  bool get hasNext => currentIndex < questions.length - 1;
  bool get hasPrevious => currentIndex > 0;

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
}

// Practice Notifier
class PracticeNotifier extends StateNotifier<PracticeState> {
  final QuestionService _service;
  final String? _userId;

  PracticeNotifier(this._service, this._userId) : super(const PracticeState());

  Future<void> loadQuestions({
    required String category,
    String? difficulty,
    int count = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final questions = await _service.getRandomQuestions(
        category: category,
        difficulty: difficulty,
        count: count,
      );

      state = state.copyWith(
        questions: questions,
        currentIndex: 0,
        userAnswers: {},
        isCompleted: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void answerQuestion(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(state.userAnswers);
    newAnswers[questionId] = answer;
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

  Future<void> submitPractice(String category, String? difficulty) async {
    if (_userId == null) return;

    state = state.copyWith(isCompleted: true);

    try {
      await _service.savePracticeResult(
        userId: _userId!,
        category: category,
        score: state.correctAnswers,
        totalQuestions: state.questions.length,
        answers: state.userAnswers,
        difficulty: difficulty,
      );
    } catch (e) {
      // Handle error silently or show notification
    }
  }

  void reset() {
    state = const PracticeState();
  }
}

// Practice Provider
final practiceProvider = StateNotifierProvider<PracticeNotifier, PracticeState>((ref) {
  final service = ref.watch(questionServiceProvider);
  final authState = ref.watch(authProvider);
  return PracticeNotifier(service, authState.user?.uid);
});

// Category Counts Provider
final categoryCounts = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(questionServiceProvider);
  return await service.getCategoryCounts();
});

