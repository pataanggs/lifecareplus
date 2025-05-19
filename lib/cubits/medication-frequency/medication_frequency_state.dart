part of 'medication_frequency_cubit.dart';

class MedicationFrequencyStateData extends Equatable {
  final String? errorMessage;
  final String formattedDate;
  final bool isLoading;
  final String nickname;

  const MedicationFrequencyStateData({
    this.errorMessage,
    this.isLoading = false,
    this.nickname = 'Pengguna',
    this.formattedDate = '',
  });

  MedicationFrequencyStateData copyWith({
    String? errorMessage,
    bool? isLoading,
    String? nickname,
    String? formattedDate,
  }) {
    return MedicationFrequencyStateData(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      nickname: nickname ?? this.nickname,
      formattedDate: formattedDate ?? this.formattedDate,
    );
  }

  @override
  List<Object?> get props => [errorMessage, isLoading, nickname, formattedDate];
}

sealed class MedicationFrequencyState extends Equatable {
  final MedicationFrequencyStateData data;
  const MedicationFrequencyState(this.data);

  @override
  List<Object?> get props => [data];
}

class MedicationFrequencyStateInitial extends MedicationFrequencyState {
  const MedicationFrequencyStateInitial() : super(const MedicationFrequencyStateData());
}

class MedicationFrequencyStateLoading extends MedicationFrequencyState {
  const MedicationFrequencyStateLoading(super.data);
}

class MedicationFrequencyStateSuccess extends MedicationFrequencyState {
  const MedicationFrequencyStateSuccess(super.data);
}

class MedicationFrequencyStateError extends MedicationFrequencyState {
  const MedicationFrequencyStateError(super.data);
}
