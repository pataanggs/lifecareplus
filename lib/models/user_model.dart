import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String nickname;
  final String email;
  final String phone;
  final String gender;
  final int age;
  final double height; // Using double for potential decimal values
  final double weight; // Using double
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    required this.createdAt,
    required this.updatedAt,
  });

  // Method to convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      // 'id' is the document ID, not usually stored in the map itself
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ), // Store as Firestore Timestamp
      'updatedAt': Timestamp.fromDate(
        updatedAt,
      ), // Store as Firestore Timestamp
    };
  }

  // Convert UserModel to a Map for local storage (different from Firestore format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      height: (data['height'] as num?)?.toDouble() ?? 0.0,
      weight: (data['weight'] as num?)?.toDouble() ?? 0.0,
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor to create UserModel from a Map (for local storage)
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      fullName: map['fullName'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      profileImageUrl: map['profileImageUrl'],
      createdAt:
          map['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
              : DateTime.now(),
    );
  }

  // Create a copy of UserModel with some field changes
  UserModel copyWith({
    String? fullName,
    String? nickname,
    String? phone,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      email: email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Equality operator override
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          nickname == other.nickname &&
          email == other.email &&
          phone == other.phone &&
          gender == other.gender &&
          age == other.age &&
          height == other.height &&
          weight == other.weight &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      nickname.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      gender.hashCode ^
      age.hashCode ^
      height.hashCode ^
      weight.hashCode ^
      (profileImageUrl?.hashCode ?? 0);
}
