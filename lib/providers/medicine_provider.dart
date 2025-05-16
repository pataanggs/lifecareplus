import 'package:flutter/foundation.dart';
import '../services/medicine_service.dart';
import '../models/medicine_model.dart';
import 'dart:io';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _error;

  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to medicines stream for the current user
  void listenToMedicines() {
    _medicineService.getMedicinesStream().listen(
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
    required String description,
    required String dosage,
    required String frequency,
    required String interval,
    required List<DateTime> scheduledTimes,
    DateTime? startDate,
    DateTime? endDate,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create medicine model
      final medicine = MedicineModel(
        id: '', // Will be set by Firestore
        userId: _medicineService.currentUserId ?? '',
        name: name,
        description: description,
        dosage: dosage,
        frequency: frequency,
        interval: interval,
        scheduledTimes: scheduledTimes,
        startDate: startDate,
        endDate: endDate,
        takenDates: [],
        missedDates: [],
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add to Firestore
      final medicineId = await _medicineService.addMedicine(
        medicine,
        imageFile: imageFile,
      );
      return medicineId != null;
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
    String? description,
    String? dosage,
    String? frequency,
    String? interval,
    List<DateTime>? scheduledTimes,
    DateTime? startDate,
    DateTime? endDate,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Find existing medicine
      final existingIndex = _medicines.indexWhere((m) => m.id == id);
      if (existingIndex < 0) {
        _error = 'Medicine not found';
        return false;
      }

      // Create updated medicine model
      final existingMedicine = _medicines[existingIndex];
      final updatedMedicine = existingMedicine.copyWith(
        name: name,
        description: description,
        dosage: dosage,
        frequency: frequency,
        interval: interval,
        scheduledTimes: scheduledTimes,
        startDate: startDate,
        endDate: endDate,
      );

      // Update in Firestore
      return await _medicineService.updateMedicine(
        updatedMedicine,
        imageFile: imageFile,
      );
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

  // Mark medicine as taken
  Future<bool> markMedicineAsTaken(String id, DateTime takenDate) async {
    try {
      return await _medicineService.markMedicineAsTaken(id, takenDate);
    } catch (e) {
      _error = 'Failed to mark medicine as taken: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Mark medicine as missed
  Future<bool> markMedicineAsMissed(String id, DateTime missedDate) async {
    try {
      return await _medicineService.markMedicineAsMissed(id, missedDate);
    } catch (e) {
      _error = 'Failed to mark medicine as missed: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Get today's medicine schedule
  List<MedicineModel> getTodayMedicines() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _medicines.where((medicine) {
      // Check if the medicine is scheduled for today
      return medicine.scheduledTimes.any((time) {
        final scheduleDate = DateTime(time.year, time.month, time.day);
        return scheduleDate.isAtSameMomentAs(today);
      });
    }).toList();
  }
}
