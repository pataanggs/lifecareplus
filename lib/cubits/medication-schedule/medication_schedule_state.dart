part of 'medication_schedule_cubit.dart';

class MedicationScheduleStateData extends Equatable {
  final String? errorMessage;
  final String formattedDate;
  final bool isLoading;
  final String nickname;

  const MedicationScheduleStateData({
    this.errorMessage,
    this.isLoading = false,
    this.nickname = 'Pengguna',
    this.formattedDate = '',
  });

  MedicationScheduleStateData copyWith({
    String? errorMessage,
    bool? isLoading,
    String? nickname,
    String? formattedDate,
  }) {
    return MedicationScheduleStateData(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      nickname: nickname ?? this.nickname,
      formattedDate: formattedDate ?? this.formattedDate,
    );
  }

  @override
  List<Object?> get props => [errorMessage, isLoading, nickname, formattedDate];
}

sealed class MedicationScheduleState extends Equatable {
  final MedicationScheduleStateData data;
  const MedicationScheduleState(this.data);

  @override
  List<Object?> get props => [data];
}

class MedicationScheduleStateInitial extends MedicationScheduleState {
  const MedicationScheduleStateInitial() : super(const MedicationScheduleStateData());
}

class MedicationScheduleStateLoading extends MedicationScheduleState {
  const MedicationScheduleStateLoading(super.data);
}

class MedicationScheduleStateSuccess extends MedicationScheduleState {
  const MedicationScheduleStateSuccess(super.data);
}

class MedicationScheduleStateError extends MedicationScheduleState {
  const MedicationScheduleStateError(super.data);
}
