part of 'medication_summary_cubit.dart';

class MedicationSummaryStateData extends Equatable {
  final String? errorMessage;
  final String formattedDate;
  final bool isLoading;
  final String nickname;
  final bool isSuccess;

  const MedicationSummaryStateData({
    this.errorMessage,
    this.isLoading = false,
    this.nickname = 'Pengguna',
    this.formattedDate = '',
    this.isSuccess = false,
  });

  MedicationSummaryStateData copyWith({
    String? errorMessage,
    bool? isLoading,
    String? nickname,
    String? formattedDate,
    bool? isSuccess,
  }) {
    return MedicationSummaryStateData(
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      nickname: nickname ?? this.nickname,
      formattedDate: formattedDate ?? this.formattedDate,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [errorMessage, isLoading, nickname, formattedDate, isSuccess];
}

sealed class MedicationSummaryState extends Equatable {
  final MedicationSummaryStateData data;
  const MedicationSummaryState(this.data);

  @override
  List<Object?> get props => [data];
}

class MedicationSummaryStateInitial extends MedicationSummaryState {
  const MedicationSummaryStateInitial() : super(const MedicationSummaryStateData());
}

class MedicationSummaryStateLoading extends MedicationSummaryState {
  const MedicationSummaryStateLoading(super.data);
}

class MedicationSummaryStateSuccess extends MedicationSummaryState {
  const MedicationSummaryStateSuccess(super.data);
}

class MedicationSummaryStateError extends MedicationSummaryState {
  const MedicationSummaryStateError(super.data);
}
