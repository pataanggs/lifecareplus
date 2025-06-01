import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../cubits/schedule/schedule_cubit.dart';
import '../../models/appointment.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(),
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Jadwal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF05606B),
                        Color(0xFF88C1D0),
                        Color(0xFFB5D8E2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      Expanded(
                        child:
                            state.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF05606B),
                                  ),
                                )
                                : state.appointments.isEmpty
                                ? _buildEmptyState()
                                : _buildAppointmentList(
                                  context,
                                  state.appointments,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF05606B),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jadwal'),
              onPressed: () {
                _showAppointmentForm(context);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 28,
            ),
          ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Jadwal Konsultasi & Pemeriksaan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.teal.shade700,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Belum ada jadwal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan jadwal konsultasi atau pemeriksaan Anda di sini.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(
    BuildContext context,
    List<Appointment> appointments,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(context, appointment, index)
            .animate(delay: (80 * index).ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment appointment,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: Color(0xFF05606B),
            size: 24,
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF05606B),
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${appointment.doctor} • ${appointment.location}',
              style: TextStyle(color: Colors.teal.shade800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(appointment.dateTime),
              style: TextStyle(color: Colors.teal.shade600, fontSize: 13),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            context.read<ScheduleCubit>().deleteAppointment(appointment.id);
          },
        ),
        onTap: () {
          _showAppointmentForm(context, appointment: appointment);
        },
      ),
    );
  }

  void _showAppointmentForm(BuildContext context, {Appointment? appointment}) {
    final isEdit = appointment != null;
    final titleController = TextEditingController(
      text: appointment?.title ?? '',
    );
    final doctorController = TextEditingController(
      text: appointment?.doctor ?? '',
    );
    final locationController = TextEditingController(
      text: appointment?.location ?? '',
    );
    DateTime selectedDate = appointment?.dateTime ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    isEdit ? 'Edit Jadwal' : 'Tambah Jadwal',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: doctorController,
                    decoration: InputDecoration(
                      labelText: 'Dokter',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Lokasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tanggal & Waktu: ${_formatDate(selectedDate)} ${_formatTime(selectedDate)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF05606B),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final time = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            if (time != null) {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                time.hour,
                                time.minute,
                              );
                            } else {
                              selectedDate = DateTime(
                                picked.year,
                                picked.month,
                                picked.day,
                                selectedDate.hour,
                                selectedDate.minute,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05606B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final title = titleController.text.trim();
                        final doctor = doctorController.text.trim();
                        final location = locationController.text.trim();
                        if (title.isEmpty ||
                            doctor.isEmpty ||
                            location.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field wajib diisi!'),
                            ),
                          );
                          return;
                        }
                        final cubit = context.read<ScheduleCubit>();
                        if (isEdit) {
                          cubit.deleteAppointment(appointment.id);
                        }
                        cubit.addAppointment(
                          Appointment(
                            id:
                                isEdit
                                    ? appointment.id
                                    : DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                            title: title,
                            dateTime: selectedDate,
                            doctor: doctor,
                            location: location,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Hari ini, ${_formatTime(dateTime)}';
    } else if (dateTime.isAfter(now)) {
      return 'Akan datang, ${_formatDate(dateTime)}';
    } else {
      return 'Selesai, ${_formatDate(dateTime)}';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
