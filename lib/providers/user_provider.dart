import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Check if user is logged in
  bool get isLoggedIn => _authService.currentUser != null;

  // Get user's display name (nickname or first name)
  String get displayName {
    if (_user != null && _user!.nickname.isNotEmpty) {
      return _user!.nickname;
    } else if (_user != null && _user!.fullName.isNotEmpty) {
      return _user!.fullName.split(' ')[0];
    }
    return 'User';
  }

  // Get profile image URL
  String? get profileImageUrl => _user?.profileImageUrl;

  // Fetch user data
  Future<void> fetchUserData() async {
    if (!isLoggedIn) return;

    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.getUserProfile(
        _authService.currentUser!.uid,
      );
      _user = user;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? fullName,
    String? nickname,
    String? phone,
    String? gender,
    int? age,
    int? height,
    int? weight,
    String? profileImageUrl,
  }) async {
    if (!isLoggedIn || _user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Create updated user model
      final updatedUser = _user!.copyWith(
        fullName: fullName,
        nickname: nickname,
        phone: phone,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        profileImageUrl: profileImageUrl,
      );

      // Update in Firestore
      await _authService.updateUserProfile(_user!.id, updatedUser);

      // Update local state
      _user = updatedUser;

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
