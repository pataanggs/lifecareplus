import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

part 'medication_stock_state.dart';

class MedicationStockCubit extends Cubit<MedicationStockState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

      final medicationData = {
        'medicationName': medicationName,
        'frequency': frequency,
        'time': time,
        'dosage': dosage,
        'unitType': unitType,
        'currentStock': currentStock,
        'reminderThreshold': reminderThreshold,
        'stockReminderEnabled': stockReminderEnabled,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': uid,
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .add(medicationData);

      final successData = state.data.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      emit(MedicationStockStateSuccess(successData));
    } catch (e) {
      final errorData = state.data.copyWith(
        errorMessage: 'Gagal menyimpan data: $e',
        isLoading: false,
      );
      emit(MedicationStockStateError(errorData));
    }
  }
}
