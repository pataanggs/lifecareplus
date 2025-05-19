import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/utils/onboarding_preferences.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  var data = HomeStateData();

  HomeCubit(this._prefs) : super(const HomeStateInitial());

  Future<void> initProceed() async {
    try {
      if (kDebugMode) {
        print("Initializing HomeCubit");
      }
      
      emit(HomeStateLoading(data));
      
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print("No user found in HomeCubit");
        }
        throw Exception('No user found');
      }

      // Get user data from SharedPreferences
      final storedEmail = _prefs.getString('user_email');
      final isLoggedIn = _prefs.getBool('is_logged_in') ?? false;

      // Get onboarding data
      final gender = await OnboardingPreferences.getGender();
      final age = await OnboardingPreferences.getAge();
      final weight = await OnboardingPreferences.getWeight();
      final height = await OnboardingPreferences.getHeight();

      // Calculate BMI if we have both weight and height
      double? bmi;
      if (weight != null && height != null && weight > 0 && height > 0) {
        // Convert height from cm to meters
        final heightInMeters = height / 100;
        bmi = weight / (heightInMeters * heightInMeters);
      }

      // Update state data
      data = data.copyWith(
        uid: user.uid,
        email: user.email ?? storedEmail,
        displayName: user.displayName,
        photoURL: user.photoURL,
        isEmailVerified: user.emailVerified,
        isLoggedIn: isLoggedIn,
        gender: gender,
        age: age,
        weight: weight,
        height: height,
        bmi: bmi,
      );

      if (kDebugMode) {
        print("HomeCubit initialized with user: ${user.uid}");
      }

      emit(HomeStateLoaded(data));
    } catch (e) {
      if (kDebugMode) {
        print("Error in HomeCubit: $e");
      }
      emit(HomeStateFailure(data));
      throw Exception('Failed to get profile data: $e');
    }
  }

  Future<void> refreshProfileData() async {
    await initProceed();
  }

  HomeStateData get currentUserData => data;
}
