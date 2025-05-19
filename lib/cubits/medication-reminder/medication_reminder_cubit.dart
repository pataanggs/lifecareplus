import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'medication_reminder_state.dart';

class MedicationReminderCubit extends Cubit<MedicationReminderState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MedicationReminderCubit() : super(const MedicationReminderStateInitial());

  Future<void> initialize() async {
    await loadUserData();
    await fetchMedications();
  }

  Future<void> loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final nickname = data['nickname'] ?? 'Pengguna';
        
        final currentData = state.data.copyWith(
          nickname: nickname,
          isLoading: true,
        );
        
        emit(MedicationReminderStateLoading(currentData));
      }
    } catch (e) {
      final currentData = state.data.copyWith(
        errorMessage: 'Error loading user data: $e',
      );
      emit(MedicationReminderStateError(currentData));
    }
  }

  Future<void> fetchMedications() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        final currentData = state.data.copyWith(
          errorMessage: 'User tidak ditemukan',
          isLoading: false,
        );
        emit(MedicationReminderStateError(currentData));
        return;
      }

      final currentData = state.data.copyWith(isLoading: true);
      emit(MedicationReminderStateLoading(currentData));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .orderBy('createdAt', descending: true)
          .get();

      final medications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['medicationName'] ?? '',
          'frequency': data['frequency'] ?? '',
          'time': data['time'] ?? '',
          'dosage': data['dosage'] ?? '',
          'unitType': data['unitType'] ?? '',
          'currentStock': data['currentStock'] ?? 0,
          'reminderThreshold': data['reminderThreshold'] ?? 0,
          'stockReminderEnabled': data['stockReminderEnabled'] ?? false,
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      final updatedData = state.data.copyWith(
        medications: medications,
        isLoading: false,
        errorMessage: null,
      );
      
      emit(MedicationReminderStateLoaded(updatedData));
    } catch (e) {
      final errorData = state.data.copyWith(
        errorMessage: 'Gagal mengambil data pengingat obat: $e',
        isLoading: false,
      );
      emit(MedicationReminderStateError(errorData));
    }
  }
}
