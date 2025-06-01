import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '/cubits/medication-summary/medication_summary_cubit.dart';
import 'medication_reminder_screen.dart';
import '/widgets/rounded_button.dart';
import '/utils/colors.dart';

class MedicationSummaryScreen extends StatefulWidget {
  final String medicationName;
  final String frequency;
  final String time;
  final String dosage;
  final bool stockReminderEnabled;
  final int currentStock;
  final int reminderThreshold;
  final String unitType;

  const MedicationSummaryScreen({
    super.key,
    required this.medicationName,
    required this.frequency,
    required this.time,
    required this.dosage,
    required this.stockReminderEnabled,
    required this.currentStock,
    required this.reminderThreshold,
    required this.unitType,
  });

  @override
  State<MedicationSummaryScreen> createState() =>
      _MedicationSummaryScreenState();
}

class _MedicationSummaryScreenState extends State<MedicationSummaryScreen> {
  bool _showContent = false;
  String _formattedDate = '';
  MedicationSummaryCubit? _medicationSummaryCubit;

  @override
  void initState() {
    super.initState();
    _setFormattedDate();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _medicationSummaryCubit = MedicationSummaryCubit();
    _medicationSummaryCubit?.initialize();
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
  }

  @override
  void dispose() {
    _medicationSummaryCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationSummaryCubit == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.textHighlight),
        ),
      );
    }

    return BlocProvider.value(
      value: _medicationSummaryCubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<MedicationSummaryCubit, MedicationSummaryState>(
          builder: (context, state) {
            return Container(
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
                  stops: [0.0, 0.3, 1.0],
                ),
              ),
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildHeader(state),
                                const SizedBox(height: 40),
                                _buildSuccessAnimation(),
                                const SizedBox(height: 30),
                                _buildSuccessMessage(),
                                const SizedBox(height: 40),
                                _buildMedicationDetails(),
                                const SizedBox(height: 40),
                                _buildNotificationInfo(),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildHomeButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MedicationSummaryState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${state.data.nickname}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              _formattedDate,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
            size: 28,
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF05606B),
              ),
            ],
          ),
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        const Text(
          'Pengingat Berhasil Dibuat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Notifikasi akan aktif sesuai jadwal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ).animate(delay: 550.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildMedicationDetails() {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.medicationName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF05606B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEAEAEA)),
              const SizedBox(height: 16),
              _buildDetailRow(
                label: 'Frekuensi',
                value: widget.frequency,
                icon: Icons.calendar_today_outlined,
                delay: 700,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                label: 'Waktu',
                value: widget.time,
                icon: Icons.access_time,
                delay: 800,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                label: 'Dosis',
                value: widget.dosage,
                icon: Icons.medication_liquid_outlined,
                delay: 900,
              ),
              if (widget.stockReminderEnabled) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEAEAEA)),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.teal.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pengingat Stok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      label: 'Stok Saat Ini',
                      value: '${widget.currentStock} ${widget.unitType}',
                      icon: Icons.inventory_2_outlined,
                      delay: 1000,
                      valueColor: Colors.teal.shade700,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      label: 'Notifikasi Pada',
                      value: '${widget.reminderThreshold} ${widget.unitType}',
                      icon: Icons.notifications_active_outlined,
                      delay: 1100,
                      valueColor: Colors.teal.shade700,
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
        .animate(delay: 600.ms)
        .fadeIn(duration: 500.ms)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 500.ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required int delay,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildNotificationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Anda akan mendapatkan notifikasi pada waktu yang telah ditentukan.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 1200.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildHomeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: RoundedButton(
            text: 'Kembali ke Halaman Utama',
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MedicationReminderScreen(),
                ),
                (route) => false,
              );
            },
            color: AppColors.textHighlight,
            textColor: Colors.black,
            width: 300,
            height: 50,
            borderRadius: 25,
            elevation: 3,
          )
          .animate(delay: 1300.ms)
          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
