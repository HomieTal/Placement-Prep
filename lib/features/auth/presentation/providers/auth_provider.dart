import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final authService = ref.watch(authServiceProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await authService.getUserData(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth State
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // Add timeout to prevent indefinite loading
      await Future.delayed(const Duration(milliseconds: 100));

      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userData = await _authService.getUserData(user.uid)
              .timeout(const Duration(seconds: 5));
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: userData,
          );
        } catch (e) {
          // User exists in Firebase Auth but not in Firestore or timeout
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
          );
        }
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      // Firebase not initialized or other error - default to unauthenticated
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? college,
    String? phone,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        college: college,
        phone: phone,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Demo mode: Allow login with test credentials
      if (email == 'demo@test.com' && password == 'demo123') {
        final demoUser = UserModel(
          uid: 'demo-user-id',
          email: email,
          name: 'Demo User',
          role: 'student',
          college: 'Demo College',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          totalPoints: 500,
          coins: 100,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: demoUser,
        );
        return;
      }

      // Demo admin mode
      if (email == 'admin@test.com' && password == 'admin123') {
        final adminUser = UserModel(
          uid: 'admin-user-id',
          email: email,
          name: 'Admin User',
          role: 'admin',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          totalPoints: 1000,
          coins: 500,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: adminUser,
        );
        return;
      }

      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      status: state.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

