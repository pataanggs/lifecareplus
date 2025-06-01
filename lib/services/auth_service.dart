import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'local_storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<UserCredential> signInWithGoogle() async {
    try {
      developer.log('Starting Google sign-in flow');

      // Initialize Google Sign In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If sign in was aborted
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      developer.log('Successfully signed in with Google');

      // Create or update user profile if necessary
      if (userCredential.user != null) {
        // Check if this user exists in our database
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          // New user - create profile
          await createUserProfile(
            uid: userCredential.user!.uid,
            fullName: userCredential.user!.displayName ?? 'User',
            nickname: userCredential.user!.displayName?.split(' ')[0] ?? 'User',
            email: userCredential.user!.email ?? '',
            phone: userCredential.user!.phoneNumber ?? '',
            gender: '', // Will be collected during onboarding
            age: 0, // Will be collected during onboarding
            height: 0.0, // Will be collected during onboarding
            weight: 0.0, // Will be collected during onboarding
            profileImageUrl: userCredential.user!.photoURL,
          );
        }
      }

      return userCredential;
    } catch (e, stackTrace) {
      developer.log('Error with Google sign-in: $e');
      developer.log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Successfully signed in with email: $email');
      return userCredential;
    } catch (e) {
      developer.log('Error signing in with email: $e');
      rethrow;
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Successfully created user with email: $email');
      return userCredential;
    } catch (e) {
      developer.log('Error creating user with email: $e');
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
    required double height,
    required double weight,
    String? profileImageUrl,
  }) async {
    try {
      // Create UserProfile with required fields
      final userProfile = UserProfile(
        uid: uid,
        fullName: fullName,
        nickname: nickname,
        email: email,
        phone: phone,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        profileImageUrl: profileImageUrl,
      );

      // Convert to map and add timestamps
      Map<String, dynamic> userProfileData = userProfile.toMap();
      userProfileData['createdAt'] = FieldValue.serverTimestamp();
      userProfileData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).set(userProfileData);
      developer.log('User profile created for UID: $uid');

      // Save basic user info to local storage
      await _storage.saveUserInfo(
        uid: uid,
        email: email,
        fullName: fullName,
        nickname: nickname,
      );
    } catch (e) {
      developer.log('Error creating user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? nickname,
    String? phone,
    // String? gender, // Not passed from ProfileScreen as it's not editable there
    int? age,
    double? height,
    double? weight,
    String? profileImageUrl, String? gender,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) updates['fullName'] = fullName;
      if (nickname != null) updates['nickname'] = nickname;
      if (phone != null) updates['phone'] = phone;
      // gender is not updated as it's not editable in the profile screen
      if (age != null) updates['age'] = age;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      // Only update if there are actual changes apart from 'updatedAt'
      if (updates.length > 1) {
        await _firestore.collection('users').doc(uid).update(updates);
        developer.log('User profile updated for UID: $uid');
      } else {
        developer.log('No fields to update for UID: $uid besides timestamp.');
      }

      // Update local storage if relevant fields changed
      if (fullName != null || nickname != null) {
        // Use the values from updates map to ensure we have the correct values
        await _storage.updateUserInfo(
          fullName: updates['fullName'] as String? ?? fullName,
          nickname: updates['nickname'] as String? ?? nickname,
        );
      }
    } catch (e) {
      developer.log('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserProfile.fromMap({...data, 'uid': uid});
      }
      return null;
    } catch (e) {
      developer.log('Error fetching user profile: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut(); // Sign out from Google first
      await _firebaseAuth.signOut(); // Then from Firebase
      await _storage.clearUserInfo();
      developer.log('User signed out');
    } catch (e) {
      developer.log('Error signing out: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      developer.log('Password reset email sent to: $email');
    } catch (e) {
      developer.log('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // First check if we have the user in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        // Return user profile from Firestore
        final data = userDoc.data()!;
        return UserProfile.fromMap({...data, 'uid': user.uid});
      } else {
        // If no profile in Firestore yet, return basic info from Firebase Auth
        return UserProfile(
          uid: user.uid,
          fullName: user.displayName ?? '',
          nickname: user.displayName?.split(' ')[0] ?? '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          gender: '',
          profileImageUrl: user.photoURL,
        );
      }
    } catch (e) {
      developer.log('Error getting user profile: $e');
      // For testing purposes, return a dummy profile
      return UserProfile.dummy();
    }
  }
}
