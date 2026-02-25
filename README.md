# Placement Prep - Full-Stack Placement Preparation Application

A comprehensive, Skillrack-like placement preparation application built with Flutter for Mobile (Android/iOS) and Web, with Firebase backend.

## 🚀 Features

### 📱 Authentication Module
- Email & Password Sign Up/Login
- Forgot Password functionality
- Persistent Login
- Role-based access (Student/Admin)
- Form validation with error handling

### 📊 Dashboard Module
- Personalized welcome message
- Performance statistics (Tests Taken, Accuracy, Score, Streak)
- Strongest/Weakest category tracking
- Quick access cards for all features
- Responsive layout (Mobile/Tablet/Desktop)

### 📚 Preparation Module
- **Categories:**
  - Quantitative Aptitude
  - Logical Reasoning
  - Verbal Ability
  - Programming (C, C++, Java, Python)
  - Data Structures
  - SQL
- Topic-wise practice
- Difficulty filter (Easy/Medium/Hard)
- Detailed explanations
- Score tracking

### 📝 Mock Test Module
- Timed tests with countdown
- Randomized questions
- Auto-submit on time expiry
- Question navigation grid
- Detailed result breakdown
- Category-wise & difficulty-wise analysis

### 💻 Coding Practice Module
- Problem description with examples
- Multiple language support (Python, Java, C++, C, JavaScript)
- Code editor
- Run code against sample test cases
- Submit for full evaluation
- Test case results visualization

### 📈 Analytics Module
- Performance over time (Line Chart)
- Category-wise accuracy (Bar Chart)
- Difficulty distribution (Pie Chart)
- Weekly study activity heatmap
- Improvement trend tracking
- Responsive charts for all screen sizes

### 🏆 Leaderboard System
- Global ranking
- College-wise ranking
- Points & coins system
- Badge achievements

### 👨‍💼 Admin Panel (Web Only)
- Dashboard with overall statistics
- Add/Edit/Delete questions
- Manage mock tests
- Manage coding problems

## 🏗 Architecture

Clean Architecture with feature-based organization:

```
lib/
├── core/
│   ├── constants/       # App constants and colors
│   ├── providers/       # Global providers
│   ├── router/          # GoRouter configuration
│   ├── services/        # Firebase and Storage services
│   ├── theme/           # Material 3 themes (Light/Dark)
│   ├── utils/           # Utilities and helpers
│   └── widgets/         # Reusable widgets
│
├── features/
│   ├── auth/            # Authentication
│   ├── dashboard/       # Dashboard
│   ├── preparation/     # Practice questions
│   ├── mock_test/       # Mock tests
│   ├── coding/          # Coding problems
│   ├── analytics/       # Progress analytics
│   ├── leaderboard/     # Rankings
│   └── admin/           # Admin panel
│
└── main.dart
```

## 📦 Dependencies

- **Firebase:** firebase_core, firebase_auth, cloud_firestore
- **State Management:** flutter_riverpod
- **Routing:** go_router
- **Charts:** fl_chart
- **Utils:** intl, shared_preferences
- **UI:** google_fonts

## 🚀 Getting Started

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Create Firebase project
   - Add configuration files for Android/iOS/Web

3. **Seed sample data (optional)**
   ```dart
   import 'package:placement_prep/core/utils/data_seeder.dart';
   await DataSeeder.seedAll();
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 UI Features

- Material 3 Design
- Dark/Light theme support
- Responsive layouts
- Modern card-based UI
- Bottom navigation (Mobile)
- Sidebar navigation (Desktop)

## 📄 License

MIT License
