import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';
import 'mock_auth_service.dart';
import 'local_storage_service.dart';

class AuthService {
  // Use mock services instead of Firebase
  final MockAuthService _mockAuth = MockAuthService();
  final LocalStorageService _storage = LocalStorageService();

  // Flag to track if we've initialized
  bool _didEnsureInitialized = false;

  // Ensure initialization of auth service
  Future<void> ensureInitialized() async {
    if (!_didEnsureInitialized) {
      developer.log('Waiting for auth service to initialize...');
      await _mockAuth.initialized;
      _didEnsureInitialized = true;
      developer.log('Auth service initialization complete');
    }
  }

  // Get current user with error handling
  MockUser? get currentUser {
    try {
      return _mockAuth.currentUser;
    } catch (e) {
      developer.log('Error getting current user: $e');
      return null;
    }
  }

  // Stream to listen to auth state changes
  Stream<MockUser?> get authStateChanges {
    try {
      return _mockAuth.authStateChanges;
    } catch (e) {
      developer.log('Error getting auth state changes: $e');
      // Return an empty stream if service isn't initialized
      return Stream.value(null);
    }
  }

  // Sign in with Google (mock implementation)
  Future<MockUserCredential?> signInWithGoogle() async {
    await ensureInitialized();

    try {
      // Use mock Google sign-in
      final credential = await _mockAuth.signInWithGoogle();

      if (credential == null || credential.user == null) {
        return null;
      }

      developer.log(
        'Successfully signed in with mock Google: ${credential.user?.uid}',
      );
      return credential;
    } catch (e, stackTrace) {
      developer.log('Error with mock Google sign-in: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await ensureInitialized();

    try {
      await _mockAuth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }

  // Create user profile
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String nickname,
    required String email,
    required String phone,
    required String gender,
    required int age,
    required int height,
    required int weight,
    String? profileImageUrl,
  }) async {
    try {
      final now = DateTime.now();
      UserModel user = UserModel(
        id: uid,
        fullName: fullName,
        nickname: nickname,
        email: email,
        phone: phone,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        profileImageUrl: profileImageUrl,
        createdAt: now,
        updatedAt: now,
      );

      await _storage.saveUser(user);
    } catch (e) {
      developer.log('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      return await _storage.getUserById(uid);
    } catch (e) {
      developer.log('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, UserModel user) async {
    try {
      await _storage.saveUser(user);
    } catch (e) {
      developer.log('Error updating user profile: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await ensureInitialized();

    try {
      return await _mockAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      developer.log('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await ensureInitialized();

    try {
      return await _mockAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      developer.log('Error creating user: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await ensureInitialized();

    try {
      await _mockAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log('Error resetting password: $e');
      rethrow;
    }
  }
}
