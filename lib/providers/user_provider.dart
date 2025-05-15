import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  
  // Check if user is logged in
  bool get isLoggedIn => _authService.currentUser != null;
  
  // Get user's display name (nickname or first name)
  String get displayName {
    if (_userData != null && _userData!.containsKey('nickname')) {
      return _userData!['nickname'];
    } else if (_userData != null && _userData!.containsKey('fullName')) {
      return _userData!['fullName'].toString().split(' ')[0];
    }
    return 'User';
  }
  
  // Get profile image URL
  String? get profileImageUrl => _userData?['profileImageUrl'];
  
  // Fetch user data
  Future<void> fetchUserData() async {
    if (!isLoggedIn) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _userData = await _authService.getUserProfile(_authService.currentUser!.uid);
      
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userData = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}