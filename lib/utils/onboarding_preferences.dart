import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferences {
  static const String _genderKey = 'onboarding_gender';
  static const String _ageKey = 'onboarding_age';
  static const String _weightKey = 'onboarding_weight';
  static const String _heightKey = 'onboarding_height';
  static const String _isOnboardingCompleteKey = 'is_onboarding_complete';

  static Future<void> saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_genderKey, gender);
  }

  static Future<void> saveAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ageKey, age);
  }

  static Future<void> saveWeight(int weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weightKey, weight);
  }

  static Future<void> saveHeight(int height) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_heightKey, height);
  }

  static Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOnboardingCompleteKey, value);
  }

  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_genderKey);
  }

  static Future<int?> getAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_ageKey);
  }

  static Future<int?> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_weightKey);
  }

  static Future<int?> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_heightKey);
  }

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOnboardingCompleteKey) ?? false;
  }

  static Future<bool> hasCompletedAllSteps() async {
    final gender = await getGender();
    final age = await getAge();
    final weight = await getWeight();
    final height = await getHeight();

    return gender != null && age != null && weight != null && height != null;
  }

  static Future<String?> getNextIncompleteStep() async {
    if (await getGender() == null) return 'gender';
    if (await getAge() == null) return 'age';
    if (await getWeight() == null) return 'weight';
    if (await getHeight() == null) return 'height';
    return null;
  }
} 