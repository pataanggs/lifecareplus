import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _storage = LocalStorageService();

  // Get current user with error handling
  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (e) {
      developer.log('Error getting current user: $e');
      return null;
    }
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
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
      await _firebaseAuth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }

  // Create user profile in both Firestore and local storage
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String nickname,
    required String email,
    required String phone,
    required String gender,
    required int age,
    required double height, // Changed to double to match UserModel
    required double weight, // Changed to double
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

      // Save to Firestore
      await _firestore.collection('users').doc(uid).set(user.toMap());
      developer.log('User profile created in Firestore for UID: $uid');

      // Also save to local storage for offline access
      await _storage.saveUser(user);
      developer.log('User profile cached in local storage');
    } catch (e, stackTrace) {
      developer.log('Error creating user profile: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get user profile from Firestore with fallback to local storage
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      // Try to get from Firestore first
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        developer.log('User profile found in Firestore for UID: $uid');
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(data, uid);

        // Update local storage cache
        await _storage.saveUser(user);

        return user;
      } else {
        developer.log(
          'User profile not found in Firestore, checking local storage',
        );
        // Fallback to local storage
        return await _storage.getUserById(uid);
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching user profile from Firestore: $e');
      developer.log('Stack trace: $stackTrace');

      // Try local storage as last resort
      try {
        return await _storage.getUserById(uid);
      } catch (localError) {
        developer.log(
          'Error fetching user profile from local storage: $localError',
        );
        return null;
      }
    }
  }

  // Update user profile in both Firestore and local storage
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      // First get current profile to ensure we have a complete model
      UserModel? currentProfile = await getUserProfile(uid);
      if (currentProfile == null) {
        throw Exception('Cannot update profile: User not found');
      }

      // Create updated model
      UserModel updatedProfile = UserModel(
        id: currentProfile.id,
        fullName: updates['fullName'] ?? currentProfile.fullName,
        nickname: updates['nickname'] ?? currentProfile.nickname,
        email: updates['email'] ?? currentProfile.email,
        phone: updates['phone'] ?? currentProfile.phone,
        gender: updates['gender'] ?? currentProfile.gender,
        age: updates['age'] ?? currentProfile.age,
        height:
            (updates['height'] as num?)?.toDouble() ?? currentProfile.height,
        weight:
            (updates['weight'] as num?)?.toDouble() ?? currentProfile.weight,
        profileImageUrl:
            updates['profileImageUrl'] ?? currentProfile.profileImageUrl,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update Firestore
      Map<String, dynamic> updateData = updatedProfile.toMap();
      await _firestore.collection('users').doc(uid).update(updateData);
      developer.log('User profile updated in Firestore for UID: $uid');

      // Update local storage
      await _storage.saveUser(updatedProfile);
      developer.log('User profile updated in local storage');
    } catch (e, stackTrace) {
      developer.log('Error updating user profile: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
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
      return await _firebaseAuth.createUserWithEmailAndPassword(
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
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log('Error resetting password: $e');
      rethrow;
    }
  }

  // Get current user profile - optimized implementation
  Future<UserModel?> getCurrentUserProfile() async {
    User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      developer.log('getCurrentUserProfile: No user logged in');
      return null;
    }

    String uid = firebaseUser.uid;
    try {
      developer.log('getCurrentUserProfile: Fetching profile for UID: $uid');

      // Try Firestore first
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        developer.log('getCurrentUserProfile: Document found in Firestore');
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(data, uid);

        // Update local cache
        await _storage.saveUser(user);

        return user;
      } else {
        developer.log(
          'getCurrentUserProfile: Document not found in Firestore, checking local storage',
        );
        return await _storage.getUserById(uid);
      }
    } catch (e, stackTrace) {
      developer.log('getCurrentUserProfile: Error fetching from Firestore: $e');
      developer.log('Stack trace: $stackTrace');

      // Fallback to local storage
      try {
        return await _storage.getUserById(uid);
      } catch (localError) {
        developer.log(
          'getCurrentUserProfile: Also failed to fetch from local storage: $localError',
        );
        return null;
      }
    }
  }
}
