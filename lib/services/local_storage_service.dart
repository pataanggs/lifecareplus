import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// A service that handles local storage for user data and authentication state
class LocalStorageService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';
  static const String _uidKey = 'user_uid';
  static const String _emailKey = 'user_email';
  static const String _fullNameKey = 'user_full_name';
  static const String _nicknameKey = 'user_nickname';
  static const String _isLoggedInKey = 'is_logged_in';

  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Get all users from local storage
  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);

    if (usersJson == null) {
      return [];
    }

    final List<dynamic> usersList = jsonDecode(usersJson);
    return usersList
        .map((userMap) => UserModel.fromMap(userMap, userMap['id']))
        .toList();
  }

  // Save users to local storage
  Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> userMaps =
        users.map((user) => user.toMap()).toList();
    await prefs.setString(_usersKey, jsonEncode(userMaps));
  }

  // Add or update a user
  Future<void> saveUser(UserModel user) async {
    final users = await getUsers();
    final existingUserIndex = users.indexWhere((u) => u.id == user.id);

    if (existingUserIndex >= 0) {
      users[existingUserIndex] = user;
    } else {
      users.add(user);
    }

    await saveUsers(users);
  }

  // Get user by ID
  Future<UserModel?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  // Delete user by ID
  Future<void> deleteUser(String id) async {
    final users = await getUsers();
    users.removeWhere((user) => user.id == id);
    await saveUsers(users);
  }

  // Save current user ID (for session management)
  Future<void> setCurrentUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString(_currentUserKey, userId);
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      return null;
    }
    return getUserById(userId);
  }

  // Save user info to SharedPreferences
  Future<void> saveUserInfo({
    required String uid,
    required String email,
    required String fullName,
    required String nickname,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_fullNameKey, fullName);
    await prefs.setString(_nicknameKey, nickname);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Update specific user info fields
  Future<void> updateUserInfo({String? fullName, String? nickname}) async {
    final prefs = await SharedPreferences.getInstance();
    if (fullName != null) await prefs.setString(_fullNameKey, fullName);
    if (nickname != null) await prefs.setString(_nicknameKey, nickname);
  }

  // Get user info
  Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'uid': prefs.getString(_uidKey) ?? '',
      'email': prefs.getString(_emailKey) ?? '',
      'fullName': prefs.getString(_fullNameKey) ?? '',
      'nickname': prefs.getString(_nicknameKey) ?? '',
    };
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear user info (for logout)
  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_nicknameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}
