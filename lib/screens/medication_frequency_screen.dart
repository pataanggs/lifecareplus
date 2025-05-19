import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/cubits/medication-frequency/medication_frequency_cubit.dart';
import 'medication_schedule_screen.dart';
import '/widgets/rounded_button.dart';
import '/utils/colors.dart';

class MedicationFrequencyScreen extends StatefulWidget {
  final String medicationName;

  const MedicationFrequencyScreen({super.key, required this.medicationName});

  @override
  State<MedicationFrequencyScreen> createState() =>
      _MedicationFrequencyScreenState();
}

class _MedicationFrequencyScreenState extends State<MedicationFrequencyScreen> {
  bool _showContent = false;
  String _selectedFrequency = 'Sekali Sehari';
  final List<String> _frequencies = [
    'Sekali Sehari',
    'Dua Kali Sehari',
    'Tanpa Jadwal (Tanpa Alarm)',
    'Lainnya',
  ];

  MedicationFrequencyCubit? _medicationFrequencyCubit;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _medicationFrequencyCubit = MedicationFrequencyCubit();
    _medicationFrequencyCubit?.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _medicationFrequencyCubit?.close();
  }

  void _proceed() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicationScheduleScreen(
              medicationName: widget.medicationName,
              frequency: _selectedFrequency,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationFrequencyCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _medicationFrequencyCubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<MedicationFrequencyCubit, MedicationFrequencyState>(
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
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
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
                                  color: Colors.white.withValues(alpha: .2),
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
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kembali',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                          const SizedBox(height: 40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Obat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade200,
                                ),
                              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: .05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.medicationName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                              const SizedBox(height: 40),
                              Center(
                                child: Text(
                                  'Seberapa sering Anda butuh\nminum obat ini?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: .9),
                                  ),
                                ),
                              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                              const SizedBox(height: 32),
                              ..._frequencies.asMap().entries.map((entry) {
                                final index = entry.key;
                                final frequency = entry.value;
                                return _buildFrequencyOption(
                                  frequency: frequency,
                                  delay: 700 + (index * 100),
                                );
                              }),
                              const SizedBox(height: 40),
                            ],
                          ),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: RoundedButton(
                                    text: 'Selanjutnya',
                                    onPressed: _proceed,
                                    color: AppColors.textHighlight,
                                    textColor: Colors.black,
                                    width: 300,
                                    height: 50,
                                    borderRadius: 25,
                                    elevation: 3,
                                  )
                                  .animate(delay: 1100.ms)
                                  .fadeIn(
                                    duration: 600.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slideY(
                                    begin: 0.3,
                                    end: 0,
                                    duration: 600.ms,
                                    curve: Curves.easeOutQuad,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrequencyOption({
    required String frequency,
    required int delay,
  }) {
    final isSelected = _selectedFrequency == frequency;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFrequency = frequency);
      },
      child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF9AC0C9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? const Color(0xFF05606B) : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF05606B)
                                : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                            : null,
                  ),
                ],
              ),
            ),
          )
          .animate(delay: delay.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideX(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
