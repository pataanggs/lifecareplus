part of 'add_medication_reminder_cubit.dart';

class AddMedicationStateData extends Equatable {
  final String? errorMessage;
  final bool isLoading;
  final String nickname;
  final String formattedDate;

  const AddMedicationStateData({
    this.errorMessage,
    this.isLoading = false,
    this.nickname = 'Pengguna',
    this.formattedDate = '',
  });

  AddMedicationStateData copyWith({
    String? errorMessage,
    bool? isLoading,
    String? nickname,
    String? formattedDate,
  }) {
    return AddMedicationStateData(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      nickname: nickname ?? this.nickname,
      formattedDate: formattedDate ?? this.formattedDate,
    );
  }

  @override
  List<Object?> get props => [errorMessage, isLoading, nickname, formattedDate];
}

sealed class AddMedicationState extends Equatable {
  final AddMedicationStateData data;
  const AddMedicationState(this.data);

  @override
  List<Object?> get props => [data];
}

class AddMedicationStateInitial extends AddMedicationState {
  const AddMedicationStateInitial() : super(const AddMedicationStateData());
}

class AddMedicationStateLoading extends AddMedicationState {
  const AddMedicationStateLoading(super.data);
}

class AddMedicationStateSuccess extends AddMedicationState {
  const AddMedicationStateSuccess(super.data);
}

class AddMedicationStateError extends AddMedicationState {
  const AddMedicationStateError(super.data);
}
