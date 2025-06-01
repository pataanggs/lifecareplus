
class UserProfile {
  final String? uid;
  final String fullName;
  final String nickname;
  final String email;
  final String phone;
  final String gender;
  final int? age;
  final double? height;
  final double? weight;
  final String? profileImageUrl;

  UserProfile({
    this.uid,
    this.fullName = '',
    this.nickname = '',
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.age,
    this.height,
    this.weight,
    this.profileImageUrl,
  });

  // Create a dummy profile for testing
  factory UserProfile.dummy() {
    return UserProfile(
      uid: 'dummy-id',
      fullName: 'Nama Pengguna',
      nickname: 'User',
      email: 'user@example.com',
      phone: '08123456789',
      gender: 'Laki-laki',
      age: 30,
      height: 170.0,
      weight: 65.0,
    );
  }

  // Create from Firebase user data
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      fullName: map['fullName'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'],
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      profileImageUrl: map['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
    };
  }
}
