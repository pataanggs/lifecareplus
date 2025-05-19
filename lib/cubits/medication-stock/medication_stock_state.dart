part of 'medication_stock_cubit.dart';

class MedicationStockStateData extends Equatable {
  final String? errorMessage;
  final String formattedDate;
  final bool isLoading;
  final String nickname;
  final bool isSuccess;

  const MedicationStockStateData({
    this.errorMessage,
    this.isLoading = false,
    this.nickname = 'Pengguna',
    this.formattedDate = '',
    this.isSuccess = false,
  });

  MedicationStockStateData copyWith({
    String? errorMessage,
    bool? isLoading,
    String? nickname,
    String? formattedDate,
    bool? isSuccess,
  }) {
    return MedicationStockStateData(
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

sealed class MedicationStockState extends Equatable {
  final MedicationStockStateData data;
  const MedicationStockState(this.data);

  @override
  List<Object?> get props => [data];
}

class MedicationStockStateInitial extends MedicationStockState {
  const MedicationStockStateInitial() : super(const MedicationStockStateData());
}

class MedicationStockStateLoading extends MedicationStockState {
  const MedicationStockStateLoading(super.data);
}

class MedicationStockStateSuccess extends MedicationStockState {
  const MedicationStockStateSuccess(super.data);
}

class MedicationStockStateError extends MedicationStockState {
  const MedicationStockStateError(super.data);
}
