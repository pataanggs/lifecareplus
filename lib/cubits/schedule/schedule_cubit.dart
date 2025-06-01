import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/appointment.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit() : super(ScheduleState.initial()) {
    loadAppointments();
  }

  void loadAppointments() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(
      appointments: [
        Appointment(
          id: '1',
          title: 'Konsultasi Umum',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          doctor: 'dr. Sarah Wijaya',
          location: 'Klinik Sehat',
        ),
        Appointment(
          id: '2',
          title: 'Pemeriksaan Rutin',
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
          doctor: 'dr. Budi Santoso',
          location: 'RS Harapan',
        ),
      ],
      isLoading: false,
    ));
  }

  void addAppointment(Appointment appointment) {
    final updated = List<Appointment>.from(state.appointments)..insert(0, appointment);
    emit(state.copyWith(appointments: updated));
  }

  void deleteAppointment(String id) {
    final updated = state.appointments.where((a) => a.id != id).toList();
    emit(state.copyWith(appointments: updated));
  }
} 