import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/screens.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/preparation/presentation/screens/preparation_screen.dart';
import '../../features/preparation/presentation/screens/practice_screen.dart';
import '../../features/mock_test/presentation/screens/mock_test_list_screen.dart';
import '../../features/mock_test/presentation/screens/mock_test_details_screen.dart';
import '../../features/mock_test/presentation/screens/mock_test_screen.dart';
import '../../features/coding/presentation/screens/coding_list_screen.dart';
import '../../features/coding/presentation/screens/coding_problem_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import 'shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Don't redirect while auth is still initializing
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.uri.toString() == '/login' ||
          state.uri.toString() == '/signup' ||
          state.uri.toString() == '/forgot-password';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Routes with Shell
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/preparation',
            builder: (context, state) => const PreparationScreen(),
          ),
          GoRoute(
            path: '/preparation/practice',
            builder: (context, state) => const PracticeScreen(),
          ),
          GoRoute(
            path: '/mock-tests',
            builder: (context, state) => const MockTestListScreen(),
          ),
          GoRoute(
            path: '/mock-tests/details',
            builder: (context, state) => const MockTestDetailsScreen(),
          ),
          GoRoute(
            path: '/mock-tests/test',
            builder: (context, state) => const MockTestScreen(),
          ),
          GoRoute(
            path: '/coding',
            builder: (context, state) => const CodingListScreen(),
          ),
          GoRoute(
            path: '/coding/problem',
            builder: (context, state) => const CodingProblemScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
        ],
      ),

      // Admin Routes (no shell)
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

