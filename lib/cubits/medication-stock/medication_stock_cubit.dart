import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

import '../../services/notification_service.dart';
part 'medication_stock_state.dart';

class MedicationStockCubit extends Cubit<MedicationStockState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  MedicationStockCubit() : super(const MedicationStockStateInitial());

  Future<void> initialize() async {
    await loadUserData();
    _setFormattedDate();
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

        emit(MedicationStockStateLoading(currentData));
      }
    } catch (e) {
      final data = state.data.copyWith(
        errorMessage: 'Error loading user data: $e',
      );
      emit(MedicationStockStateError(data));
    }
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID');
    final formatted = formatter.format(now);

    final formattedDate = formatted
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');

    final currentData = state.data.copyWith(formattedDate: formattedDate);

    emit(MedicationStockStateSuccess(currentData));
  }

  Future<void> saveMedicationData({
    required String medicationName,
    required String frequency,
    required String time,
    required String dosage,
    required String unitType,
    required int currentStock,
    required int reminderThreshold,
    required bool stockReminderEnabled,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        final data = state.data.copyWith(
          errorMessage: 'User tidak ditemukan',
          isLoading: false,
        );
        emit(MedicationStockStateError(data));
        return;
      }

      final currentData = state.data.copyWith(isLoading: true);
      emit(MedicationStockStateLoading(currentData));

      final medicationId = _firestore.collection('medications').doc().id;
      String formattedTime = time;
      if (time.contains('.')) {
        formattedTime = time.replaceAll('.', ':');
      }

      final medicationData = {
        'id': medicationId,
        'medicationName': medicationName,
        'frequency': frequency,
        'time': formattedTime,
        'dosage': dosage,
        'unitType': unitType,
        'currentStock': currentStock,
        'reminderThreshold': reminderThreshold,
        'stockReminderEnabled': stockReminderEnabled,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid,
      };

      // Simpan data obat ke Firestore
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medicationId)
          .set(medicationData);

      if (stockReminderEnabled) {
        await _notificationService.scheduleMedicationReminder(
          medicationId: medicationId,
          medicationName: medicationName,
          time: formattedTime,
          dosage: dosage,
          unitType: unitType,
        );

        await _notificationService.scheduleStockReminder(
          medicationId: medicationId,
          medicationName: medicationName,
          currentStock: currentStock,
          reminderThreshold: reminderThreshold,
          unitType: unitType,
        );
      }

      final successData = state.data.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      emit(MedicationStockStateSuccess(successData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving medication data: $e');
      }
      final errorData = state.data.copyWith(
        errorMessage: 'Gagal menyimpan data: $e',
        isLoading: false,
      );
      emit(MedicationStockStateError(errorData));
    }
  }

  Future<void> decrementMedicationStock(String medicationId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medicationId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentStock = data['currentStock'] as int;
      final reminderThreshold = data['reminderThreshold'] as int;
      final stockReminderEnabled = data['stockReminderEnabled'] as bool;
      final medicationName = data['medicationName'] as String;
      final unitType = data['unitType'] as String;

      if (currentStock <= 1) {
        await docRef.delete();
        await _notificationService.cancelAllRemindersForMedication(
          medicationId,
        );
        return;
      }

      // pengurangan stock
      final newStock = currentStock - 1;
      await docRef.update({'currentStock': newStock});

      if (stockReminderEnabled && newStock <= reminderThreshold) {
        await _notificationService.scheduleStockReminder(
          medicationId: medicationId,
          medicationName: medicationName,
          currentStock: newStock,
          reminderThreshold: reminderThreshold,
          unitType: unitType,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decrementing stock: $e');
      }
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medicationId)
          .delete();

      await _notificationService.cancelAllRemindersForMedication(medicationId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting medication: $e');
      }
    }
  }
}
