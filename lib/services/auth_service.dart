import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _storage = LocalStorageService();

  // Get current user with error handling
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      developer.log('Error getting current user: $e');
      return null;
    }
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      developer.log('Error getting auth state changes: $e');
      return Stream.value(null);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign In
      throw UnimplementedError('Google Sign In not implemented yet');
    } catch (e, stackTrace) {
      developer.log('Error with Google sign-in: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
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
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      developer.log('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
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
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log('Error resetting password: $e');
      rethrow;
    }
  }
}
