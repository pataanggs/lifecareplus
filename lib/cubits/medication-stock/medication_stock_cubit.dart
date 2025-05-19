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

      // Simpan data obat ke Firestore terlebih dahulu
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medicationId)
          .set(medicationData);

      bool reminderSuccess = true;
      String reminderError = '';

      if (stockReminderEnabled) {
        try {
          // Coba setup pengingat obat
          await _notificationService.scheduleMedicationReminder(
            medicationId: medicationId,
            medicationName: medicationName,
            time: formattedTime,
            dosage: dosage,
            unitType: unitType,
          );

          // Coba setup pengingat stok
          await _notificationService.scheduleStockReminder(
            medicationId: medicationId,
            medicationName: medicationName,
            currentStock: currentStock,
            reminderThreshold: reminderThreshold,
            unitType: unitType,
          );
        } catch (notificationError) {
          // Catat error tapi jangan menghentikan proses
          reminderSuccess = false;
          reminderError = notificationError.toString();
          
          if (kDebugMode) {
            print('Gagal mengatur notifikasi: $notificationError');
          }
        }
      }

      // Obat sudah disimpan, anggap sukses meskipun ada masalah dengan notifikasi
      final successData = state.data.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      emit(MedicationStockStateSuccess(successData));
      
      // Jika ada masalah dengan pengingat, tampilkan pesan setelah redirect
      if (!reminderSuccess && stockReminderEnabled) {
        if (kDebugMode) {
          print('Data obat disimpan, tetapi ada masalah dengan pengingat: $reminderError');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error menyimpan data obat: $e');
      }
      
      String errorMessage = 'Gagal menyimpan data';
      
      // Tambahkan pesan khusus untuk masalah izin alarm
      if (e.toString().contains('exact_alarm_not_permitted')) {
        errorMessage = 'Aplikasi membutuhkan izin untuk mengatur alarm. Silakan aktifkan di pengaturan perangkat Anda.';
      } else {
        errorMessage = 'Gagal menyimpan data: $e';
      }
      
      final errorData = state.data.copyWith(
        errorMessage: errorMessage,
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
