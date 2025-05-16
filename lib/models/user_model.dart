class UserModel {
  final String id;
  final String fullName;
  final String nickname;
  final String email;
  final String phone;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.email,
    required this.phone,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // Create a UserModel from a Map (from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      height: map['height'] ?? 0,
      weight: map['weight'] ?? 0,
      profileImageUrl: map['profileImageUrl'],
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  // Convert UserModel to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'updatedAt': DateTime.now(),
    };
  }

  // Create a copy of UserModel with some field changes
  UserModel copyWith({
    String? fullName,
    String? nickname,
    String? phone,
    String? gender,
    int? age,
    int? height,
    int? weight,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: this.id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      email: this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
