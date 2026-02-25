import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_test_model.dart';
import '../../../preparation/data/models/question_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../main.dart';

class MockTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available mock tests
  Future<List<MockTestModel>> getMockTests() async {
    // If Firebase is not available, return sample data
    if (!isFirebaseAvailable) {
      return _getSampleMockTests();
    }

    try {
      final snapshot = await _firestore
          .collection(AppConstants.mockTestsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final tests = snapshot.docs
          .map((doc) => MockTestModel.fromMap(doc.data(), doc.id))
          .toList();

      // Return sample data if no tests in Firestore
      if (tests.isEmpty) {
        return _getSampleMockTests();
      }

      return tests;
    } catch (e) {
      // Return sample data on error
      return _getSampleMockTests();
    }
  }

  // Sample company-wise mock tests (like Skillrack)
  List<MockTestModel> _getSampleMockTests() {
    return [
      MockTestModel(
        id: 'tcs-001',
        title: 'TCS',
        description: 'TCS NQT Pattern Test - Aptitude, Coding & Verbal',
        totalQuestions: 50,
        durationMinutes: 60,
        categories: ['Hiring'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'infosys-001',
        title: 'Infosys',
        description: 'Infosys InfyTQ Pattern Test',
        totalQuestions: 40,
        durationMinutes: 55,
        categories: ['Programming'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'wipro-001',
        title: 'Wipro',
        description: 'Wipro NLTH Pattern Test',
        totalQuestions: 60,
        durationMinutes: 90,
        categories: ['Aptitude'],
        difficulty: 'Easy',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'accenture-001',
        title: 'Accenture_Mock',
        description: 'Accenture Recruitment Pattern Test',
        totalQuestions: 90,
        durationMinutes: 90,
        categories: ['Screening Test'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'cognizant-001',
        title: 'Cognizant',
        description: 'Cognizant GenC Pattern Test',
        totalQuestions: 55,
        durationMinutes: 60,
        categories: ['Programming'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'capgemini-001',
        title: 'Capgemini',
        description: 'Capgemini Recruitment Pattern Test',
        totalQuestions: 50,
        durationMinutes: 60,
        categories: ['Coding'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'hcl-001',
        title: 'HCL_Tech',
        description: 'HCL Technologies Pattern Test',
        totalQuestions: 45,
        durationMinutes: 50,
        categories: ['Aptitude'],
        difficulty: 'Easy',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'amazon-001',
        title: 'Amazon',
        description: 'Amazon SDE Online Assessment',
        totalQuestions: 30,
        durationMinutes: 90,
        categories: ['Coding'],
        difficulty: 'Hard',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'google-001',
        title: 'Google',
        description: 'Google Online Assessment Pattern',
        totalQuestions: 25,
        durationMinutes: 120,
        categories: ['Coding'],
        difficulty: 'Hard',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'microsoft-001',
        title: 'Microsoft',
        description: 'Microsoft Online Assessment',
        totalQuestions: 30,
        durationMinutes: 100,
        categories: ['Coding'],
        difficulty: 'Hard',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'zoho-001',
        title: 'Zoho',
        description: 'Zoho Recruitment Pattern Test',
        totalQuestions: 40,
        durationMinutes: 90,
        categories: ['Programming'],
        difficulty: 'Hard',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'tcs-nqt-001',
        title: 'TCS-NQT',
        description: 'TCS National Qualifier Test',
        totalQuestions: 100,
        durationMinutes: 120,
        categories: ['Exam'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'amcat-001',
        title: 'AMCAT',
        description: 'AMCAT Employability Assessment',
        totalQuestions: 70,
        durationMinutes: 90,
        categories: ['Coding'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'c-lang-001',
        title: 'C language',
        description: 'C Programming Fundamentals Test',
        totalQuestions: 50,
        durationMinutes: 45,
        categories: ['Programming'],
        difficulty: 'Easy',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'java-001',
        title: 'Java Programming',
        description: 'Core Java & OOP Concepts Test',
        totalQuestions: 50,
        durationMinutes: 50,
        categories: ['Coding'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'python-001',
        title: 'Python',
        description: 'Python Programming Test',
        totalQuestions: 40,
        durationMinutes: 40,
        categories: ['Programming'],
        difficulty: 'Easy',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'aptitude-001',
        title: 'APTITUDE',
        description: 'Quantitative Aptitude Practice',
        totalQuestions: 50,
        durationMinutes: 50,
        categories: ['Aptitude'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'pseudo-001',
        title: 'Pseudo Code',
        description: 'Pseudo Code & Algorithm Test',
        totalQuestions: 30,
        durationMinutes: 30,
        categories: ['Programming'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'dsa-001',
        title: 'Data Structures',
        description: 'DSA Concepts & Problems',
        totalQuestions: 40,
        durationMinutes: 60,
        categories: ['Coding'],
        difficulty: 'Hard',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      MockTestModel(
        id: 'sql-001',
        title: 'SQL',
        description: 'SQL Database Queries Test',
        totalQuestions: 35,
        durationMinutes: 40,
        categories: ['Programming'],
        difficulty: 'Medium',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Get mock test by ID
  Future<MockTestModel?> getMockTestById(String id) async {
    final doc = await _firestore
        .collection(AppConstants.mockTestsCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return MockTestModel.fromMap(doc.data()!, doc.id);
  }

  // Get questions for a mock test
  Future<List<QuestionModel>> getTestQuestions(MockTestModel test) async {
    // If Firebase is not available, return sample questions
    if (!isFirebaseAvailable) {
      return _getSampleQuestionsForTest(test);
    }

    try {
      final questions = <QuestionModel>[];

      // Distribute questions across categories
      final questionsPerCategory = test.totalQuestions ~/ test.categories.length;
      final remaining = test.totalQuestions % test.categories.length;

      for (int i = 0; i < test.categories.length; i++) {
        final category = test.categories[i];
        final count = questionsPerCategory + (i < remaining ? 1 : 0);

        Query query = _firestore
            .collection(AppConstants.questionsCollection)
            .where('category', isEqualTo: category);

        if (test.difficulty != 'Mixed') {
          query = query.where('difficulty', isEqualTo: test.difficulty);
        }

        final snapshot = await query.limit(count * 2).get();
        final categoryQuestions = snapshot.docs
            .map((doc) => QuestionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        categoryQuestions.shuffle();
        questions.addAll(categoryQuestions.take(count));
      }

      // If no questions found, return sample questions
      if (questions.isEmpty) {
        return _getSampleQuestionsForTest(test);
      }

      // Shuffle all questions
      questions.shuffle();
      return questions;
    } catch (e) {
      return _getSampleQuestionsForTest(test);
    }
  }

  // Generate sample questions for a test
  List<QuestionModel> _getSampleQuestionsForTest(MockTestModel test) {
    final questions = <QuestionModel>[];
    final category = test.categories.isNotEmpty ? test.categories.first : 'General';

    // Generate sample questions based on category
    final sampleQuestions = _getSampleQuestionsByCategory(category, test.totalQuestions);
    questions.addAll(sampleQuestions);

    questions.shuffle();
    return questions.take(test.totalQuestions).toList();
  }

  List<QuestionModel> _getSampleQuestionsByCategory(String category, int count) {
    final questions = <QuestionModel>[];

    // Aptitude Questions
    final aptitudeQuestions = [
      QuestionModel(
        id: 'apt-1',
        question: 'If a train travels 300 km in 5 hours, what is its average speed?',
        options: ['50 km/h', '60 km/h', '70 km/h', '80 km/h'],
        correctAnswer: '60 km/h',
        explanation: 'Average speed = Total distance / Total time = 300/5 = 60 km/h',
        category: 'Aptitude',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'apt-2',
        question: 'A shopkeeper sells an article at 20% profit. If the cost price is Rs. 500, what is the selling price?',
        options: ['Rs. 550', 'Rs. 600', 'Rs. 650', 'Rs. 700'],
        correctAnswer: 'Rs. 600',
        explanation: 'Selling Price = Cost Price + Profit = 500 + (20/100 × 500) = 500 + 100 = Rs. 600',
        category: 'Aptitude',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'apt-3',
        question: 'What is the next number in the series: 2, 6, 12, 20, 30, ?',
        options: ['40', '42', '44', '46'],
        correctAnswer: '42',
        explanation: 'Differences: 4, 6, 8, 10, 12. The pattern shows difference increasing by 2.',
        category: 'Aptitude',
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'apt-4',
        question: 'If 8 workers can complete a task in 12 days, how many days will 6 workers take?',
        options: ['14 days', '16 days', '18 days', '20 days'],
        correctAnswer: '16 days',
        explanation: 'Total work = 8 × 12 = 96 worker-days. Time for 6 workers = 96/6 = 16 days',
        category: 'Aptitude',
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'apt-5',
        question: 'The ratio of A\'s age to B\'s age is 4:5. If A is 20 years old, how old is B?',
        options: ['22 years', '24 years', '25 years', '28 years'],
        correctAnswer: '25 years',
        explanation: 'A/B = 4/5, 20/B = 4/5, B = (20 × 5)/4 = 25 years',
        category: 'Aptitude',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
    ];

    // Programming Questions
    final programmingQuestions = [
      QuestionModel(
        id: 'prog-1',
        question: 'What is the time complexity of binary search?',
        options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        correctAnswer: 'O(log n)',
        explanation: 'Binary search divides the search space in half each time, resulting in O(log n) complexity.',
        category: 'Programming',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'prog-2',
        question: 'Which data structure uses LIFO (Last In First Out)?',
        options: ['Queue', 'Stack', 'Array', 'Linked List'],
        correctAnswer: 'Stack',
        explanation: 'Stack follows LIFO - the last element added is the first to be removed.',
        category: 'Programming',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'prog-3',
        question: 'What is the output of: printf("%d", 5 + 3 * 2)?',
        options: ['16', '11', '13', '10'],
        correctAnswer: '11',
        explanation: 'Multiplication has higher precedence. 3*2=6, then 5+6=11',
        category: 'Programming',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'prog-4',
        question: 'Which sorting algorithm has the best average time complexity?',
        options: ['Bubble Sort', 'Selection Sort', 'Quick Sort', 'Insertion Sort'],
        correctAnswer: 'Quick Sort',
        explanation: 'Quick Sort has an average time complexity of O(n log n), which is better than O(n²) algorithms.',
        category: 'Programming',
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'prog-5',
        question: 'What is a NULL pointer in C?',
        options: ['A pointer to zero', 'A pointer that points to nothing', 'An uninitialized pointer', 'A pointer to empty string'],
        correctAnswer: 'A pointer that points to nothing',
        explanation: 'NULL pointer is a pointer that does not point to any valid memory location.',
        category: 'Programming',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
    ];

    // Coding Questions
    final codingQuestions = [
      QuestionModel(
        id: 'code-1',
        question: 'What is the space complexity of a recursive fibonacci function?',
        options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
        correctAnswer: 'O(n)',
        explanation: 'The call stack can grow up to n levels deep in recursive fibonacci.',
        category: 'Coding',
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'code-2',
        question: 'Which design pattern is used to create objects without specifying exact class?',
        options: ['Singleton', 'Factory', 'Observer', 'Decorator'],
        correctAnswer: 'Factory',
        explanation: 'Factory pattern creates objects without exposing the instantiation logic.',
        category: 'Coding',
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'code-3',
        question: 'What is the purpose of the "final" keyword in Java?',
        options: ['Make variable unchangeable', 'Improve performance', 'Enable inheritance', 'Create threads'],
        correctAnswer: 'Make variable unchangeable',
        explanation: 'Final keyword prevents modification of variables, methods (no override), and classes (no inheritance).',
        category: 'Coding',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'code-4',
        question: 'Which OOP concept is demonstrated by method overriding?',
        options: ['Encapsulation', 'Polymorphism', 'Abstraction', 'Inheritance'],
        correctAnswer: 'Polymorphism',
        explanation: 'Method overriding is a form of runtime polymorphism where subclass provides specific implementation.',
        category: 'Coding',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      QuestionModel(
        id: 'code-5',
        question: 'What is the default return type of main() in C?',
        options: ['void', 'int', 'float', 'char'],
        correctAnswer: 'int',
        explanation: 'In C, main() returns int to indicate program execution status to the operating system.',
        category: 'Coding',
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
    ];

    // Select questions based on category
    switch (category.toLowerCase()) {
      case 'aptitude':
        questions.addAll(aptitudeQuestions);
        break;
      case 'programming':
        questions.addAll(programmingQuestions);
        break;
      case 'coding':
        questions.addAll(codingQuestions);
        break;
      case 'hiring':
      case 'exam':
      case 'screening test':
        // Mix of all categories for company tests
        questions.addAll(aptitudeQuestions);
        questions.addAll(programmingQuestions);
        questions.addAll(codingQuestions);
        break;
      default:
        questions.addAll(aptitudeQuestions);
        questions.addAll(programmingQuestions);
    }

    // If we need more questions, duplicate with modified IDs
    while (questions.length < count) {
      final originalLength = questions.length;
      for (int i = 0; i < originalLength && questions.length < count; i++) {
        final q = questions[i];
        questions.add(QuestionModel(
          id: '${q.id}-dup-${questions.length}',
          question: q.question,
          options: q.options,
          correctAnswer: q.correctAnswer,
          explanation: q.explanation,
          category: q.category,
          difficulty: q.difficulty,
          createdAt: q.createdAt,
        ));
      }
    }

    return questions.take(count).toList();
  }

  // Save test attempt
  Future<String> saveTestAttempt(TestAttemptModel attempt) async {
    final doc = await _firestore
        .collection(AppConstants.testAttemptsCollection)
        .add(attempt.toMap());

    // Update user points
    await _firestore.collection(AppConstants.usersCollection).doc(attempt.userId).update({
      'totalPoints': FieldValue.increment(attempt.score * 10),
      'coins': FieldValue.increment(attempt.score ~/ 2),
    });

    // Update leaderboard
    await _updateLeaderboard(attempt.userId, attempt.score * 10);

    return doc.id;
  }

  // Get user's test attempts
  Future<List<TestAttemptModel>> getUserAttempts(String userId, {int limit = 10}) async {
    final snapshot = await _firestore
        .collection(AppConstants.testAttemptsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => TestAttemptModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get attempt by ID
  Future<TestAttemptModel?> getAttemptById(String id) async {
    final doc = await _firestore
        .collection(AppConstants.testAttemptsCollection)
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return TestAttemptModel.fromMap(doc.data()!, doc.id);
  }

  // Create mock test (for admin)
  Future<String> createMockTest(MockTestModel test) async {
    final doc = await _firestore
        .collection(AppConstants.mockTestsCollection)
        .add(test.toMap());
    return doc.id;
  }

  // Update leaderboard
  Future<void> _updateLeaderboard(String userId, int points) async {
    final leaderboardRef = _firestore
        .collection(AppConstants.leaderboardCollection)
        .doc(userId);

    final doc = await leaderboardRef.get();
    if (doc.exists) {
      await leaderboardRef.update({
        'totalPoints': FieldValue.increment(points),
      });
    } else {
      await leaderboardRef.set({
        'userId': userId,
        'totalPoints': points,
        'rank': 0,
        'badges': [],
      });
    }
  }

  // Calculate category breakdown
  Map<String, dynamic> calculateCategoryBreakdown(
    List<QuestionModel> questions,
    Map<String, String> answers,
  ) {
    final breakdown = <String, dynamic>{};

    for (var question in questions) {
      final category = question.category;
      if (!breakdown.containsKey(category)) {
        breakdown[category] = {'total': 0, 'correct': 0, 'accuracy': 0.0};
      }

      breakdown[category]['total']++;
      if (answers[question.id] == question.correctAnswer) {
        breakdown[category]['correct']++;
      }
    }

    // Calculate accuracy for each category
    breakdown.forEach((key, value) {
      value['accuracy'] = value['total'] > 0
          ? (value['correct'] / value['total'] * 100).roundToDouble()
          : 0.0;
    });

    return breakdown;
  }

  // Calculate difficulty breakdown
  Map<String, dynamic> calculateDifficultyBreakdown(
    List<QuestionModel> questions,
    Map<String, String> answers,
  ) {
    final breakdown = <String, dynamic>{};

    for (var question in questions) {
      final difficulty = question.difficulty;
      if (!breakdown.containsKey(difficulty)) {
        breakdown[difficulty] = {'total': 0, 'correct': 0, 'accuracy': 0.0};
      }

      breakdown[difficulty]['total']++;
      if (answers[question.id] == question.correctAnswer) {
        breakdown[difficulty]['correct']++;
      }
    }

    // Calculate accuracy for each difficulty
    breakdown.forEach((key, value) {
      value['accuracy'] = value['total'] > 0
          ? (value['correct'] / value['total'] * 100).roundToDouble()
          : 0.0;
    });

    return breakdown;
  }
}

