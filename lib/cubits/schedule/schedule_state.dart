part of 'schedule_cubit.dart';

class ScheduleState extends Equatable {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    required this.appointments,
    required this.isLoading,
    this.error,
  });

  factory ScheduleState.initial() =>
      const ScheduleState(appointments: [], isLoading: true, error: null);

  ScheduleState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      appointments: appointments ?? this.appointments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [appointments, isLoading, error];
}
