import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/medicine_model.dart';

class MedicineProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to medicines stream for the current user
  void listenToMedicines() {
    final userId = _firestore.collection('users').doc().id; // Get current user ID
    _firestore
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _medicines = snapshot.docs
            .map((doc) => Medicine.fromMap(doc.data()))
            .toList();
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load medicines: $error';
        debugPrint(_error);
        notifyListeners();
      },
    );
  }

  // Add a new medicine
  Future<bool> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required String timeOfDay,
    required DateTime startDate,
    required DateTime endDate,
    required String notes,
    required String color,
    required bool reminderEnabled,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        final ref = _storage.ref().child('medicines/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Create medicine model with a new ID
      final String medicineId = _firestore.collection('medicines').doc().id;
      final medicine = Medicine(
        id: medicineId,
        name: name,
        dosage: dosage,
        frequency: frequency,
        timeOfDay: timeOfDay,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
        color: color,
        userId: _firestore.collection('users').doc().id, // Get current user ID
        reminderEnabled: reminderEnabled,
        imageUrl: imageUrl,
      );

      // Add to Firestore
      await _firestore.collection('medicines').doc(medicineId).set(medicine.toMap());
      return true;
    } catch (e) {
      _error = 'Failed to add medicine: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing medicine
  Future<bool> updateMedicine({
    required String id,
    String? name,
    String? dosage,
    String? frequency,
    String? timeOfDay,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? color,
    bool? reminderEnabled,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find existing medicine
      final doc = await _firestore.collection('medicines').doc(id).get();
      if (!doc.exists) {
        _error = 'Medicine not found';
        return false;
      }

      final existingMedicine = Medicine.fromMap(doc.data()!);

      // Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        final ref = _storage.ref().child('medicines/$id.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Create updated medicine model
      final updatedMedicine = existingMedicine.copyWith(
        name: name,
        dosage: dosage,
        frequency: frequency,
        timeOfDay: timeOfDay,
        startDate: startDate,
        endDate: endDate,
        notes: notes,
        color: color,
        reminderEnabled: reminderEnabled,
        imageUrl: imageFile != null ? imageUrl : existingMedicine.imageUrl,
      );

      // Update in Firestore
      await _firestore.collection('medicines').doc(id).update(updatedMedicine.toMap());
      return true;
    } catch (e) {
      _error = 'Failed to update medicine: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a medicine
  Future<bool> deleteMedicine(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('medicines').doc(id).delete();
      return true;
    } catch (e) {
      _error = 'Failed to delete medicine: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's medicine schedule
  List<Medicine> getTodayMedicines() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _medicines.where((medicine) {
      // Check if medicine is active today (between start and end dates)
      final medicineStartDate = DateTime(
        medicine.startDate.year,
        medicine.startDate.month,
        medicine.startDate.day,
      );
      final medicineEndDate = DateTime(
        medicine.endDate.year,
        medicine.endDate.month,
        medicine.endDate.day,
      );

      return !today.isBefore(medicineStartDate) &&
          !today.isAfter(medicineEndDate);
    }).toList();
  }
}
