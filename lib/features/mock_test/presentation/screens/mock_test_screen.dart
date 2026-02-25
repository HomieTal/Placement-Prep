import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/mock_test_provider.dart';

class MockTestScreen extends ConsumerWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testEngineProvider);

    if (testState.isLoading) {
      return const Scaffold(
        body: Center(child: LoadingWidget(message: 'Loading test...')),
      );
    }

    if (testState.error != null) {
      return Scaffold(
        body: ErrorStateWidget(
          message: testState.error!,
          onRetry: () => context.go('/mock-tests'),
        ),
      );
    }

    if (testState.isCompleted) {
      return _buildResultScreen(context, ref, testState);
    }

    return _buildTestScreen(context, ref, testState);
  }

  Widget _buildTestScreen(BuildContext context, WidgetRef ref, TestEngineState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox();

    final selectedAnswer = state.userAnswers[question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(state.test?.title ?? 'Mock Test'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context, ref),
        ),
        actions: [
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: state.remainingSeconds < 300
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: state.remainingSeconds < 300
                      ? AppColors.error
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  state.formattedTime,
                  style: TextStyle(
                    color: state.remainingSeconds < 300
                        ? AppColors.error
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () => _showQuestionGrid(context, ref, state),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.questions.length,
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${state.currentIndex + 1} of ${state.questions.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(question.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.difficulty,
                          style: TextStyle(
                            color: _getDifficultyColor(question.difficulty),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = selectedAnswer == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          ref.read(testEngineProvider.notifier).answerQuestion(
                                question.id,
                                option,
                              );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Clear Selection
                  if (selectedAnswer != null)
                    TextButton.icon(
                      onPressed: () {
                        ref.read(testEngineProvider.notifier).clearAnswer(question.id);
                      },
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Clear Selection'),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (state.hasPrevious)
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      isOutlined: true,
                      onPressed: () {
                        ref.read(testEngineProvider.notifier).previousQuestion();
                      },
                    ),
                  ),
                if (state.hasPrevious) const SizedBox(width: 12),
                Expanded(
                  child: state.hasNext
                      ? CustomButton(
                          text: 'Next',
                          onPressed: () {
                            ref.read(testEngineProvider.notifier).nextQuestion();
                          },
                        )
                      : CustomButton(
                          text: 'Submit Test',
                          backgroundColor: AppColors.success,
                          onPressed: () => _showSubmitDialog(context, ref, state),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(BuildContext context, WidgetRef ref, TestEngineState state) {
    final isPassed = state.accuracy >= 60;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Result Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isPassed ? AppColors.success : AppColors.error).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 24),

              // Result Title
              Text(
                isPassed ? 'Congratulations!' : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have completed the mock test',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              const SizedBox(height: 32),

              // Score Card
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      '${state.accuracy.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPassed ? AppColors.success : AppColors.error,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(context, 'Correct', '${state.correctAnswers}', AppColors.success),
                        _buildStatColumn(context, 'Wrong', '${state.questions.length - state.correctAnswers - state.unansweredCount}', AppColors.error),
                        _buildStatColumn(context, 'Skipped', '${state.unansweredCount}', AppColors.warning),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Time Taken Card
              if (state.result != null)
                CustomCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.timer, color: AppColors.info),
                          ),
                          const SizedBox(width: 12),
                          const Text('Time Taken'),
                        ],
                      ),
                      Text(
                        _formatDuration(state.result!.timeTakenSeconds),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Buttons
              CustomButton(
                text: 'Review Answers',
                onPressed: () => context.push('/mock-tests/review'),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Tests',
                isOutlined: true,
                onPressed: () {
                  ref.read(testEngineProvider.notifier).reset();
                  context.go('/mock-tests');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(testEngineProvider.notifier).reset();
              context.go('/mock-tests');
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, WidgetRef ref, TestEngineState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text(
          state.unansweredCount > 0
              ? 'You have ${state.unansweredCount} unanswered questions. Are you sure you want to submit?'
              : 'Are you sure you want to submit the test?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(testEngineProvider.notifier).submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showQuestionGrid(BuildContext context, WidgetRef ref, TestEngineState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${state.answeredCount}/${state.questions.length} Answered',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.questions.length,
                  itemBuilder: (context, index) {
                    final question = state.questions[index];
                    final isAnswered = state.userAnswers.containsKey(question.id);
                    final isCurrent = index == state.currentIndex;

                    return InkWell(
                      onTap: () {
                        ref.read(testEngineProvider.notifier).goToQuestion(index);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : isAnswered
                                  ? AppColors.success.withOpacity(0.1)
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.primary
                                : isAnswered
                                    ? AppColors.success
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : isAnswered
                                      ? AppColors.success
                                      : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.easy;
      case 'Medium':
        return AppColors.medium;
      case 'Hard':
        return AppColors.hard;
      default:
        return AppColors.primary;
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes}m ${secs}s';
  }
}

