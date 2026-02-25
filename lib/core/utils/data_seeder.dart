import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// Utility class to seed sample data into Firestore for testing
/// Call DataSeeder.seedAll() once to populate the database with sample data
class DataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    await seedQuestions();
    await seedMockTests();
    await seedCodingProblems();
  }

  static Future<void> seedQuestions() async {
    final questions = [
      {
        'question': 'What is the time complexity of binary search?',
        'options': ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        'correctAnswer': 'O(log n)',
        'explanation': 'Binary search divides the search space in half at each step, resulting in O(log n) complexity.',
        'category': 'Data Structures',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'Which data structure uses LIFO principle?',
        'options': ['Queue', 'Stack', 'Array', 'Linked List'],
        'correctAnswer': 'Stack',
        'explanation': 'Stack follows Last In First Out (LIFO) principle where the last element added is the first to be removed.',
        'category': 'Data Structures',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'If a train travels 60 km in 1 hour, how far will it travel in 2.5 hours at the same speed?',
        'options': ['120 km', '150 km', '180 km', '200 km'],
        'correctAnswer': '150 km',
        'explanation': 'Distance = Speed × Time = 60 × 2.5 = 150 km',
        'category': 'Quantitative Aptitude',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'What is the next number in the series: 2, 6, 12, 20, 30, ?',
        'options': ['40', '42', '44', '46'],
        'correctAnswer': '42',
        'explanation': 'The differences are 4, 6, 8, 10, 12. So next number is 30 + 12 = 42',
        'category': 'Logical Reasoning',
        'difficulty': 'Medium',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'Which SQL keyword is used to retrieve data from a database?',
        'options': ['GET', 'FETCH', 'SELECT', 'RETRIEVE'],
        'correctAnswer': 'SELECT',
        'explanation': 'SELECT is the SQL statement used to query and retrieve data from database tables.',
        'category': 'SQL',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'What is the output of print(2**3) in Python?',
        'options': ['6', '8', '9', 'Error'],
        'correctAnswer': '8',
        'explanation': '** is the exponentiation operator in Python. 2**3 = 2³ = 8',
        'category': 'Programming - Python',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'Which OOP concept allows a class to inherit properties from another class?',
        'options': ['Encapsulation', 'Polymorphism', 'Inheritance', 'Abstraction'],
        'correctAnswer': 'Inheritance',
        'explanation': 'Inheritance allows a class (child) to inherit attributes and methods from another class (parent).',
        'category': 'Programming - Java',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'What is the worst-case time complexity of Quick Sort?',
        'options': ['O(n log n)', 'O(n²)', 'O(n)', 'O(log n)'],
        'correctAnswer': 'O(n²)',
        'explanation': 'Quick Sort has O(n²) worst-case complexity when the pivot selection is poor (already sorted array with first/last pivot).',
        'category': 'Data Structures',
        'difficulty': 'Medium',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'Choose the correct synonym for "Ephemeral"',
        'options': ['Permanent', 'Transient', 'Eternal', 'Lasting'],
        'correctAnswer': 'Transient',
        'explanation': 'Ephemeral means lasting for a very short time, similar to transient.',
        'category': 'Verbal Ability',
        'difficulty': 'Medium',
        'createdAt': Timestamp.now(),
      },
      {
        'question': 'What does NULL represent in SQL?',
        'options': ['Zero', 'Empty string', 'Unknown/Missing value', 'False'],
        'correctAnswer': 'Unknown/Missing value',
        'explanation': 'NULL in SQL represents an unknown or missing value, not zero or empty string.',
        'category': 'SQL',
        'difficulty': 'Easy',
        'createdAt': Timestamp.now(),
      },
    ];

    for (var question in questions) {
      await _firestore.collection(AppConstants.questionsCollection).add(question);
    }

    print('✅ Seeded ${questions.length} questions');
  }

  static Future<void> seedMockTests() async {
    final mockTests = [
      {
        'title': 'Aptitude Test - Beginner',
        'description': 'Test your basic aptitude skills with this beginner-friendly mock test.',
        'totalQuestions': 20,
        'durationMinutes': 30,
        'categories': ['Quantitative Aptitude', 'Logical Reasoning'],
        'difficulty': 'Easy',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Programming Fundamentals',
        'description': 'Comprehensive test covering programming basics in multiple languages.',
        'totalQuestions': 25,
        'durationMinutes': 45,
        'categories': ['Programming - Python', 'Programming - Java', 'Programming - C'],
        'difficulty': 'Medium',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Data Structures & Algorithms',
        'description': 'Advanced test on DSA concepts for placement preparation.',
        'totalQuestions': 30,
        'durationMinutes': 60,
        'categories': ['Data Structures', 'Programming - C++'],
        'difficulty': 'Hard',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Full Mock Test',
        'description': 'Complete placement test covering all topics.',
        'totalQuestions': 50,
        'durationMinutes': 90,
        'categories': ['Quantitative Aptitude', 'Logical Reasoning', 'Verbal Ability', 'Data Structures', 'SQL'],
        'difficulty': 'Mixed',
        'isActive': true,
        'createdAt': Timestamp.now(),
      },
    ];

    for (var test in mockTests) {
      await _firestore.collection(AppConstants.mockTestsCollection).add(test);
    }

    print('✅ Seeded ${mockTests.length} mock tests');
  }

  static Future<void> seedCodingProblems() async {
    final problems = [
      {
        'title': 'Two Sum',
        'description': 'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.\n\nYou may assume that each input would have exactly one solution, and you may not use the same element twice.',
        'difficulty': 'Easy',
        'tags': ['Array', 'Hash Table'],
        'testCases': [
          {'input': '[2,7,11,15], target=9', 'expectedOutput': '[0,1]', 'isHidden': false},
          {'input': '[3,2,4], target=6', 'expectedOutput': '[1,2]', 'isHidden': false},
          {'input': '[3,3], target=6', 'expectedOutput': '[0,1]', 'isHidden': true},
        ],
        'hints': [
          'Try using a hash map to store the values you have seen',
          'For each element, check if target - element exists in the map'
        ],
        'sampleInput': '[2,7,11,15], target=9',
        'sampleOutput': '[0,1]',
        'explanation': 'nums[0] + nums[1] = 2 + 7 = 9',
        'points': 10,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Reverse String',
        'description': 'Write a function that reverses a string. The input string is given as an array of characters.\n\nYou must do this by modifying the input array in-place with O(1) extra memory.',
        'difficulty': 'Easy',
        'tags': ['String', 'Two Pointers'],
        'testCases': [
          {'input': '["h","e","l","l","o"]', 'expectedOutput': '["o","l","l","e","h"]', 'isHidden': false},
          {'input': '["H","a","n","n","a","h"]', 'expectedOutput': '["h","a","n","n","a","H"]', 'isHidden': false},
        ],
        'hints': [
          'Use two pointers, one at the start and one at the end',
          'Swap characters and move pointers towards center'
        ],
        'sampleInput': '["h","e","l","l","o"]',
        'sampleOutput': '["o","l","l","e","h"]',
        'points': 10,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Valid Parentheses',
        'description': 'Given a string s containing just the characters \'(\', \')\', \'{\', \'}\', \'[\' and \']\', determine if the input string is valid.\n\nAn input string is valid if:\n1. Open brackets must be closed by the same type of brackets.\n2. Open brackets must be closed in the correct order.',
        'difficulty': 'Medium',
        'tags': ['String', 'Stack'],
        'testCases': [
          {'input': '()', 'expectedOutput': 'true', 'isHidden': false},
          {'input': '()[]{}', 'expectedOutput': 'true', 'isHidden': false},
          {'input': '(]', 'expectedOutput': 'false', 'isHidden': false},
          {'input': '([)]', 'expectedOutput': 'false', 'isHidden': true},
        ],
        'hints': [
          'Use a stack to keep track of opening brackets',
          'When you see a closing bracket, check if it matches the top of stack'
        ],
        'sampleInput': '()',
        'sampleOutput': 'true',
        'points': 15,
        'createdAt': Timestamp.now(),
      },
      {
        'title': 'Maximum Subarray',
        'description': 'Given an integer array nums, find the contiguous subarray (containing at least one number) which has the largest sum and return its sum.',
        'difficulty': 'Medium',
        'tags': ['Array', 'Dynamic Programming', 'Divide and Conquer'],
        'testCases': [
          {'input': '[-2,1,-3,4,-1,2,1,-5,4]', 'expectedOutput': '6', 'isHidden': false},
          {'input': '[1]', 'expectedOutput': '1', 'isHidden': false},
          {'input': '[5,4,-1,7,8]', 'expectedOutput': '23', 'isHidden': true},
        ],
        'hints': [
          'Think about Kadane\'s algorithm',
          'Keep track of the maximum sum ending at each position'
        ],
        'sampleInput': '[-2,1,-3,4,-1,2,1,-5,4]',
        'sampleOutput': '6',
        'explanation': 'The subarray [4,-1,2,1] has the largest sum = 6',
        'points': 15,
        'createdAt': Timestamp.now(),
      },
    ];

    for (var problem in problems) {
      await _firestore.collection('coding_problems').add(problem);
    }

    print('✅ Seeded ${problems.length} coding problems');
  }
}

