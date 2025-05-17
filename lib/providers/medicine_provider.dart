import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/medicine_model.dart';
import '../services/mock_medicine_service.dart';
import '../services/mock_storage_service.dart';

class MedicineProvider with ChangeNotifier {
  final MockMedicineService _medicineService = MockMedicineService();
  final MockStorageService _storageService = MockStorageService();
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to medicines stream for the current user
  void listenToMedicines() {
    _medicineService.streamMedicines().listen(
      (medicines) {
        _medicines = medicines;
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
        imageUrl = await _storageService.uploadMedicationImage(
          imageFile,
          Medicine.generateId(),
        );
      }

      // Create medicine model with a new ID
      final String medicineId = Medicine.generateId();
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
        userId: 'current_user', // Will be set by the service
        reminderEnabled: reminderEnabled,
        imageUrl: imageUrl,
      );

      // Add to local storage
      await _medicineService.addMedicine(medicine);
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
      final existingMedicine = await _medicineService.getMedicineById(id);
      if (existingMedicine == null) {
        _error = 'Medicine not found';
        return false;
      }

      // Upload new image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadMedicationImage(imageFile, id);
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

      // Update in storage
      await _medicineService.updateMedicine(updatedMedicine);
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
      return await _medicineService.deleteMedicine(id);
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
