import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;

  FirebaseAuth get _auth {
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  FirebaseFirestore get _firestore {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance!;
  }

  // Get current user (safely)
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Auth state changes stream (safely)
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      debugPrint('Error getting auth state stream: $e');
      return Stream.value(null);
    }
  }

  // Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'student',
    String? college,
    String? phone,
  }) async {
    try {
      // Create user with Firebase Auth
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      final UserModel userModel = UserModel(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        college: college,
        phone: phone,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      // Update last login time
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'lastLoginAt': Timestamp.now()});

      // Get user data from Firestore
      return await getUserData(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<UserModel> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw Exception('User data not found');
    }

    return UserModel.fromMap(doc.data()!);
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user from Firebase Auth
      await user.delete();
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final user = await getUserData(uid);
    return user.role == AppConstants.roleAdmin;
  }

  // Update user streak
  Future<void> updateUserStreak(String uid) async {
    final userDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (userDoc.exists) {
      final userData = UserModel.fromMap(userDoc.data()!);
      final now = DateTime.now();
      final lastLogin = userData.lastLoginAt ?? userData.createdAt;
      final daysDifference = now.difference(lastLogin).inDays;

      int newStreak = userData.currentStreak;
      if (daysDifference == 1) {
        // Consecutive day
        newStreak++;
      } else if (daysDifference > 1) {
        // Streak broken
        newStreak = 1;
      }

      final longestStreak = newStreak > userData.longestStreak
          ? newStreak
          : userData.longestStreak;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'currentStreak': newStreak,
        'longestStreak': longestStreak,
        'lastLoginAt': Timestamp.now(),
      });
    }
  }
}

