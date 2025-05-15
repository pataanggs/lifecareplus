import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    if (_userId == null) return null;
    
    String fileName = '${_userId}_profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    
    try {
      final Reference storageRef = _storage.ref().child('profile_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
  
  // Upload medication image
  Future<String?> uploadMedicationImage(File imageFile, String medicationId) async {
    if (_userId == null) return null;
    
    String fileName = '${_userId}_med_${medicationId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    
    try {
      final Reference storageRef = _storage.ref().child('medication_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading medication image: $e');
      return null;
    }
  }
  
  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}