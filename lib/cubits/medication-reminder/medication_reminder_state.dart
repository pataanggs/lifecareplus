part of 'medication_reminder_cubit.dart';

class MedicationReminderStateData extends Equatable {
  final List<Map<String, dynamic>> medications;
  final String nickname;
  final bool isLoading;
  final String? errorMessage;

  const MedicationReminderStateData({
    this.medications = const [],
    this.nickname = 'Pengguna',
    this.isLoading = false,
    this.errorMessage,
  });

  MedicationReminderStateData copyWith({
    List<Map<String, dynamic>>? medications,
    String? nickname,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MedicationReminderStateData(
      medications: medications ?? this.medications,
      nickname: nickname ?? this.nickname,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [medications, nickname, isLoading, errorMessage];
}

sealed class MedicationReminderState extends Equatable {
  final MedicationReminderStateData data;
  const MedicationReminderState(this.data);

  @override
  List<Object?> get props => [data];
}

class MedicationReminderStateInitial extends MedicationReminderState {
  const MedicationReminderStateInitial() : super(const MedicationReminderStateData());
}

class MedicationReminderStateLoading extends MedicationReminderState {
  const MedicationReminderStateLoading(super.data);
}

class MedicationReminderStateLoaded extends MedicationReminderState {
  const MedicationReminderStateLoaded(super.data);
}

class MedicationReminderStateError extends MedicationReminderState {
  const MedicationReminderStateError(super.data);
}
