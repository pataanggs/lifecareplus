import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Create a new medication reminder
  Future<DocumentReference> addMedication({
    required String name,
    required String frequency,
    required String time,
    required String dosage,
    required bool stockReminderEnabled,
    required int currentStock,
    required int reminderThreshold,
    required String unitType,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    return await _firestore.collection('users').doc(_userId).collection('medications').add({
      'name': name,
      'frequency': frequency,
      'time': time,
      'dosage': dosage,
      'stockReminderEnabled': stockReminderEnabled,
      'currentStock': currentStock,
      'reminderThreshold': reminderThreshold,
      'unitType': unitType,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get all medications for the current user
  Stream<QuerySnapshot> getMedications() {
    if (_userId == null) throw Exception('User not authenticated');
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Get a specific medication
  Future<DocumentSnapshot> getMedication(String medicationId) {
    if (_userId == null) throw Exception('User not authenticated');
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .get();
  }
  
  // Update a medication
  Future<void> updateMedication(String medicationId, Map<String, dynamic> data) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .update(data);
  }
  
  // Update medication stock
  Future<void> updateMedicationStock(String medicationId, int newStock) async {
    await updateMedication(medicationId, {'currentStock': newStock});
  }
  
  // Delete a medication
  Future<void> deleteMedication(String medicationId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .delete();
  }
  
  // Toggle medication active status
  Future<void> toggleMedicationStatus(String medicationId, bool isActive) async {
    await updateMedication(medicationId, {'isActive': isActive});
  }
}