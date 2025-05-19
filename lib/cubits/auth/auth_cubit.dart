import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  var data = AuthStateData();

  AuthCubit(this._prefs) : super(const AuthStateInitial()) {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        emit(const AuthStateInitial());
      } else {
        data = data.copyWith(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          isEmailVerified: user.emailVerified,
        );

        emit(AuthStateLoaded(data));
      }
    });
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthStateLoading(data));
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user credentials
      if (userCredential.user != null) {
        await _prefs.setString('user_email', email);
        await _prefs.setString('user_uid', userCredential.user!.uid);
        await _prefs.setBool('is_logged_in', true);
      }

      data = data.copyWith(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
        isEmailVerified: userCredential.user!.emailVerified,
        isLoggedIn: true,
      );
      
      emit(AuthStateLoaded(data));
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user has been disabled.';
      }
      emit(AuthStateFailure(data));
      throw message;
    }
  }

  // Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthStateLoading(data));
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user credentials
      if (userCredential.user != null) {
        await _prefs.setString('user_email', email);
        await _prefs.setString('user_uid', userCredential.user!.uid);
        await _prefs.setBool('is_logged_in', true);
      }

      data = data.copyWith(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email,
        displayName: userCredential.user!.displayName,
        photoURL: userCredential.user!.photoURL,
        isEmailVerified: userCredential.user!.emailVerified,
        isLoggedIn: true,
      );
      
      emit(AuthStateLoaded(data));
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }
      emit(AuthStateFailure(data));
      throw message;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _prefs.remove('user_email');
      await _prefs.remove('user_uid');
      await _prefs.setBool('is_logged_in', false);

      data = data.copyWith(
        uid: null,
        email: null,
        displayName: null,
        photoURL: null,
        isEmailVerified: false,
        isLoggedIn: false,
      );
      emit(AuthStateLoaded(data));
    } catch (e) {
      emit(AuthStateFailure(data));
      throw 'Failed to sign out';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }
      throw message;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      emit(AuthStateLoading(data));
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      emit(AuthStateFailure(data));
      throw 'Failed to update profile';
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
