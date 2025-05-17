import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';
import '../models/medicine_model.dart';

class MockMedicineService {
  static const String _medicinesKey = 'local_medicines';
  final LocalStorageService _storage = LocalStorageService();

  // Get all medicines for the current user
  Future<List<Medicine>> getMedicines() async {
    final userId = await _storage.getCurrentUserId();
    if (userId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final String? medicinesJson = prefs.getString('${_medicinesKey}_$userId');

    if (medicinesJson == null) {
      // Initialize with some demo data for a new user
      final demoMedicines = _createDemoMedicines(userId);
      await saveMedicines(demoMedicines);
      return demoMedicines;
    }

    final List<dynamic> medicinesList = jsonDecode(medicinesJson);
    return medicinesList
        .map((medicineMap) => Medicine.fromMap(medicineMap))
        .toList();
  }

  // Save medicines for the current user
  Future<void> saveMedicines(List<Medicine> medicines) async {
    final userId = await _storage.getCurrentUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> medicineMaps =
        medicines.map((medicine) => medicine.toMap()).toList();
    await prefs.setString('${_medicinesKey}_$userId', jsonEncode(medicineMaps));
  }

  // Add a new medicine
  Future<Medicine> addMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    medicines.add(medicine);
    await saveMedicines(medicines);
    return medicine;
  }

  // Update an existing medicine
  Future<Medicine> updateMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    final index = medicines.indexWhere((m) => m.id == medicine.id);

    if (index >= 0) {
      medicines[index] = medicine;
      await saveMedicines(medicines);
    }

    return medicine;
  }

  // Delete a medicine
  Future<bool> deleteMedicine(String medicineId) async {
    final medicines = await getMedicines();
    final initialLength = medicines.length;

    medicines.removeWhere((medicine) => medicine.id == medicineId);

    if (medicines.length != initialLength) {
      await saveMedicines(medicines);
      return true;
    }

    return false;
  }

  // Get a medicine by ID
  Future<Medicine?> getMedicineById(String id) async {
    final medicines = await getMedicines();
    try {
      return medicines.firstWhere((medicine) => medicine.id == id);
    } catch (_) {
      return null;
    }
  }

  // Create some demo medicines for new users
  List<Medicine> _createDemoMedicines(String userId) {
    final now = DateTime.now();

    return [
      Medicine(
        id: 'demo_med_1',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'Once daily',
        timeOfDay: 'Morning',
        startDate: now.subtract(Duration(days: 10)),
        endDate: now.add(Duration(days: 20)),
        notes: 'Take with food',
        color: '#FF5722',
        userId: userId,
        reminderEnabled: true,
        imageUrl:
            'https://mock-storage.example.com/medication_images/demo/aspirin.jpg',
      ),
      Medicine(
        id: 'demo_med_2',
        name: 'Vitamin D',
        dosage: '1000 IU',
        frequency: 'Once daily',
        timeOfDay: 'Morning',
        startDate: now.subtract(Duration(days: 30)),
        endDate: now.add(Duration(days: 335)),
        notes: 'Take with breakfast',
        color: '#4CAF50',
        userId: userId,
        reminderEnabled: true,
        imageUrl: null,
      ),
      Medicine(
        id: 'demo_med_3',
        name: 'Ibuprofen',
        dosage: '200mg',
        frequency: 'As needed',
        timeOfDay: 'Any time',
        startDate: now.subtract(Duration(days: 5)),
        endDate: now.add(Duration(days: 10)),
        notes: 'For headache or pain',
        color: '#2196F3',
        userId: userId,
        reminderEnabled: false,
        imageUrl: null,
      ),
    ];
  }

  // Stream medicines (simulated)
  Stream<List<Medicine>> streamMedicines() async* {
    // Initial yield
    yield await getMedicines();

    // In a real app, this would use Firestore streaming
    // For our mock, we'll just poll every few seconds
    while (true) {
      await Future.delayed(Duration(seconds: 5));
      yield await getMedicines();
    }
  }
}
