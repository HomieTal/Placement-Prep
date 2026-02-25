import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/preparation_provider.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String? selectedDifficulty;
  bool showExplanation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  void _loadQuestions() {
    final category = ref.read(selectedCategoryProvider);
    if (category != null) {
      ref.read(practiceProvider.notifier).loadQuestions(
            category: category,
            difficulty: selectedDifficulty,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceProvider);
    final category = ref.watch(selectedCategoryProvider);

    if (practiceState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(category ?? 'Practice')),
        body: const Center(child: LoadingWidget(message: 'Loading questions...')),
      );
    }

    if (practiceState.error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(category ?? 'Practice')),
        body: ErrorStateWidget(
          message: practiceState.error!,
          onRetry: _loadQuestions,
        ),
      );
    }

    if (practiceState.isCompleted) {
      return _buildResultScreen(practiceState);
    }

    if (practiceState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(category ?? 'Practice')),
        body: _buildDifficultySelector(),
      );
    }

    return _buildQuestionScreen(practiceState, category);
  }

  Widget _buildDifficultySelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Difficulty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred difficulty level',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          const SizedBox(height: 32),
          ...AppConstants.difficultyLevels.map((difficulty) {
            final isSelected = selectedDifficulty == difficulty;
            final color = _getDifficultyColor(difficulty);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                onTap: () {
                  setState(() {
                    selectedDifficulty = difficulty;
                  });
                },
                border: isSelected
                    ? Border.all(color: color, width: 2)
                    : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getDifficultyIcon(difficulty),
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            _getDifficultyDescription(difficulty),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: color),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          CustomButton(
            text: 'Start Practice',
            onPressed: _loadQuestions,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen(PracticeState state, String? category) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox();

    final selectedAnswer = state.userAnswers[question.id];

    return Scaffold(
      appBar: AppBar(
        title: Text(category ?? 'Practice'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitDialog();
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${state.currentIndex + 1}/${state.questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.questions.length,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(question.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(question.difficulty),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
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
                    final isCorrect = option == question.correctAnswer;
                    final showResult = showExplanation && selectedAnswer != null;

                    Color? borderColor;
                    Color? bgColor;

                    if (showResult) {
                      if (isCorrect) {
                        borderColor = AppColors.success;
                        bgColor = AppColors.success.withOpacity(0.1);
                      } else if (isSelected && !isCorrect) {
                        borderColor = AppColors.error;
                        bgColor = AppColors.error.withOpacity(0.1);
                      }
                    } else if (isSelected) {
                      borderColor = AppColors.primary;
                      bgColor = AppColors.primary.withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: showExplanation
                            ? null
                            : () {
                                ref
                                    .read(practiceProvider.notifier)
                                    .answerQuestion(question.id, option);
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor ?? Colors.grey.shade300,
                              width: isSelected || (showResult && isCorrect) ? 2 : 1,
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
                              if (showResult && isCorrect)
                                const Icon(Icons.check_circle, color: AppColors.success),
                              if (showResult && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: AppColors.error),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation
                  if (showExplanation && question.explanation.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    CustomCard(
                      color: AppColors.info.withOpacity(0.1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: AppColors.info),
                              const SizedBox(width: 8),
                              Text(
                                'Explanation',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        setState(() {
                          showExplanation = false;
                        });
                        ref.read(practiceProvider.notifier).previousQuestion();
                      },
                    ),
                  ),
                if (state.hasPrevious) const SizedBox(width: 12),
                Expanded(
                  child: selectedAnswer == null
                      ? CustomButton(
                          text: 'Skip',
                          isOutlined: true,
                          onPressed: () {
                            if (state.hasNext) {
                              ref.read(practiceProvider.notifier).nextQuestion();
                            } else {
                              _submitPractice();
                            }
                          },
                        )
                      : showExplanation
                          ? CustomButton(
                              text: state.hasNext ? 'Next' : 'Finish',
                              onPressed: () {
                                setState(() {
                                  showExplanation = false;
                                });
                                if (state.hasNext) {
                                  ref.read(practiceProvider.notifier).nextQuestion();
                                } else {
                                  _submitPractice();
                                }
                              },
                            )
                          : CustomButton(
                              text: 'Check Answer',
                              onPressed: () {
                                setState(() {
                                  showExplanation = true;
                                });
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(PracticeState state) {
    final percentage = state.accuracy;
    final isPassed = percentage >= 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Result Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (isPassed ? AppColors.success : AppColors.error)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(height: 32),

              // Result Title
              Text(
                isPassed ? 'Great Job!' : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have completed the practice session',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              const SizedBox(height: 48),

              // Score Card
              CustomCard(
                child: Column(
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPassed ? AppColors.success : AppColors.error,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Correct',
                          '${state.correctAnswers}',
                          AppColors.success,
                        ),
                        _buildStatItem(
                          'Wrong',
                          '${state.questions.length - state.correctAnswers}',
                          AppColors.error,
                        ),
                        _buildStatItem(
                          'Total',
                          '${state.questions.length}',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Buttons
              CustomButton(
                text: 'Practice Again',
                onPressed: () {
                  ref.read(practiceProvider.notifier).reset();
                  _loadQuestions();
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Categories',
                isOutlined: true,
                onPressed: () {
                  ref.read(practiceProvider.notifier).reset();
                  context.go('/preparation');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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

  void _submitPractice() {
    final category = ref.read(selectedCategoryProvider);
    ref.read(practiceProvider.notifier).submitPractice(
          category ?? '',
          selectedDifficulty,
        );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(practiceProvider.notifier).reset();
              context.go('/preparation');
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
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

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Icons.sentiment_satisfied;
      case 'Medium':
        return Icons.sentiment_neutral;
      case 'Hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 'Beginner friendly questions';
      case 'Medium':
        return 'Moderate level questions';
      case 'Hard':
        return 'Advanced challenging questions';
      default:
        return '';
    }
  }
}

