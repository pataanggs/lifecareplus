import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';

class MockMedicationService {
  static const String _medicationsKey = 'mock_medications';
  final LocalStorageService _storage = LocalStorageService();
  final _medicationsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Singleton pattern
  static final MockMedicationService _instance =
      MockMedicationService._internal();
  factory MockMedicationService() => _instance;
  MockMedicationService._internal() {
    _loadMedications();
  }

  // Load medications and initialize stream
  Future<void> _loadMedications() async {
    final medications = await _getMedicationsFromStorage();
    _medicationsController.add(medications);
  }

  // Get all medications from local storage
  Future<List<Map<String, dynamic>>> _getMedicationsFromStorage() async {
    final userId = await _storage.getCurrentUserId();
    if (userId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final String? medicationsJson = prefs.getString(
      '${_medicationsKey}_$userId',
    );

    if (medicationsJson == null) {
      // Add demo data for first-time users
      final demoMedications = _createDemoMedications();
      await _saveMedicationsToStorage(demoMedications);
      return demoMedications;
    }

    try {
      final List<dynamic> medicationsList = jsonDecode(medicationsJson);
      return List<Map<String, dynamic>>.from(medicationsList);
    } catch (e) {
      print('Error parsing medications: $e');
      return [];
    }
  }

  // Save medications to local storage
  Future<void> _saveMedicationsToStorage(
    List<Map<String, dynamic>> medications,
  ) async {
    final userId = await _storage.getCurrentUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_medicationsKey}_$userId',
      jsonEncode(medications),
    );

    // Update stream
    _medicationsController.add(medications);
  }

  // Get medications stream
  Stream<List<Map<String, dynamic>>> getMedications() {
    return _medicationsController.stream;
  }

  // Add a new medication
  Future<String> addMedication({
    required String name,
    required String frequency,
    required String time,
    required String dosage,
    required bool stockReminderEnabled,
    required int currentStock,
    required int reminderThreshold,
    required String unitType,
  }) async {
    final medications = await _getMedicationsFromStorage();

    final String id = 'med_${DateTime.now().millisecondsSinceEpoch}';

    final newMedication = {
      'id': id,
      'name': name,
      'frequency': frequency,
      'time': time,
      'dosage': dosage,
      'stockReminderEnabled': stockReminderEnabled,
      'currentStock': currentStock,
      'reminderThreshold': reminderThreshold,
      'unitType': unitType,
      'isActive': true,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    medications.add(newMedication);

    await _saveMedicationsToStorage(medications);
    return id;
  }

  // Toggle medication status (active/inactive)
  Future<void> toggleMedicationStatus(String id, bool isActive) async {
    final medications = await _getMedicationsFromStorage();

    final index = medications.indexWhere((med) => med['id'] == id);
    if (index >= 0) {
      medications[index]['isActive'] = isActive;
      medications[index]['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _saveMedicationsToStorage(medications);
    }
  }

  // Update medication
  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    final medications = await _getMedicationsFromStorage();

    final index = medications.indexWhere((med) => med['id'] == id);
    if (index >= 0) {
      medications[index] = {
        ...medications[index],
        ...data,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _saveMedicationsToStorage(medications);
    }
  }

  // Delete medication
  Future<void> deleteMedication(String id) async {
    final medications = await _getMedicationsFromStorage();

    final filteredMedications =
        medications.where((med) => med['id'] != id).toList();

    if (filteredMedications.length != medications.length) {
      await _saveMedicationsToStorage(filteredMedications);
    }
  }

  // Create demo medications
  List<Map<String, dynamic>> _createDemoMedications() {
    return [
      {
        'id': 'demo_med_1',
        'name': 'Paracetamol',
        'frequency': 'Setiap 6 jam',
        'time': 'Pagi, Siang, Sore, Malam',
        'dosage': '500mg',
        'stockReminderEnabled': true,
        'currentStock': 20,
        'reminderThreshold': 5,
        'unitType': 'tablet',
        'isActive': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'demo_med_2',
        'name': 'Vitamin C',
        'frequency': 'Setiap hari',
        'time': 'Pagi',
        'dosage': '1000mg',
        'stockReminderEnabled': true,
        'currentStock': 15,
        'reminderThreshold': 3,
        'unitType': 'tablet',
        'isActive': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'demo_med_3',
        'name': 'Insulin',
        'frequency': 'Setiap hari',
        'time': 'Pagi, Malam',
        'dosage': '10 unit',
        'stockReminderEnabled': true,
        'currentStock': 5,
        'reminderThreshold': 2,
        'unitType': 'vial',
        'isActive': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];
  }

  // Dispose
  void dispose() {
    _medicationsController.close();
  }
}
