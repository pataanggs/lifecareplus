import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'local_storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MockStorageService {
  final LocalStorageService _localStorage = LocalStorageService();

  // Get current user ID
  Future<String?> get _userId async => await _localStorage.getCurrentUserId();

  // Upload profile image - in a real app, this would upload to Firebase Storage
  // In our mock version, we'll just return a placeholder URL
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');

      // Return local file path as the "download URL"
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return null;
    }
  }

  // Upload medication image
  Future<String?> uploadMedicationImage(
    File imageFile,
    String medicationId,
  ) async {
    final uid = await _userId;
    if (uid == null) return null;

    try {
      // Generate a fake URL based on the file name
      String fileName = path.basename(imageFile.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Copy the file to local app directory (for demo purposes)
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await imageFile.copy(
        '${appDir.path}/$uid\_med\_$medicationId\_$timestamp\_$fileName',
      );

      if (kDebugMode) {
        print('Medication image saved locally at: ${savedImage.path}');
      }

      // Return a placeholder URL that includes the file information
      return savedImage.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error in mock medication image upload: $e');
      }
      return null;
    }
  }

  // Delete image (mock implementation just logs the action)
  Future<bool> deleteImage(String imageUrl) async {
    if (kDebugMode) {
      print('Mock delete image: $imageUrl');
    }
    return true;
  }

  // Upload medicine image to local storage
  Future<String?> uploadMedicineImage(File imageFile) async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'medicine_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');

      // Return local file path as the "download URL"
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving medicine image: $e');
      return null;
    }
  }

  // Delete file from local storage
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Get file from local storage
  Future<File?> getFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file: $e');
      return null;
    }
  }
}
