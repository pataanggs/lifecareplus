import '../models/user_model.dart';
import 'local_storage_service.dart';
import 'mock_auth_service.dart';

// This lets us access the password map from outside the class
// which is a hack but acceptable for a demo
Map<String, String> _passwordStore = {};
Map<String, String> get passwordStore => _passwordStore;

class MockDataInitializer {
  final LocalStorageService _storage = LocalStorageService();

  Future<void> initializeMockData() async {
    // Check if we already have users
    final existingUsers = await _storage.getUsers();
    if (existingUsers.isNotEmpty) {
      // Already initialized
      return;
    }

    // Add some dummy users
    final now = DateTime.now();
    final users = [
      UserModel(
        id: 'test_user_1',
        fullName: 'John Doe',
        nickname: 'John',
        email: 'john.doe@example.com',
        phone: '555-123-4567',
        gender: 'Male',
        age: 35,
        height: 175,
        weight: 75,
        profileImageUrl:
            'https://ui-avatars.com/api/?name=John+Doe&background=random',
        createdAt: now,
        updatedAt: now,
      ),
      UserModel(
        id: 'test_user_2',
        fullName: 'Jane Smith',
        nickname: 'Jane',
        email: 'jane.smith@example.com',
        phone: '555-987-6543',
        gender: 'Female',
        age: 28,
        height: 168,
        weight: 62,
        profileImageUrl:
            'https://ui-avatars.com/api/?name=Jane+Smith&background=random',
        createdAt: now,
        updatedAt: now,
      ),
      UserModel(
        id: 'test_user_3',
        fullName: 'Test User',
        nickname: 'Test',
        email: 'test@example.com',
        phone: '555-555-5555',
        gender: 'Other',
        age: 42,
        height: 180,
        weight: 80,
        profileImageUrl:
            'https://ui-avatars.com/api/?name=Test+User&background=random',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Save to local storage
    for (final user in users) {
      await _storage.saveUser(user);
    }

    // Initialize passwords for the test users
    _passwordStore['john.doe@example.com'] = 'password123';
    _passwordStore['jane.smith@example.com'] = 'password123';
    _passwordStore['test@example.com'] = 'password123';

    // Create a simpler way for login testing
    print('Demo users created with emails:');
    print('- john.doe@example.com');
    print('- jane.smith@example.com');
    print('- test@example.com');
    print('All users have the password: password123');
  }
}
