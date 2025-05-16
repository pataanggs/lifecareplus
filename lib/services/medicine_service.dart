import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/medicine_model.dart';
import 'dart:developer' as developer;

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // Get all medicines for the current user
  Stream<List<MedicineModel>> getMedicinesStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('medicines')
        .where('userId', isEqualTo: currentUserId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get medicine by id
  Future<MedicineModel?> getMedicineById(String medicineId) async {
    try {
      final doc =
          await _firestore.collection('medicines').doc(medicineId).get();
      if (doc.exists) {
        return MedicineModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      developer.log('Error getting medicine: $e');
      return null;
    }
  }

  // Add a new medicine
  Future<String?> addMedicine(MedicineModel medicine, {File? imageFile}) async {
    try {
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadMedicineImage(imageFile);
      }

      // Create medicine data
      final medicineData = medicine.toMap();
      if (imageUrl != null) {
        medicineData['imageUrl'] = imageUrl;
      }

      // Add to Firestore
      final docRef = await _firestore.collection('medicines').add(medicineData);
      return docRef.id;
    } catch (e) {
      developer.log('Error adding medicine: $e');
      return null;
    }
  }

  // Update an existing medicine
  Future<bool> updateMedicine(MedicineModel medicine, {File? imageFile}) async {
    try {
      // Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadMedicineImage(imageFile);
      }

      // Update medicine data
      final medicineData = medicine.toMap();
      if (imageUrl != null) {
        medicineData['imageUrl'] = imageUrl;
      }

      // Update in Firestore
      await _firestore
          .collection('medicines')
          .doc(medicine.id)
          .update(medicineData);
      return true;
    } catch (e) {
      developer.log('Error updating medicine: $e');
      return false;
    }
  }

  // Delete medicine (soft delete by setting isActive to false)
  Future<bool> deleteMedicine(String medicineId) async {
    try {
      await _firestore.collection('medicines').doc(medicineId).update({
        'isActive': false,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      developer.log('Error deleting medicine: $e');
      return false;
    }
  }

  // Mark medicine as taken
  Future<bool> markMedicineAsTaken(
    String medicineId,
    DateTime takenDate,
  ) async {
    try {
      final medicine = await getMedicineById(medicineId);
      if (medicine == null) return false;

      final updatedMedicine = medicine.markAsTaken(takenDate);
      return await updateMedicine(updatedMedicine);
    } catch (e) {
      developer.log('Error marking medicine as taken: $e');
      return false;
    }
  }

  // Mark medicine as missed
  Future<bool> markMedicineAsMissed(
    String medicineId,
    DateTime missedDate,
  ) async {
    try {
      final medicine = await getMedicineById(medicineId);
      if (medicine == null) return false;

      final updatedMedicine = medicine.markAsMissed(missedDate);
      return await updateMedicine(updatedMedicine);
    } catch (e) {
      developer.log('Error marking medicine as missed: $e');
      return false;
    }
  }

  // Upload medicine image to Firebase Storage
  Future<String?> _uploadMedicineImage(File imageFile) async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final storageRef = _storage
          .ref()
          .child('medicines')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      developer.log('Error uploading medicine image: $e');
      return null;
    }
  }
}
