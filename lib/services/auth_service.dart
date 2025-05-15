import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email, 
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String nickname,
    required String email,
    required String phone,
    required String gender,
    required int age,
    required int height,
    required int weight,
    String? profileImageUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'nickname': nickname,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'profileImageUrl': profileImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic>? : null;
  }
  
  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(data);
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}