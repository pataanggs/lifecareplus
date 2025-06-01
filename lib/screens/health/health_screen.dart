import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HealthRecord {
  final String id;
  final String type;
  final String value;
  final DateTime date;
  final String notes;

  HealthRecord({
    required this.id,
    required this.type,
    required this.value,
    required this.date,
    required this.notes,
  });
}

class HealthCubit extends Cubit<HealthState> {
  HealthCubit() : super(HealthState.initial()) {
    loadRecords();
  }

  void loadRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    emit(
      state.copyWith(
        records: [
          HealthRecord(
            id: '1',
            type: 'Tekanan Darah',
            value: '120/80 mmHg',
            date: DateTime.now().subtract(const Duration(days: 1)),
            notes: 'Normal',
          ),
          HealthRecord(
            id: '2',
            type: 'Berat Badan',
            value: '70 kg',
            date: DateTime.now().subtract(const Duration(days: 3)),
            notes: 'Stabil',
          ),
        ],
        isLoading: false,
      ),
    );
  }

  void addRecord(HealthRecord record) {
    final updated = List<HealthRecord>.from(state.records)..insert(0, record);
    emit(state.copyWith(records: updated));
  }

  void deleteRecord(String id) {
    final updated = state.records.where((r) => r.id != id).toList();
    emit(state.copyWith(records: updated));
  }
}

class HealthState {
  final List<HealthRecord> records;
  final bool isLoading;
  final String? error;

  HealthState({required this.records, required this.isLoading, this.error});

  factory HealthState.initial() => HealthState(records: [], isLoading: true);

  HealthState copyWith({
    List<HealthRecord>? records,
    bool? isLoading,
    String? error,
  }) {
    return HealthState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HealthCubit(),
      child: BlocBuilder<HealthCubit, HealthState>(
        builder: (context, state) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Kesehatan',
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
                                : state.records.isEmpty
                                ? _buildEmptyState()
                                : _buildRecordList(context, state.records),
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
              label: const Text('Tambah Data'),
              onPressed: () {
                _showHealthRecordForm(context);
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
              Icons.monitor_heart,
              color: Colors.white,
              size: 28,
            ),
          ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Catatan Kesehatan',
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
              Icons.monitor_heart,
              size: 48,
              color: Colors.teal.shade700,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Belum ada data kesehatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan catatan kesehatan Anda di sini.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordList(BuildContext context, List<HealthRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(context, record, index)
            .animate(delay: (80 * index).ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    HealthRecord record,
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
            Icons.monitor_heart,
            color: Color(0xFF05606B),
            size: 24,
          ),
        ),
        title: Text(
          record.type,
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
              record.value,
              style: TextStyle(color: Colors.teal.shade800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(record.date),
              style: TextStyle(color: Colors.teal.shade600, fontSize: 13),
            ),
            if (record.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  record.notes,
                  style: TextStyle(color: Colors.teal.shade400, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            context.read<HealthCubit>().deleteRecord(record.id);
          },
        ),
        onTap: () {
          _showHealthRecordForm(context, record: record);
        },
      ),
    );
  }

  void _showHealthRecordForm(
    BuildContext parentContext, {
    HealthRecord? record,
  }) {
    final isEdit = record != null;
    final typeController = TextEditingController(text: record?.type ?? '');
    final valueController = TextEditingController(text: record?.value ?? '');
    final notesController = TextEditingController(text: record?.notes ?? '');
    DateTime selectedDate = record?.date ?? DateTime.now();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                    isEdit ? 'Edit Data Kesehatan' : 'Tambah Data Kesehatan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: 'Jenis Data',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: 'Nilai',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
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
                          'Tanggal: ${_formatDate(selectedDate)}',
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
                            context: sheetContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                            );
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
                        final type = typeController.text.trim();
                        final value = valueController.text.trim();
                        final notes = notesController.text.trim();
                        if (type.isEmpty || value.isEmpty) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Jenis dan Nilai wajib diisi!'),
                            ),
                          );
                          return;
                        }
                        final cubit = parentContext.read<HealthCubit>();
                        if (isEdit) {
                          cubit.deleteRecord(record!.id);
                        }
                        cubit.addRecord(
                          HealthRecord(
                            id:
                                isEdit
                                    ? record!.id
                                    : DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                            type: type,
                            value: value,
                            date: selectedDate,
                            notes: notes,
                          ),
                        );
                        Navigator.pop(sheetContext);
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
