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
    return _authService.currentUser?.displayName ?? 'Guest';
  }

  // Get profile image URL
  String? get profileImageUrl => _user?.profileImageUrl ?? _authService.currentUser?.photoURL;

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
    double? height,
    double? weight,
    String? profileImageUrl,
  }) async {
    if (!isLoggedIn || _user == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Update Firebase Auth profile if name or photo changes
      if (fullName != null || profileImageUrl != null) {
        await _authService.currentUser?.updateDisplayName(fullName);
        await _authService.currentUser?.updatePhotoURL(profileImageUrl);
      }

      // Create updated user model
      final updatedUser = UserModel(
        id: _user!.id,
        fullName: fullName ?? _user!.fullName,
        nickname: nickname ?? _user!.nickname,
        email: _user!.email,
        phone: phone ?? _user!.phone,
        gender: gender ?? _user!.gender,
        age: age ?? _user!.age,
        height: height ?? _user!.height,
        weight: weight ?? _user!.weight,
        profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
        createdAt: _user!.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in storage
      await _authService.updateUserProfile(_user!.id, updatedUser as Map<String, dynamic>);

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
