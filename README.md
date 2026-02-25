<p align="center">
  <img src="assets/images/logo.png" alt="Placement Prep Logo" width="120" height="120">
</p>

<h1 align="center">Placement Prep</h1>

<p align="center">
  <strong>Your Complete Placement Preparation Companion</strong>
</p>

<p align="center">
  A comprehensive, full-stack placement preparation application built with Flutter for Mobile (Android/iOS) and Web, powered by Firebase backend.
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge" alt="Platform">
</p>

---

## ✨ Features

### 📱 Authentication Module
- 🔐 Email & Password Sign Up/Login
- 🔄 Forgot Password functionality
- 💾 Persistent Login with local storage
- 👥 Role-based access (Student/Admin)
- ✅ Form validation with error handling

### 📊 Dashboard Module
- 👋 Personalized welcome message
- 📈 Performance statistics (Tests Taken, Accuracy, Score, Streak)
- 🎯 Strongest/Weakest category tracking
- ⚡ Quick access cards for all features
- 📱 Responsive layout (Mobile/Tablet/Desktop)

### 📚 Preparation Module
**Categories:**
| Category | Topics |
|----------|--------|
| 📐 Quantitative Aptitude | Number System, Algebra, Geometry, etc. |
| 🧠 Logical Reasoning | Puzzles, Patterns, Deductions |
| 📝 Verbal Ability | Grammar, Comprehension, Vocabulary |
| 💻 Programming | C, C++, Java, Python |
| 🗂️ Data Structures | Arrays, Trees, Graphs, etc. |
| 🗄️ SQL | Queries, Joins, Optimization |

- ✅ Topic-wise practice
- 🎚️ Difficulty filter (Easy/Medium/Hard)
- 📖 Detailed explanations
- 📊 Score tracking per category

### 📝 Mock Test Module
- ⏱️ Timed tests with countdown timer
- 🔀 Randomized questions
- ⏰ Auto-submit on time expiry
- 🗺️ Question navigation grid
- 📊 Detailed result breakdown
- 📈 Category-wise & difficulty-wise analysis

### 💻 Coding Practice Module
- 📋 Problem description with examples
- 🌐 Multiple language support:
  - Python
  - Java
  - C++
  - C
  - JavaScript
- 🖥️ Built-in code editor
- ▶️ Run code against sample test cases
- 📤 Submit for full evaluation
- ✅ Test case results visualization

### 📈 Analytics Module
- 📉 Performance over time (Line Chart)
- 📊 Category-wise accuracy (Bar Chart)
- 🥧 Difficulty distribution (Pie Chart)
- 📅 Weekly study activity heatmap
- 📈 Improvement trend tracking
- 📱 Responsive charts for all screen sizes

### 🏆 Leaderboard System
- 🌍 Global ranking
- 🏫 College-wise ranking
- 💰 Points & coins system
- 🏅 Badge achievements:
  | Badge | Requirement |
  |-------|-------------|
  | 🌟 Beginner | 100 points |
  | ⭐ Intermediate | 500 points |
  | 🏆 Advanced | 1000 points |
  | 👑 Expert | 5000 points |
  | 🔥 7 Day Streak | 7 consecutive days |
  | 💪 30 Day Streak | 30 consecutive days |
  | 💯 Perfect Score | 100% in any test |

### 👨‍💼 Admin Panel (Web Only)
- 📊 Dashboard with overall statistics
- ➕ Add/Edit/Delete questions
- 📝 Manage mock tests
- 💻 Manage coding problems
- 👥 User management

---

## 🛠️ Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Dart** | Programming language |
| **Riverpod** | State management |
| **GoRouter** | Navigation & routing |
| **fl_chart** | Charts & visualizations |
| **Google Fonts** | Typography |

### Backend
| Technology | Purpose |
|------------|---------|
| **Firebase Auth** | Authentication |
| **Cloud Firestore** | Database |
| **Firebase Hosting** | Web deployment |

### Dev Tools
| Tool | Purpose |
|------|---------|
| **flutter_launcher_icons** | App icons generation |
| **flutter_lints** | Code quality |

---

## 🏗️ Architecture

The project follows **Clean Architecture** with feature-based organization:

```
lib/
├── core/
│   ├── constants/       # App constants, colors, and config
│   ├── providers/       # Global Riverpod providers
│   ├── router/          # GoRouter configuration
│   ├── services/        # Firebase and Storage services
│   ├── theme/           # Material 3 themes (Light/Dark)
│   ├── utils/           # Utilities, helpers, and validators
│   └── widgets/         # Reusable UI components
│
├── features/
│   ├── admin/           # Admin panel (CRUD operations)
│   ├── analytics/       # Progress & performance analytics
│   ├── auth/            # Authentication (Login/Signup)
│   ├── coding/          # Coding problems & editor
│   ├── dashboard/       # Home dashboard
│   ├── leaderboard/     # Rankings & achievements
│   ├── mock_test/       # Timed mock tests
│   └── preparation/     # Practice questions by category
│
└── main.dart            # App entry point
```

### State Management Pattern

```
Feature/
├── data/
│   ├── models/          # Data models
│   └── repositories/    # Data access layer
├── presentation/
│   ├── providers/       # Riverpod providers
│   ├── screens/         # UI screens
│   └── widgets/         # Feature-specific widgets
└── domain/              # Business logic (if needed)
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.11+)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- Android Studio / VS Code
- A Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/placement_prep.git
   cd placement_prep
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI if not already installed
   dart pub global activate flutterfire_cli
   
   # Login to Firebase
   firebase login
   
   # Configure Firebase for your project
   flutterfire configure
   ```
   
   > For detailed Firebase setup instructions, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

4. **Generate launcher icons**
   ```bash
   dart run flutter_launcher_icons
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For Web
   flutter run -d chrome
   
   # For iOS (macOS only)
   flutter run -d ios
   ```

### Seed Sample Data (Optional)

To populate the database with sample questions and data:

```dart
import 'package:placement_prep/core/utils/data_seeder.dart';

// In your initialization code
await DataSeeder.seedAll();
```

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | ✅ Supported |
| Windows | 🔄 In Progress |
| macOS | 🔄 In Progress |
| Linux | 🔄 In Progress |

---

## 🎨 UI/UX Features

- 🎨 **Material 3 Design** - Modern and clean interface
- 🌓 **Dark/Light Theme** - System-aware theme switching
- 📱 **Responsive Design** - Optimized for all screen sizes
- 💫 **Smooth Animations** - Engaging user experience
- 🎴 **Card-based UI** - Organized content presentation
- 📍 **Bottom Navigation** - Easy access on mobile
- 📌 **Sidebar Navigation** - Desktop-optimized layout

---

## 📁 Project Structure

```
placement_prep/
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── web/                  # Web-specific files
├── assets/
│   └── images/           # App images and icons
├── lib/
│   ├── core/             # Core functionality
│   ├── features/         # Feature modules
│   ├── firebase_options.dart
│   └── main.dart
├── test/                 # Unit and widget tests
├── pubspec.yaml          # Dependencies
├── FIREBASE_SETUP.md     # Firebase setup guide
└── README.md             # This file
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use the provided `analysis_options.yaml` for linting
- Write meaningful commit messages

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI Framework
- [Firebase](https://firebase.google.com/) - Backend Services
- [Riverpod](https://riverpod.dev/) - State Management
- [fl_chart](https://pub.dev/packages/fl_chart) - Charts Library

---

## 📧 Contact

For any queries or suggestions, feel free to reach out!

---

<p align="center">
  Made with ❤️ using Flutter
</p>

<p align="center">
  ⭐ Star this repo if you find it helpful!
</p>
