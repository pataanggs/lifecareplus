import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

part 'medication_schedule_state.dart';

class MedicationScheduleCubit extends Cubit<MedicationScheduleState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MedicationScheduleCubit() : super(MedicationScheduleStateInitial());

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

        emit(MedicationScheduleStateLoading(currentData));
      }
    } catch (e) {
      final data = state.data.copyWith(
        errorMessage: 'Error loading user data: $e',
      );
      emit(MedicationScheduleStateError(data));
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

    emit(MedicationScheduleStateSuccess(currentData));
  }
}
