import 'package:cloud_firestore/cloud_firestore.dart';

class CodingProblemModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<String> tags;
  final List<TestCase> testCases;
  final List<String> hints;
  final String? sampleInput;
  final String? sampleOutput;
  final String? explanation;
  final Map<String, String>? starterCode;
  final int points;
  final DateTime createdAt;

  CodingProblemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    this.tags = const [],
    this.testCases = const [],
    this.hints = const [],
    this.sampleInput,
    this.sampleOutput,
    this.explanation,
    this.starterCode,
    this.points = 10,
    required this.createdAt,
  });

  factory CodingProblemModel.fromMap(Map<String, dynamic> map, String id) {
    return CodingProblemModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      tags: List<String>.from(map['tags'] ?? []),
      testCases: (map['testCases'] as List<dynamic>?)
              ?.map((tc) => TestCase.fromMap(tc))
              .toList() ??
          [],
      hints: List<String>.from(map['hints'] ?? []),
      sampleInput: map['sampleInput'],
      sampleOutput: map['sampleOutput'],
      explanation: map['explanation'],
      starterCode: map['starterCode'] != null
          ? Map<String, String>.from(map['starterCode'])
          : null,
      points: map['points'] ?? 10,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'tags': tags,
      'testCases': testCases.map((tc) => tc.toMap()).toList(),
      'hints': hints,
      'sampleInput': sampleInput,
      'sampleOutput': sampleOutput,
      'explanation': explanation,
      'starterCode': starterCode,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;

  TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  factory TestCase.fromMap(Map<String, dynamic> map) {
    return TestCase(
      input: map['input'] ?? '',
      expectedOutput: map['expectedOutput'] ?? '',
      isHidden: map['isHidden'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'isHidden': isHidden,
    };
  }
}

class CodeSubmission {
  final String id;
  final String problemId;
  final String userId;
  final String language;
  final String code;
  final SubmissionStatus status;
  final List<TestCaseResult> results;
  final int passedTestCases;
  final int totalTestCases;
  final DateTime submittedAt;

  CodeSubmission({
    required this.id,
    required this.problemId,
    required this.userId,
    required this.language,
    required this.code,
    required this.status,
    this.results = const [],
    required this.passedTestCases,
    required this.totalTestCases,
    required this.submittedAt,
  });

  factory CodeSubmission.fromMap(Map<String, dynamic> map, String id) {
    return CodeSubmission(
      id: id,
      problemId: map['problemId'] ?? '',
      userId: map['userId'] ?? '',
      language: map['language'] ?? '',
      code: map['code'] ?? '',
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubmissionStatus.pending,
      ),
      results: (map['results'] as List<dynamic>?)
              ?.map((r) => TestCaseResult.fromMap(r))
              .toList() ??
          [],
      passedTestCases: map['passedTestCases'] ?? 0,
      totalTestCases: map['totalTestCases'] ?? 0,
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'problemId': problemId,
      'userId': userId,
      'language': language,
      'code': code,
      'status': status.name,
      'results': results.map((r) => r.toMap()).toList(),
      'passedTestCases': passedTestCases,
      'totalTestCases': totalTestCases,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }
}

enum SubmissionStatus {
  pending,
  running,
  accepted,
  wrongAnswer,
  runtimeError,
  compilationError,
  timeLimitExceeded,
}

class TestCaseResult {
  final int testCaseIndex;
  final String input;
  final String expectedOutput;
  final String actualOutput;
  final bool passed;
  final String? error;

  TestCaseResult({
    required this.testCaseIndex,
    required this.input,
    required this.expectedOutput,
    required this.actualOutput,
    required this.passed,
    this.error,
  });

  factory TestCaseResult.fromMap(Map<String, dynamic> map) {
    return TestCaseResult(
      testCaseIndex: map['testCaseIndex'] ?? 0,
      input: map['input'] ?? '',
      expectedOutput: map['expectedOutput'] ?? '',
      actualOutput: map['actualOutput'] ?? '',
      passed: map['passed'] ?? false,
      error: map['error'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testCaseIndex': testCaseIndex,
      'input': input,
      'expectedOutput': expectedOutput,
      'actualOutput': actualOutput,
      'passed': passed,
      'error': error,
    };
  }
}

// Supported Languages
class ProgrammingLanguage {
  final String id;
  final String name;
  final String extension;
  final String? defaultCode;

  const ProgrammingLanguage({
    required this.id,
    required this.name,
    required this.extension,
    this.defaultCode,
  });

  static const List<ProgrammingLanguage> supportedLanguages = [
    ProgrammingLanguage(
      id: 'python',
      name: 'Python',
      extension: 'py',
      defaultCode: '# Write your Python code here\n\ndef solution():\n    pass\n',
    ),
    ProgrammingLanguage(
      id: 'java',
      name: 'Java',
      extension: 'java',
      defaultCode: '// Write your Java code here\n\npublic class Solution {\n    public static void main(String[] args) {\n        \n    }\n}\n',
    ),
    ProgrammingLanguage(
      id: 'cpp',
      name: 'C++',
      extension: 'cpp',
      defaultCode: '// Write your C++ code here\n\n#include <iostream>\nusing namespace std;\n\nint main() {\n    \n    return 0;\n}\n',
    ),
    ProgrammingLanguage(
      id: 'c',
      name: 'C',
      extension: 'c',
      defaultCode: '// Write your C code here\n\n#include <stdio.h>\n\nint main() {\n    \n    return 0;\n}\n',
    ),
    ProgrammingLanguage(
      id: 'javascript',
      name: 'JavaScript',
      extension: 'js',
      defaultCode: '// Write your JavaScript code here\n\nfunction solution() {\n    \n}\n',
    ),
  ];

  static ProgrammingLanguage getById(String id) {
    return supportedLanguages.firstWhere(
      (lang) => lang.id == id,
      orElse: () => supportedLanguages.first,
    );
  }
}

