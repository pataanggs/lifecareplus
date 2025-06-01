import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var data = const AuthStateData();

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

      final user = userCredential.user;
      if (user == null) throw Exception('Login gagal: user tidak ditemukan');

      await _prefs.setString('user_email', email);
      await _prefs.setString('user_uid', user.uid);
      await _prefs.setBool('is_logged_in', true);

      data = data.copyWith(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        isEmailVerified: user.emailVerified,
        isLoggedIn: true,
      );

      emit(AuthStateLoaded(data));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      emit(AuthStateFailure(data));
      throw message;
    } catch (e) {
      emit(AuthStateFailure(data));
      throw Exception('Terjadi kesalahan saat login: ${e.toString()}');
    }
  }

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

  // Sign in with Google - corrected implementation
  Future<UserCredential> signInWithGoogle() async {
    try {
      emit(AuthStateLoading(data));

      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _prefs.setString('user_email', userCredential.user!.email ?? '');
        await _prefs.setString('user_uid', userCredential.user!.uid);
        await _prefs.setBool('is_logged_in', true);

        // Create new state with user data
        data = data.copyWith(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email,
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          isEmailVerified: userCredential.user!.emailVerified,
          isLoggedIn: true,
        );

        emit(AuthStateLoaded(data));
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Email sudah digunakan dengan metode login lain';
          break;
        case 'invalid-credential':
          message = 'Kredensial tidak valid';
          break;
        case 'ERROR_ABORTED_BY_USER':
          message = 'Login dibatalkan oleh pengguna';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      emit(AuthStateFailure(data));
      throw message;
    } catch (e) {
      developer.log('Error signing in with Google: ${e.toString()}');
      emit(AuthStateFailure(data));
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
