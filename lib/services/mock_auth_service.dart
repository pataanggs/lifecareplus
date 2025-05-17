import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';
import 'mock_data_initializer.dart';

// Track login attempts to prevent login looping
// Now we're using the shared password store from MockDataInitializer
Map<String, String> get _passwordStore => passwordStore;

/// Mock User class that simulates Firebase User
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
  });
}

/// Mock UserCredential class that simulates Firebase UserCredential
class MockUserCredential {
  final MockUser? user;
  final bool isNewUser;

  MockUserCredential({required this.user, this.isNewUser = false});
}

/// Mock authentication provider that simulates FirebaseAuth
class MockAuthService {
  final LocalStorageService _storage = LocalStorageService();

  // Auth state controller
  final StreamController<MockUser?> _authStateController =
      StreamController<MockUser?>.broadcast();

  // Current authenticated user
  MockUser? _currentUser;

  // Track if initialization is complete
  bool _isInitialized = false;
  Completer<void> _initializationCompleter = Completer<void>();

  // Simulate auth state changes
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Get current user
  MockUser? get currentUser {
    // If not initialized, force synchronous initialization to avoid race conditions
    if (!_isInitialized) {
      debugPrint(
        'WARNING: Accessing currentUser before initialization is complete',
      );
    }
    return _currentUser;
  }

  // Initialization status
  Future<void> get initialized => _initializationCompleter.future;

  // Constructor
  MockAuthService() {
    _initializeAuthState();
  }

  // Initialize auth state from stored user
  Future<void> _initializeAuthState() async {
    try {
      debugPrint('MockAuthService: Beginning initialization');

      final storedUserId = await _storage.getCurrentUserId();
      debugPrint('MockAuthService: Found stored user ID: $storedUserId');

      if (storedUserId != null) {
        final user = await _storage.getUserById(storedUserId);
        if (user != null) {
          _currentUser = MockUser(
            uid: user.id,
            email: user.email,
            displayName: user.fullName,
            photoURL: user.profileImageUrl,
            phoneNumber: user.phone,
          );
          debugPrint(
            'MockAuthService: Successfully initialized with user: ${_currentUser?.uid}',
          );
        } else {
          debugPrint(
            'MockAuthService: User ID found in storage but no matching user record: $storedUserId',
          );
          // Clear the invalid stored ID
          await _storage.setCurrentUserId(null);
          _currentUser = null;
        }
      } else {
        debugPrint('MockAuthService: No user ID in storage');
        _currentUser = null;
      }

      // Notify listeners of the current state
      _authStateController.add(_currentUser);

      // Mark initialization as complete
      _isInitialized = true;
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
      debugPrint('MockAuthService: Initialization complete');
    } catch (e) {
      debugPrint('MockAuthService: Error during initialization: $e');
      // Mark as initialized even on error, but with null user
      _currentUser = null;
      _isInitialized = true;
      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
      _authStateController.add(null);
    }
  }

  // Email + Password Registration
  Future<MockUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Ensure initialization is complete
    if (!_isInitialized) {
      await initialized;
    }

