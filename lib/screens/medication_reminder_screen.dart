import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/cubits/medication-reminder/medication_reminder_cubit.dart';
import '/cubits/medication-stock/medication_stock_cubit.dart';
import '/widgets/rounded_button.dart';
import 'add_medication_screen.dart';
import '/utils/colors.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  bool _showContent = false;
  String _formattedDate = '';
  MedicationReminderCubit? _medicationCubit;
  MedicationStockCubit? _stockCubit;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    initializeDateFormatting('id_ID').then((_) {
      _setFormattedDate();
      if (mounted) setState(() {});
    });

    _medicationCubit = MedicationReminderCubit();
    _stockCubit = MedicationStockCubit();
    _medicationCubit?.initialize();
    _stockCubit?.initialize();
  }

  @override
  void dispose() {
    _medicationCubit?.close();
    _stockCubit?.close();
    super.dispose();
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID');
    final formatted = formatter.format(now);
    _formattedDate = formatted
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');

    if (mounted) setState(() {});
  }

  void _createReminder() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    ).then((_) {
      if (mounted) {
        _medicationCubit?.fetchMedications();
      }
    });
  }

  void _deleteMedication(String medicationId) async {
    HapticFeedback.mediumImpact();
    await _stockCubit?.deleteMedication(medicationId);
    if (mounted) {
      _medicationCubit?.fetchMedications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat obat berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationCubit == null || _stockCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _medicationCubit!),
        BlocProvider.value(value: _stockCubit!),
      ],
      child: BlocConsumer<MedicationReminderCubit, MedicationReminderState>(
        listener: (context, state) {
          if (state is MedicationReminderStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.data.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF05606B), Color(0xFF88C1D0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child:
                      state is MedicationReminderStateLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state is MedicationReminderStateError
                          ? Center(
                            child: Text(
                              state.data.errorMessage ?? 'An error occurred',
                            ),
                          )
                          : state is MedicationReminderStateLoaded
                          ? _buildContent(state.data)
                          : const SizedBox(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(MedicationReminderStateData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${data.nickname}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    _formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Text(
                'Pengingat Obat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 20),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ),
        const SizedBox(height: 16),
        Expanded(
          child:
              data.medications.isEmpty
                  ? Center(
                    child: RoundedButton(
                          text: 'Buat Pengingat Pertama',
                          onPressed: _createReminder,
                          color: AppColors.textHighlight,
                          textColor: Colors.black,
                          width: 300,
                          height: 50,
                          borderRadius: 25,
                          elevation: 3,
                        )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad,
                        ),
                  )
                  : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: data.medications.length,
                          itemBuilder: (context, index) {
                            final medication = data.medications[index];
                            return _buildMedicationCard(medication);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 40,
                        ),
                        child: RoundedButton(
                          text: 'Tambah Pengingat',
                          onPressed: _createReminder,
                          color: AppColors.textHighlight,
                          textColor: Colors.black,
                          width: 300,
                          height: 50,
                          borderRadius: 25,
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final bool isLowStock = medication['stockReminderEnabled'] == true &&
        (medication['currentStock'] ?? 0) <= (medication['reminderThreshold'] ?? 0);

    return Slidable(
      key: ValueKey(medication['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteMedication(medication['id']),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isLowStock
                ? Border.all(color: Colors.red.shade300, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'] ?? 'Nama Obat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medication['dosage']} ${medication['unitType']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textHighlight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.textHighlight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medication['time'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (medication['stockReminderEnabled'] == true) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: isLowStock ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stok: ${medication['currentStock']} ${medication['unitType']}',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.grey.shade600,
                              fontWeight: isLowStock ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }
}
