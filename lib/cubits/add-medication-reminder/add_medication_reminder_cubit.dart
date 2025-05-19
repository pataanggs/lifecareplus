import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';

part 'add_medication_reminder_state.dart';

class AddMedicationCubit extends Cubit<AddMedicationState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AddMedicationCubit(this._firestore, this._auth)
      : super(const AddMedicationStateInitial()) {
    initialize();
  }

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
        
        emit(AddMedicationStateLoading(currentData));
      }
    } catch (e) {
      emit(AddMedicationStateError(
        state.data.copyWith(errorMessage: 'Error loading user data: $e'),
      ));
    }
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID');
    final formatted = formatter.format(now);

    final formattedDate = formatted
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');

    final currentData = state.data.copyWith(
      formattedDate: formattedDate,
    );
    
    emit(AddMedicationStateSuccess(currentData));
  }
}