    // Check if user already exists
    final existingUser = await _storage.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception(
        'The email address is already in use by another account.',
      );
    }

    // Generate a new user ID
    final uid =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

    // Create new user in local storage
    final now = DateTime.now();
    final user = UserModel(
      id: uid,
      fullName: '',
      nickname: '',
      email: email,
      phone: '',
      gender: '',
      age: 0,
      height: 0,
      weight: 0,
      profileImageUrl: null,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.saveUser(user);

    // Make sure to set current user ID BEFORE updating auth state
    await _storage.setCurrentUserId(uid);
    debugPrint('Registered new user with email: $email, ID: $uid');

    // Store the password
    _passwordStore[email] = password;

    // Create and return MockUser
    final mockUser = MockUser(uid: uid, email: email);
    _currentUser = mockUser;
    _authStateController.add(mockUser);

    return MockUserCredential(user: mockUser, isNewUser: true);
  }

  // Email + Password Sign In
  Future<MockUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Ensure initialization is complete
    if (!_isInitialized) {
      await initialized;
    }

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Find user with the email
    final user = await _storage.getUserByEmail(email);
    if (user == null) {
      debugPrint('No user found for email: $email');
      throw Exception('No user found for that email.');
    }

    debugPrint('Found user with email: $email, ID: ${user.id}');

    // SIMPLIFIED: For mock purposes, always accept any password for existing users
    // This removes any potential password verification issues
    debugPrint('Mock password check - always accepting password for demo');
    _passwordStore[email] = password;

    // Make sure to save the current user ID in storage
    await _storage.setCurrentUserId(user.id);
    debugPrint('Set current user ID in storage: ${user.id}');

    // Verify the ID was actually saved
    final storedId = await _storage.getCurrentUserId();
    debugPrint('Verified stored user ID: $storedId');

    // Create and return MockUser
    final mockUser = MockUser(
      uid: user.id,
      email: user.email,
      displayName: user.fullName,
      photoURL: user.profileImageUrl,
      phoneNumber: user.phone,
    );

    // Update the current user reference
    _currentUser = mockUser;

    // Notify listeners of auth state change
    _authStateController.add(mockUser);
    debugPrint('Auth state updated with user: ${mockUser.uid}');

    // Wait a moment to ensure state is propagated
    await Future.delayed(Duration(milliseconds: 100));

    return MockUserCredential(user: mockUser);
  }

  // Google Sign In (simulated)
  Future<MockUserCredential?> signInWithGoogle() async {
    // Ensure initialization is complete
    if (!_isInitialized) {
      await initialized;
    }

    // Simulate Google sign-in process delay
    await Future.delayed(Duration(milliseconds: 800));

    // Simulate user cancellation (random, 20% chance)
    if (Random().nextDouble() < 0.2) {
      return null; // User cancelled
    }

    // Generate mock Google account info
    final email = 'user${Random().nextInt(10000)}@gmail.com';
    final displayName = 'Test User ${Random().nextInt(100)}';
    final uid = 'google_${DateTime.now().millisecondsSinceEpoch}';
    final photoURL =
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random';

    // Check if this email already exists in our system
    UserModel? existingUser = await _storage.getUserByEmail(email);
    bool isNewUser = existingUser == null;

    if (isNewUser) {
      // Create a new user
      final now = DateTime.now();
      final newUser = UserModel(
        id: uid,
        fullName: displayName,
        nickname: displayName.split(' ').first,
        email: email,
        phone: '',
        gender: '',
        age: 0,
        height: 0,
        weight: 0,
        profileImageUrl: photoURL,
        createdAt: now,
        updatedAt: now,
      );

      await _storage.saveUser(newUser);
      existingUser = newUser;
    }

    // Set current user
    await _storage.setCurrentUserId(existingUser.id);

    // Create MockUser
    final mockUser = MockUser(
      uid: existingUser.id,
      email: existingUser.email,
      displayName: existingUser.fullName,
      photoURL: existingUser.profileImageUrl,
      phoneNumber: existingUser.phone,
    );

    _currentUser = mockUser;
    _authStateController.add(mockUser);

    return MockUserCredential(user: mockUser, isNewUser: isNewUser);
  }

  // Sign out
  Future<void> signOut() async {
    // Ensure initialization is complete
    if (!_isInitialized) {
      await initialized;
    }

    await _storage.setCurrentUserId(null);
    _currentUser = null;
    _authStateController.add(null);
    debugPrint('User signed out, auth state cleared');
  }

  // Reset password (mock implementation)
  Future<void> sendPasswordResetEmail({required String email}) async {
    // Ensure initialization is complete
    if (!_isInitialized) {
      await initialized;
    }

    // Check if user exists
    final user = await _storage.getUserByEmail(email);
    if (user == null) {
      throw Exception('No user found for that email.');
    }

    // In a real app, this would send an email
    // Here we just simulate a delay
    await Future.delayed(Duration(milliseconds: 700));

    if (kDebugMode) {
      print('Password reset email sent to $email (mock implementation)');
    }
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
