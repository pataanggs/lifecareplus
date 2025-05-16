import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';

class AuthService {
  // Simplified Google Sign In without serverClientId for Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Use getters for lazy initialization
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      developer.log('Error accessing FirebaseAuth: $e');
      throw Exception('Firebase Auth not initialized: $e');
    }
  }

  FirebaseFirestore get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      developer.log('Error accessing Firestore: $e');
      throw Exception('Firestore not initialized: $e');
    }
  }

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
      // Return an empty stream if Firebase isn't initialized
      return Stream.value(null);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign-In flow');

      // Sign out from any previous session to avoid conflicts
      await _googleSignIn.signOut();

      // Force silent sign out first to clear any cached credentials
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        developer.log('Error during Firebase signOut: $e');
        // Continue anyway
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      developer.log(
        'Google Sign-In result: ${googleUser?.email ?? "No user returned"}',
      );

      if (googleUser == null) {
        developer.log('Google Sign-In was canceled by user');
        // User canceled the sign-in flow
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      developer.log('Got Google authentication tokens');
      developer.log(
        'Access token available: ${googleAuth.accessToken != null}',
      );
      developer.log('ID token available: ${googleAuth.idToken != null}');

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      developer.log('Created Firebase credential from Google tokens');

      // Sign in with credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      developer.log(
        'Successfully signed in with Firebase: ${userCredential.user?.uid}',
      );

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        developer.log('New user detected, creating profile');
        final User user = userCredential.user!;

        // Create a basic profile for new Google users
        await createUserProfile(
          uid: user.uid,
          fullName: user.displayName ?? 'Google User',
          nickname: user.displayName?.split(' ').first ?? 'User',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          gender: '', // These will be filled in onboarding
          age: 0,
          height: 0,
          weight: 0,
          profileImageUrl: user.photoURL,
        );
        developer.log('Created new user profile for: ${user.email}');
      } else {
        developer.log('Existing user signed in: ${userCredential.user?.email}');
      }

      return userCredential;
    } catch (e) {
      developer.log('Error signing in with Google: $e');
      print('Detailed error in Google Sign-In: $e');
      if (e is FirebaseAuthException) {
        developer.log('Firebase Auth Error Code: ${e.code}');
      } else if (e is Exception) {
        developer.log('Non-Firebase exception: ${e.toString()}');
      }
      rethrow;
    }
  }

  // Sign out (now also signs out from Google)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }

  // Create user profile in Firestore
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      developer.log('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, UserModel user) async {
    try {
      Map<String, dynamic> data = user.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      developer.log('Error updating user profile: $e');
      rethrow;
    }
  }

  // The following methods are kept for backward compatibility but not actively used

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
