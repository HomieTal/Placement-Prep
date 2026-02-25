// App Constants
class AppConstants {
  static const String appName = 'Placement Prep';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String questionsCollection = 'questions';
  static const String testAttemptsCollection = 'test_attempts';
  static const String codingProblemsCollection = 'coding_problems';
  static const String leaderboardCollection = 'leaderboard';
  static const String mockTestsCollection = 'mock_tests';
  static const String analyticsCollection = 'analytics';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleAdmin = 'admin';

  // Categories
  static const List<String> categories = [
    'Quantitative Aptitude',
    'Logical Reasoning',
    'Verbal Ability',
    'Programming - C',
    'Programming - C++',
    'Programming - Java',
    'Programming - Python',
    'Data Structures',
    'SQL',
  ];

  // Difficulty Levels
  static const List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];

  // Quick Access Features
  static const List<Map<String, dynamic>> quickAccessFeatures = [
    {'title': 'Aptitude', 'icon': 'calculate', 'route': '/preparation/aptitude'},
    {'title': 'Coding', 'icon': 'code', 'route': '/coding'},
    {'title': 'Mock Tests', 'icon': 'quiz', 'route': '/mock-tests'},
    {'title': 'Interview Q&A', 'icon': 'question_answer', 'route': '/interview'},
    {'title': 'Resume Builder', 'icon': 'description', 'route': '/resume'},
    {'title': 'Analytics', 'icon': 'analytics', 'route': '/analytics'},
  ];

  // Badge Types
  static const Map<String, Map<String, dynamic>> badges = {
    'beginner': {'name': 'Beginner', 'points': 100, 'icon': '🌟'},
    'intermediate': {'name': 'Intermediate', 'points': 500, 'icon': '⭐'},
    'advanced': {'name': 'Advanced', 'points': 1000, 'icon': '🏆'},
    'expert': {'name': 'Expert', 'points': 5000, 'icon': '👑'},
    'streak_7': {'name': '7 Day Streak', 'points': 0, 'icon': '🔥'},
    'streak_30': {'name': '30 Day Streak', 'points': 0, 'icon': '💪'},
    'perfect_score': {'name': 'Perfect Score', 'points': 0, 'icon': '💯'},
  };
}

