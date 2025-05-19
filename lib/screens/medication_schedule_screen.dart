import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/cubits/medication-schedule/medication_schedule_cubit.dart';
import '/widgets/rounded_button.dart';
import 'medication_stock_screen.dart';
import '/utils/colors.dart';

class MedicationScheduleScreen extends StatefulWidget {
  final String medicationName;
  final String frequency;

  const MedicationScheduleScreen({
    super.key,
    required this.medicationName,
    required this.frequency,
  });

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  String _selectedDosage = '1 tablet';
  String _selectedTime = '08.00';
  bool _showContent = false;

  MedicationScheduleCubit? _medicationScheduleCubit;

  final List<String> _dosageOptions = [
    '1 tablet',
    '2 tablet',
    '3 tablet',
    '1 sendok teh',
    '1 kapsul',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _medicationScheduleCubit = MedicationScheduleCubit();
    _medicationScheduleCubit?.initialize();
  }

  @override
  void dispose() {
    _medicationScheduleCubit?.close();
    super.dispose();
  }

  void _proceed() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MedicationStockScreen(
            medicationName: widget.medicationName,
            frequency: widget.frequency,
            time: _selectedTime,
            dosage: _selectedDosage,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationScheduleCubit == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider.value(
      value: _medicationScheduleCubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<MedicationScheduleCubit, MedicationScheduleState>(
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
                          const SizedBox(height: 60),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  widget.medicationName,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF05606B),
                                  ),
                                ),
                              ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
                              const SizedBox(height: 40),
                              Text(
                                'Kapan baiknya kami mengingatkan Anda?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  color: Colors.white.withValues(alpha: .9),
                                ),
                              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                              const SizedBox(height: 60),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Jam',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _showTimePickerSheet,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: .1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedTime,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Dosis',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _showDosagePickerSheet,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: .1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedDosage,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
                              const SizedBox(height: 80),
                              RoundedButton(
                                    text: 'Selanjutnya',
                                    onPressed: _proceed,
                                    color: AppColors.textHighlight,
                                    textColor: Colors.black,
                                    width: 300,
                                    height: 50,
                                    borderRadius: 25,
                                    elevation: 3,
                                  )
                                  .animate(delay: 800.ms)
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
                              const SizedBox(height: 40),
                            ],
                          ),
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

  void _showTimePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedTime = _selectedTime;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF05606B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pilih Waktu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              margin: const EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                tempSelectedTime, // Show local selection
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05606B),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),

                            _buildTimeSelectionSection(
                              title: 'Pagi',
                              icon: Icons.wb_sunny_outlined,
                              iconColor: Colors.orange,
                              times: ['06.00', '07.00', '08.00', '09.00'],
                              selectedTime: tempSelectedTime,
                              onTimeSelected: (time) {
                                // Update both the temporary variable and the parent state
                                setModalState(() => tempSelectedTime = time);
                                setState(() => _selectedTime = time);
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildTimeSelectionSection(
                              title: 'Siang',
                              icon: Icons.wb_sunny,
                              iconColor: Colors.amber.shade700,
                              times: ['12.00', '13.00', '14.00'],
                              selectedTime: tempSelectedTime,
                              onTimeSelected: (time) {
                                setModalState(() => tempSelectedTime = time);
                                setState(() => _selectedTime = time);
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildTimeSelectionSection(
                              title: 'Malam',
                              icon: Icons.nightlight_round,
                              iconColor: Colors.indigo,
                              times: [
                                '18.00',
                                '19.00',
                                '20.00',
                                '21.00',
                                '22.00',
                              ],
                              selectedTime: tempSelectedTime,
                              onTimeSelected: (time) {
                                setModalState(() => tempSelectedTime = time);
                                setState(() => _selectedTime = time);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RoundedButton(
                      text: 'Konfirmasi',
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: double.infinity,
                      height: 50,
                      borderRadius: 25,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSelectionSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> times,
    required String selectedTime,
    required Function(String) onTimeSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              times.map((time) {
                final isSelected = selectedTime == time;
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTimeSelected(time);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF05606B) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF05606B)
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF05606B,
                                  ).withValues(alpha: .3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      time,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  void _showDosagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedDosage = _selectedDosage;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Sheet header with handle (unchanged)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF05606B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        const Text(
                          'Pilih Dosis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Dosage picker
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Selected Dosage Display
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              margin: const EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                tempSelectedDosage, // Show local selection
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF05606B),
                                ),
                              ),
                            ),

                            // Dosage options
                            Wrap(
                              spacing: 10,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children:
                                  _dosageOptions.map((dosage) {
                                    final isSelected =
                                        tempSelectedDosage == dosage;
                                    return InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        // Update both the temporary variable and the parent state
                                        setModalState(
                                          () => tempSelectedDosage = dosage,
                                        );
                                        setState(
                                          () => _selectedDosage = dosage,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.42,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF05606B)
                                                  : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? const Color(0xFF05606B)
                                                    : Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF05606B,
                                                      ).withValues(alpha: .3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.medication_outlined,
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.grey.shade700,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                dosage,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Confirm button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RoundedButton(
                      text: 'Konfirmasi',
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: double.infinity,
                      height: 50,
                      borderRadius: 25,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
