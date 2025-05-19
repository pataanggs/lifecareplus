import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

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
  MedicationSummaryCubit? _medicationSummaryCubit;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _medicationSummaryCubit = MedicationSummaryCubit();
    _medicationSummaryCubit?.initialize();
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
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                              'Hi, ${state.data.nickname}',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                            )
                                            .animate(delay: 100.ms)
                                            .fadeIn(duration: 400.ms),
                                        const SizedBox(height: 4),
                                        Text(
                                              state.data.formattedDate,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                            )
                                            .animate(delay: 200.ms)
                                            .fadeIn(duration: 400.ms),
                                      ],
                                    ),
                                    Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: .2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        )
                                        .animate(delay: 200.ms)
                                        .fadeIn(duration: 400.ms),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: .1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 80,
                                        color: Color(0xFF05606B),
                                      ),
                                    )
                                    .animate(delay: 300.ms)
                                    .fadeIn(duration: 600.ms)
                                    .scale(
                                      begin: const Offset(0.7, 0.7),
                                      end: const Offset(1.0, 1.0),
                                      duration: 600.ms,
                                      curve: Curves.elasticOut,
                                    ),

                                const SizedBox(height: 30),
                                const Text(
                                      'Pengingat Berhasil Dibuat',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                    .animate(delay: 500.ms)
                                    .fadeIn(duration: 400.ms),
                                const SizedBox(height: 40),
                                Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: .08,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.medicationName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF05606B),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(
                                            height: 1,
                                            color: Color(0xFFEAEAEA),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildDetailRow(
                                            label: 'Frekuensi',
                                            value: widget.frequency,
                                            delay: 700,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDetailRow(
                                            label: 'Waktu',
                                            value: widget.time,
                                            delay: 800,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDetailRow(
                                            label: 'Dosis',
                                            value: widget.dosage,
                                            delay: 900,
                                          ),
                                          if (widget.stockReminderEnabled) ...[
                                            const SizedBox(height: 16),
                                            const Divider(
                                              height: 1,
                                              color: Color(0xFFEAEAEA),
                                            ),
                                            const SizedBox(height: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Pengingat Stok',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                _buildDetailRow(
                                                  label: 'Stok Saat Ini',
                                                  value:
                                                      '${widget.currentStock} ${widget.unitType}',
                                                  delay: 1000,
                                                  valueColor: const Color(
                                                    0xFF9C4380,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                _buildDetailRow(
                                                  label: 'Notifikasi Pada',
                                                  value:
                                                      '${widget.reminderThreshold} ${widget.unitType}',
                                                  delay: 1100,
                                                  valueColor: const Color(
                                                    0xFF9C4380,
                                                  ),
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
                                    ),
                                const SizedBox(height: 40),
                                Text(
                                  'Anda akan mendapatkan notifikasi pada waktu yang telah ditentukan.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: .9),
                                    height: 1.5,
                                  ),
                                ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: RoundedButton(
                              text: 'Kembali ke Halaman Utama',
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) {
                                      return const MedicationReminderScreen();
                                    },
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
                      ),
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

  Widget _buildDetailRow({
    required String label,
    required String value,
    required int delay,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGS',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];
    final days = [
      'SENIN',
      'SELASA',
      'RABU',
      'KAMIS',
      'JUMAT',
      'SABTU',
      'MINGGU',
    ];

    final day = days[now.weekday - 1];
    final month = months[now.month - 1];

    return '$day, $month ${now.day}';
  }
}
