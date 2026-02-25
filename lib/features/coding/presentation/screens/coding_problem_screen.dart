import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/coding_problem_model.dart';
import '../providers/coding_provider.dart';

class CodingProblemScreen extends ConsumerStatefulWidget {
  const CodingProblemScreen({super.key});

  @override
  ConsumerState<CodingProblemScreen> createState() => _CodingProblemScreenState();
}

class _CodingProblemScreenState extends ConsumerState<CodingProblemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final problem = ref.read(selectedProblemProvider);
      final language = ref.read(selectedLanguageProvider);

      if (problem != null) {
        final starterCode = problem.starterCode?[language.id] ?? language.defaultCode ?? '';
        _codeController.text = starterCode;
        ref.read(codeEditorProvider.notifier).initializeCode(starterCode);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final problem = ref.watch(selectedProblemProvider);
    final editorState = ref.watch(codeEditorProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);

    if (problem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Coding Problem')),
        body: const EmptyStateWidget(
          icon: Icons.code_off,
          title: 'No Problem Selected',
          subtitle: 'Please select a problem from the list',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(problem.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(codeEditorProvider.notifier).reset();
            context.go('/coding');
          },
        ),
        actions: [
          // Language Selector
          PopupMenuButton<ProgrammingLanguage>(
            initialValue: selectedLanguage,
            onSelected: (language) {
              ref.read(selectedLanguageProvider.notifier).state = language;
              final starterCode = problem.starterCode?[language.id] ?? language.defaultCode ?? '';
              _codeController.text = starterCode;
              ref.read(codeEditorProvider.notifier).setCode(starterCode);
            },
            itemBuilder: (context) => ProgrammingLanguage.supportedLanguages
                .map((lang) => PopupMenuItem(
                      value: lang,
                      child: Text(lang.name),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.code, size: 18),
                  const SizedBox(width: 4),
                  Text(selectedLanguage.name),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Problem'),
            Tab(text: 'Code'),
            Tab(text: 'Output'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProblemTab(problem),
          _buildCodeTab(problem, selectedLanguage),
          _buildOutputTab(editorState),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(problem, selectedLanguage, editorState),
    );
  }

  Widget _buildProblemTab(CodingProblemModel problem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty and Points
          Row(
            children: [
              _buildDifficultyBadge(problem.difficulty),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('${problem.points} points'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            problem.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),

          // Sample Input/Output
          if (problem.sampleInput != null) ...[
            Text(
              'Sample Input',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                problem.sampleInput!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (problem.sampleOutput != null) ...[
            Text(
              'Sample Output',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                problem.sampleOutput!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Explanation
          if (problem.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              'Explanation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              problem.explanation!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],

          // Hints
          if (problem.hints.isNotEmpty) ...[
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Hints'),
              tilePadding: EdgeInsets.zero,
              children: problem.hints.asMap().entries.map((entry) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.info.withOpacity(0.1),
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(entry.value),
                );
              }).toList(),
            ),
          ],

          // Tags
          if (problem.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: problem.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(fontSize: 12),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeTab(CodingProblemModel problem, ProgrammingLanguage language) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          // Code Editor Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2D2D2D),
            child: Row(
              children: [
                Icon(Icons.code, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(
                  'main.${language.extension}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.format_align_left, color: Colors.grey.shade400, size: 20),
                  onPressed: () {
                    // Format code (placeholder)
                  },
                  tooltip: 'Format Code',
                ),
              ],
            ),
          ),
          // Code Editor
          Expanded(
            child: TextField(
              controller: _codeController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: '// Write your code here...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) {
                ref.read(codeEditorProvider.notifier).setCode(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputTab(CodeEditorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Run Results
          if (state.runResults != null) ...[
            Text(
              'Run Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...state.runResults!.map((result) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            result.passed ? Icons.check_circle : Icons.cancel,
                            color: result.passed ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Test Case ${result.testCaseIndex + 1}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            result.passed ? 'Passed' : 'Failed',
                            style: TextStyle(
                              color: result.passed ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildOutputRow('Input:', result.input),
                      _buildOutputRow('Expected:', result.expectedOutput),
                      _buildOutputRow('Output:', result.actualOutput),
                      if (result.error != null)
                        _buildOutputRow('Error:', result.error!, isError: true),
                    ],
                  ),
                ),
              );
            }),
          ],

          // Submission Results
          if (state.submission != null) ...[
            const Divider(height: 32),
            Text(
              'Submission Result',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            CustomCard(
              gradient: state.submission!.status == SubmissionStatus.accepted
                  ? LinearGradient(
                      colors: [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)],
                    )
                  : LinearGradient(
                      colors: [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
                    ),
              child: Column(
                children: [
                  Icon(
                    state.submission!.status == SubmissionStatus.accepted
                        ? Icons.celebration
                        : Icons.error_outline,
                    size: 48,
                    color: state.submission!.status == SubmissionStatus.accepted
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.submission!.status == SubmissionStatus.accepted
                        ? 'Accepted!'
                        : _getStatusText(state.submission!.status),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: state.submission!.status == SubmissionStatus.accepted
                              ? AppColors.success
                              : AppColors.error,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.submission!.passedTestCases}/${state.submission!.totalTestCases} test cases passed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          // Empty State
          if (state.runResults == null && state.submission == null)
            const EmptyStateWidget(
              icon: Icons.terminal,
              title: 'No Output Yet',
              subtitle: 'Run or submit your code to see results',
            ),
        ],
      ),
    );
  }

  Widget _buildOutputRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: isError ? AppColors.error : Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isError ? AppColors.error.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: isError ? AppColors.error : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CodingProblemModel problem, ProgrammingLanguage language, CodeEditorState state) {
    return Container(
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
          Expanded(
            child: CustomButton(
              text: 'Run',
              isOutlined: true,
              isLoading: state.isRunning,
              icon: Icons.play_arrow,
              onPressed: state.isRunning
                  ? null
                  : () {
                      ref.read(codeEditorProvider.notifier).runCode(problem, language.id);
                      _tabController.animateTo(2);
                    },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: 'Submit',
              isLoading: state.isSubmitting,
              icon: Icons.upload,
              backgroundColor: AppColors.success,
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      ref.read(codeEditorProvider.notifier).submitCode(problem, language.id);
                      _tabController.animateTo(2);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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

  String _getStatusText(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.wrongAnswer:
        return 'Wrong Answer';
      case SubmissionStatus.runtimeError:
        return 'Runtime Error';
      case SubmissionStatus.compilationError:
        return 'Compilation Error';
      case SubmissionStatus.timeLimitExceeded:
        return 'Time Limit Exceeded';
      default:
        return status.name;
    }
  }
}

